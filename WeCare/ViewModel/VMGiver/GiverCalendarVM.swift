//
//  GiverCalendarVM.swift
//  WeCare (Firestore-integrated, caregiver forced to Budi)
//
import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

@MainActor
final class GiverCalendarVM: ObservableObject {
    // ===== USERS =====
    @Published var users: [Users] = []
    @Published var selectedUser: Users? = nil           // UI selection (filter UI)
    @Published var currentCaregiver: Users? = nil       // forced caregiver (Budi)

    // ===== UI STATE =====
    @Published var selectedDate: Date = Date()
    @Published var currentMonthOffset: Int = 0
    @Published var selectedPerson: Users? = nil         // selected careReceiver

    // ===== ADD-AGENDA SHEET =====
    @Published var showingAddAgenda = false
    @Published var newAgendaTitle = ""
    @Published var newAgendaDescription = ""
    @Published var newAgendaOwner: Users? = nil         // not used for owner when forcing caregiver
    @Published var newAgendaStatus: UrgencyStatus = .low
    @Published var newAgendaTimeDate: Date = Date()
    @Published var newAgendaType: AgendaType = .activity
    @Published var selectedMedicine: Medicines? = nil

    // ===== ALERT =====
    @Published var showPastDateAlert = false
    private var confirmSavePastAgenda = false

    // ===== DETAIL / EDIT =====
    @Published var selectedAgenda: AgendaItem? = nil
    @Published var showingEditAgenda = false
    @Published var editAgendaOriginal: AgendaItem? = nil
    @Published var editAgendaTitle = ""
    @Published var editAgendaDescription = ""
    @Published var editAgendaTimeDate = Date()
    @Published var editAgendaStatus: UrgencyStatus = .low
    @Published var editAgendaOwner: Users? = nil
    @Published var editAgendaType: AgendaType = .activity
    @Published var isTitleEditable: Bool = true

    // ===== DATA =====
    // persons holds only careReceivers (so the view/pickers won't show the caregiver)
    @Published var persons: [Users] = []
    // agendaData organized by receiver's fullName
    @Published var agendaData: [String: [String: [AgendaItem]]] = [:]

    private let db = Firestore.firestore()
    private let tasksCollection = "Tasks" // root collection as per your screenshot

    // MARK: - Initialization / caregiver forcing

    /// Call updateUsers when UsersTableViewModel publishes users.
    /// This will set the forced caregiver (Budi) and keep `persons` to receivers only.
    func updateUsers(_ newUsers: [Users]) {
        print("VM.updateUsers called — count: \(newUsers.count)")
        self.users = newUsers

        // Force caregiver to Budi if possible, otherwise use first caregiver fallback
        forceCaregiverToBudiOrFirst(newUsers: newUsers)

    
        // persons should contain only careReceivers so UI lists (filter/picker) don't show caregiver
        self.persons = newUsers.filter { user in
            // normalize role checks: "careReceiver", "careReceiver", "carereceiver", etc.
            let r = user.role.lowercased()
            return r.contains("receiver") || r.contains("carereceiver") // be robust
        }

        // If selectedPerson disappeared in the new set, clear it
        if let sel = selectedPerson, !newUsers.contains(where: { $0.id == sel.id }) {
            print("Previously selected person not present anymore -> clearing selectedPerson")
            selectedPerson = nil
            selectedUser = nil
        }

        // If a receiver is selected, fetch their tasks
        if selectedPerson != nil {
            print("Selected person present after update -> fetching tasks")
            Task {
                await fetchTasksForSelectedReceiver()
            }
        } else if let firstReceiver = persons.first {
            // Optionally auto-select the first receiver so UI isn't empty:
            // comment this out if you prefer no default selection
            selectedPerson = firstReceiver
            selectedUser = firstReceiver
            Task {
                await fetchTasksForSelectedReceiver()
            }
        }
    }

    /// Force caregiver to Budi (by full name "Budi" or role contains "caregiv").
    private func forceCaregiverToBudiOrFirst(newUsers: [Users]) {
        // Prefer exact Budi Santoso match if present
        if let budi = newUsers.first(where: { $0.fullName.lowercased().contains("budi") && $0.role.lowercased().contains("caregiv") }) {
            currentCaregiver = budi
            print("🔥 Forced caregiver to Budi: \(budi.fullName)")
            return
        }

        // Otherwise pick first caregiver by role
        if let firstGiver = newUsers.first(where: { $0.role.lowercased().contains("caregiv") }) {
            currentCaregiver = firstGiver
            print("⚠️ Budi not found. Forced caregiver to first caregiver: \(firstGiver.fullName)")
            return
        }

        // fallback: nil
        currentCaregiver = nil
        print("⚠️ No caregiver found in users list.")
    }

    // For the view: expose receiver users (to populate filter/picker)
    var receiverUsers: [Users] {
        persons
    }

    // MARK: - Calendar helpers

    var currentMonthName: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: dateByAddingMonths(currentMonthOffset))
    }

    private func dateByAddingMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
    }

    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: dateByAddingMonths(currentMonthOffset))?.count ?? 30
    }

    func dateForDay(_ day: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month], from: dateByAddingMonths(currentMonthOffset))
        comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    var currentAgenda: [AgendaItem] {
        let key = dateKey(from: selectedDate)
        if let person = selectedPerson {
            return agendaData[person.fullName]?[key] ?? []
        }
        return persons.flatMap { agendaData[$0.fullName]?[key] ?? [] }
    }

    // MARK: - Remove / Delete (local only; also delete from Firestore)

    func deleteAgenda(_ agenda: AgendaItem) {
        let key = dateKey(from: selectedDate)
        if let person = selectedPerson {
            _ = removeAgenda(ownerName: person.fullName, dateKey: key, agenda: agenda)
        } else {
            for p in persons {
                if removeAgenda(ownerName: p.fullName, dateKey: key, agenda: agenda) { break }
            }
        }

        // attempt to delete in Firestore if this agenda corresponds to a persisted task (task_id)
        // our AgendaItem.id when loaded from Firestore uses the documentID; when locally created it's UUID.
        if let docId = Int(agenda.id) == nil ? agenda.id : nil {
            // if the id is the Firestore docID (string), remove doc
            Task {
                do {
                    try await db.collection(tasksCollection).document(agenda.id).delete()
                    print("Firestore: deleted docId=\(agenda.id)")
                    // refresh
                    await fetchTasksForSelectedReceiver()
                } catch {
                    print("❌ Firestore delete failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @discardableResult
    private func removeAgenda(ownerName: String, dateKey: String, agenda: AgendaItem) -> Bool {
        var ownerMap = agendaData[ownerName] ?? [:]
        var dayList = ownerMap[dateKey] ?? []
        let before = dayList.count
        dayList.removeAll { $0.id == agenda.id }
        if before != dayList.count {
            ownerMap[dateKey] = dayList.isEmpty ? nil : dayList
            agendaData[ownerName] = ownerMap
            print("Removed agenda locally for receiver='\(ownerName)' date='\(dateKey)'")
            return true
        }
        return false
    }

    // MARK: - FIRESTORE: Fetch tasks for selected receiver

    /// Loads tasks from Firestore for selectedReceiver (and currentCaregiver if present).
    func fetchTasksForSelectedReceiver() async {
        guard let receiver = selectedPerson else {
            print("⚠️ fetchTasks aborted: no selectedPerson")
            return
        }

        print("fetchTasks: loading tasks for receiver='\(receiver.fullName)' (userId=\(receiver.userId))")
        do {
            var query: Query = db.collection(tasksCollection).whereField("careReceiver_id", isEqualTo: receiver.userId)

            // If we have a forced caregiver, narrow by caregiver as well (keeps the calendar focused)
            if let giver = currentCaregiver {
                query = query.whereField("careGiver_id", isEqualTo: giver.userId)
                print("fetchTasks: additionally filtering by careGiver_id=\(giver.userId)")
            }

            let snapshot = try await query.getDocuments()
            print("📥 fetchTasks -> found \(snapshot.documents.count) docs for receiver \(receiver.fullName)")

            var newAgendaForReceiver: [String: [AgendaItem]] = [:]

            for doc in snapshot.documents {
                let data = doc.data()
                let caregiverUserId = data["careGiver_id"] as? Int ?? 0
                // map caregiver id -> Users model (search in full user list)
                let caregiver = self.users.first { $0.userId == caregiverUserId }

                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let typeString = (data["type"] as? String) ?? UrgencyStatus.low.rawValue
                let medicineId = data["medicine_id"] as? Int
                // due_time (Timestamp) -> Date
                let dueTimestamp = (data["due_time"] as? Timestamp)?.dateValue() ?? Date()

                let dateKey = dateKey(from: dueTimestamp)
                let timeString = timeFormatter.string(from: dueTimestamp)

                let agenda = AgendaItem(
                    id: doc.documentID, // use Firestore docID for persisted items
                    title: title,
                    description: description,
                    time: timeString,
                    date: dateKey,
                    status: UrgencyStatus(rawValue: typeString) ?? .low,
                    type: (medicineId == nil ? .activity : .medicine),
                    ownerId: caregiver?.id ?? "",
                    ownerName: caregiver?.fullName ?? "Unknown",
                    medicineId: medicineId,
                    medicineName: nil,
                    medicineImage: nil
                )

                print("  → parsed task docId=\(doc.documentID) title='\(title)' date=\(dateKey) time=\(timeString) caregiverUserId=\(caregiverUserId)")

                var arr = newAgendaForReceiver[dateKey] ?? []
                arr.append(agenda)
                newAgendaForReceiver[dateKey] = arr
            }

            // Update local cache
            DispatchQueue.main.async {
                self.agendaData[receiver.fullName] = newAgendaForReceiver
                print("✅ fetchTasks: agendaData[\(receiver.fullName)] updated (keys: \(newAgendaForReceiver.keys.count))")
            }

        } catch {
            print("❌ fetchTasks error: \(error.localizedDescription)")
        }
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        return f
    }

    // MARK: - SAVE NEW AGENDA (local + Firestore)

    /// Saves agenda locally and writes to Firestore under the forced caregiver (Budi).
    func saveNewAgenda() {
        print("saveNewAgenda called — type=\(newAgendaType) title='\(newAgendaTitle)' selectedPerson='\(selectedPerson?.fullName ?? "nil")' time=\(newAgendaTimeDate)")

        // validate receiver
        guard let receiver = selectedPerson else {
            print("saveNewAgenda -> abort: selectedPerson (receiver) is nil")
            return
        }

        // prevent past date unless confirmed
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfAgendaDay = calendar.startOfDay(for: selectedDate)
        if startOfAgendaDay < startOfToday && !confirmSavePastAgenda {
            print("saveNewAgenda -> past date; showing confirm alert")
            showPastDateAlert = true
            return
        }

        // determine caregiver (forced)
        guard let caregiver = currentCaregiver ?? users.first(where: { $0.role.lowercased().contains("caregiv") }) else {
            print("❌ saveNewAgenda -> abort: no caregiver available")
            return
        }
        print("🔧 FORCED OWNER = caregiver '\(caregiver.fullName)'")

        // display time string
        let f = DateFormatter(); f.dateFormat = "hh:mm a"
        let timeString = f.string(from: newAgendaTimeDate)

        // title
        let finalTitle = newAgendaType == .medicine ? "💊 \(selectedMedicine?.medicineName ?? newAgendaTitle)" : newAgendaTitle

        let dateKey = dateKey(from: selectedDate)

        // Build local AgendaItem (id will be a UUID for local cache; after Firestore write we refresh and replace with doc id)
        let localItem = AgendaItem(
            id: UUID().uuidString,
            title: finalTitle,
            description: newAgendaDescription,
            time: timeString,
            date: dateKey,
            status: newAgendaStatus,
            type: newAgendaType,
            ownerId: receiver.id,
            ownerName: receiver.fullName,
            medicineId: newAgendaType == .medicine ? selectedMedicine?.medicineId : nil,
            medicineName: newAgendaType == .medicine ? selectedMedicine?.medicineName : nil,
            medicineImage: newAgendaType == .medicine ? selectedMedicine?.medicineImage : nil
        )

        // Store locally under receiver
        var receiverMap = agendaData[receiver.fullName] ?? [:]
        var dayList = receiverMap[dateKey] ?? []
        dayList.append(localItem)
        receiverMap[dateKey] = dayList
        agendaData[receiver.fullName] = receiverMap
        print("Local cache updated for receiver '\(receiver.fullName)' date '\(dateKey)' — dayListCount: \(dayList.count)")

        // Write to Firestore
        Task {
            await createTaskInFirestore(from: localItem, caregiver: caregiver, receiver: receiver)
        }

        // reset
        confirmSavePastAgenda = false
        resetNewAgendaFields()
    }

    func confirmSavingPastAgenda() {
        confirmSavePastAgenda = true
        showPastDateAlert = false
        saveNewAgenda()
    }

    // MARK: - FIRESTORE: create task doc (auto-increment task_id)

    private func createTaskInFirestore(from agenda: AgendaItem, caregiver: Users, receiver: Users) async {
        print("createTaskInFirestore -> start (ownerUserId=\(caregiver.userId), receiverUserId=\(receiver.userId))")

        do {
            let nextTaskId = try await getNextTaskId()
            print("Next task_id = \(nextTaskId)")

            // merge date string + agenda.time into Timestamp
            // agenda.date is yyyy-MM-dd; agenda.time is "hh:mm a"
            let dueTimestamp = try mergeDateAndTimeToTimestamp(dateString: agenda.date, timeString: agenda.time)
            print("dueTimestamp = \(dueTimestamp.dateValue())")

            var data: [String: Any] = [
                "task_id": nextTaskId,
                "careGiver_id": caregiver.userId,
                "careReceiver_id": receiver.userId,
                "created_at": Timestamp(date: Date()),
                "title": agenda.title,
                "description": agenda.description,
                "due_time": dueTimestamp,
                "is_completed": false,
                "type": agenda.status.rawValue
            ]

            if let mid = agenda.medicineId { data["medicine_id"] = mid }
            else { data["medicine_id"] = NSNull() }

            // Write document with numeric string id (so it matches existing numeric docs if you want)
            let docId = String(nextTaskId)
            try await db.collection(tasksCollection).document(docId).setData(data)
            print("✅ Firestore: task created (task_id=\(nextTaskId), docId=\(docId))")

            // Refresh tasks for this receiver to replace local UUID items with persisted ones
            await fetchTasksForSelectedReceiver()

        } catch {
            print("❌ createTaskInFirestore error: \(error.localizedDescription)")
        }
    }

    // Auto-increment task_id: read highest task_id and +1 (best-effort)
    private func getNextTaskId() async throws -> Int {
        let snapshot = try await db.collection(tasksCollection)
            .order(by: "task_id", descending: true)
            .limit(to: 1)
            .getDocuments()
        if let doc = snapshot.documents.first, let max = doc.data()["task_id"] as? Int {
            return max + 1
        } else {
            return 1
        }
    }

    // merge "yyyy-MM-dd" + "hh:mm a" -> Timestamp
    private func mergeDateAndTimeToTimestamp(dateString: String, timeString: String) throws -> Timestamp {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm a"
        let combined = "\(dateString) \(timeString)"
        if let d = df.date(from: combined) {
            return Timestamp(date: d)
        } else {
            throw NSError(domain: "WeCare.MergeDateError", code: -1)
        }
    }

    // MARK: - EDIT flow (local + Firestore best-effort)

    func startEditing(_ agenda: AgendaItem) {
        editAgendaOriginal = agenda

        if agenda.medicineId != nil {
            editAgendaTitle = agenda.medicineName ?? ""
            isTitleEditable = false
        } else {
            if agenda.title.starts(with: "💊 ") {
                editAgendaTitle = String(agenda.title.dropFirst(2))
            } else {
                editAgendaTitle = agenda.title
            }
            isTitleEditable = true
        }

        editAgendaDescription = agenda.description

        let df = DateFormatter(); df.dateFormat = "hh:mm a"
        editAgendaTimeDate = df.date(from: agenda.time) ?? Date()
        editAgendaStatus = agenda.status
        // default owner for edit — we keep to forced caregiver when saving
        editAgendaOwner = currentCaregiver
        editAgendaType = agenda.medicineId != nil ? .medicine : .activity

        // restore medicine selection if needed
        if editAgendaType == .medicine {
            selectedMedicine = Medicines(
                id: agenda.id,
                data: [
                    "medicine_id": agenda.medicineId ?? 0,
                    "medicine_name": agenda.medicineName ?? "",
                    "medicine_image": agenda.medicineImage ?? ""
                ]
            )
        } else {
            selectedMedicine = nil
        }

        showingEditAgenda = true
    }

    func saveEditedAgenda() {
        print("saveEditedAgenda called")
        guard let original = editAgendaOriginal else { print("saveEditedAgenda -> original nil"); return }
        // always use forced caregiver as owner (Budi)
        guard let caregiver = currentCaregiver else { print("saveEditedAgenda -> no caregiver"); return }
        guard let receiver = selectedPerson else { print("saveEditedAgenda -> no receiver"); return }

        let key = dateKey(from: selectedDate)
        let f = DateFormatter(); f.dateFormat = "hh:mm a"
        let timeString = f.string(from: editAgendaTimeDate)

        let updated = AgendaItem(
            id: original.id,
            title: editAgendaType == .medicine ? "💊 \(selectedMedicine?.medicineName ?? "")" : editAgendaTitle,
            description: editAgendaDescription,
            time: timeString,
            date: key,
            status: editAgendaStatus,
            type: editAgendaType,
            ownerId: caregiver.id,
            ownerName: caregiver.fullName,
            medicineId: editAgendaType == .medicine ? selectedMedicine?.medicineId : nil,
            medicineName: editAgendaType == .medicine ? selectedMedicine?.medicineName : nil,
            medicineImage: editAgendaType == .medicine ? selectedMedicine?.medicineImage : nil
        )

        // local: replace
        for p in persons {
            if removeAgenda(ownerName: p.fullName, dateKey: key, agenda: original) { break }
        }
        var receiverMap = agendaData[caregiver.fullName] ?? [:]
        var list = receiverMap[key] ?? []
        list.append(updated)
        receiverMap[key] = list
        agendaData[caregiver.fullName] = receiverMap
        print("Local edited agenda saved (id=\(updated.id))")

        // update Firestore best-effort: find doc(s) matching task_id or title
        Task {
            do {
                // Attempt to match by numeric doc ID if original.id is numeric-ish
                if let numericDocId = Int(original.id) {
                    // numeric doc id case (you used numeric doc ids for tasks)
                    let docRef = db.collection(tasksCollection).document(String(numericDocId))
                    var updateData: [String: Any] = [
                        "title": updated.title,
                        "description": updated.description,
                        "type": updated.status.rawValue,
                        "due_time": Timestamp(date: combine(date: selectedDate, time: editAgendaTimeDate))
                    ]
                    if let mid = updated.medicineId { updateData["medicine_id"] = mid } else { updateData["medicine_id"] = NSNull() }
                    try await docRef.updateData(updateData)
                    print("Updated Firestore docId=\(numericDocId)")
                } else {
                    // fallback: query by caregiver+receiver+title (best-effort)
                    let query = db.collection(tasksCollection)
                        .whereField("careGiver_id", isEqualTo: caregiver.userId)
                        .whereField("careReceiver_id", isEqualTo: receiver.userId)
                        .whereField("title", isEqualTo: original.title)

                    let snapshot = try await query.getDocuments()
                    print("saveEditedAgenda: matched \(snapshot.documents.count) documents")

                    for doc in snapshot.documents {
                        var updateData: [String: Any] = [
                            "title": updated.title,
                            "description": updated.description,
                            "type": updated.status.rawValue,
                            "due_time": Timestamp(date: combine(date: selectedDate, time: editAgendaTimeDate))
                        ]
                        if let mid = updated.medicineId { updateData["medicine_id"] = mid } else { updateData["medicine_id"] = NSNull() }
                        try await doc.reference.updateData(updateData)
                        print("Updated Firestore docId=\(doc.documentID)")
                    }
                }

                // refresh local
                await fetchTasksForSelectedReceiver()
            } catch {
                print("❌ saveEditedAgenda Firestore update error: \(error.localizedDescription)")
            }
        }

        showingEditAgenda = false
    }

    // MARK: - Colors / Helpers

    func colorForDay(_ day: Int) -> Color {
        let key = dateKey(forDay: day, in: dateByAddingMonths(currentMonthOffset))
        var statuses: [UrgencyStatus] = []

        func appendStatus(_ p: Users) {
            if let list = agendaData[p.fullName]?[key] {
                statuses.append(contentsOf: list.map { $0.status })
            }
        }

        if let sel = selectedPerson { appendStatus(sel) }
        else { persons.forEach { appendStatus($0) } }

        if statuses.contains(.critical) { return .red.opacity(0.8) }
        if statuses.contains(.high)     { return .yellow.opacity(0.7) }
        if statuses.contains(.medium)   { return .blue.opacity(0.7) }
        if statuses.contains(.low)      { return .green.opacity(0.7) }
        return .gray.opacity(0.15)
    }

    func dateKey(from date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func dateKey(forDay day: Int, in base: Date) -> String {
        var comps = Calendar.current.dateComponents([.year, .month], from: base)
        comps.day = day
        return dateKey(from: Calendar.current.date(from: comps) ?? base)
    }

    func combine(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: date)
        let t = cal.dateComponents([.hour, .minute], from: time)
        return cal.date(from:
            DateComponents(year: d.year, month: d.month, day: d.day,
                           hour: t.hour, minute: t.minute)
        ) ?? date
    }

    // MARK: - Reset form
    func resetNewAgendaFields() {
        newAgendaTitle = ""
        newAgendaDescription = ""
        // do not clear selectedPerson (we keep the receiver selected in calendar)
        newAgendaOwner = nil
        newAgendaStatus = .low
        newAgendaTimeDate = Date()
        newAgendaType = .activity
        selectedMedicine = nil
    }
}
