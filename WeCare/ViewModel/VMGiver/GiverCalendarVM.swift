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
    @Published var selectedPerson: Users? = nil {
        didSet {
            detachTasksListener()
            if selectedPerson != nil {
                Task {
                    await fetchTasksForSelectedReceiver()
                    await setupTasksListener()
                }
            } else {
                Task { await fetchTasksForAllReceivers() }
            }
        }
    }
    
    private var didInitialLoad = false

    // ===== ADD-AGENDA SHEET =====
    @Published var showingAddAgenda = false
    @Published var newAgendaTitle = ""
    @Published var newAgendaDescription = ""
    @Published var newAgendaOwner: Users? = nil         // not used for owner when forcing caregiver
    @Published var newAgendaStatus: UrgencyStatus = .low
    @Published var newAgendaTimeDate: Date = Date()
    @Published var newAgendaType: AgendaType = .activity
    @Published var selectedMedicine: Medicines? = nil
    @Published var medicines: [Medicines] = []
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
    @Published var agendaData: [Int: [String: [AgendaItem]]] = [:]
    //            receiverId
    
    private let db = Firestore.firestore()
    private let tasksCollection = "Tasks" // root collection as per your screenshot
    private var tasksListener: ListenerRegistration? = nil

    private func detachTasksListener() {
        if let l = tasksListener {
            l.remove()
            tasksListener = nil
            print("🔌 Detached previous tasks listener")
        }
    }

    func updateUsers(_ newUsers: [Users]) {
        self.users = newUsers
        forceCaregiverToBudiOrFirst(newUsers: newUsers)

        self.persons = newUsers.filter {
            let r = $0.role.lowercased()
            return r.contains("receiver")
        }

        // ✅ AUTO LOAD ALL ON FIRST USER LOAD
        if !didInitialLoad {
            didInitialLoad = true
            Task { await fetchTasksForAllReceivers() }
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
            return (agendaData[person.userId]?[key] ?? [])
                .sorted { $0.time < $1.time }
        }


        return persons
            .flatMap { agendaData[$0.userId]?[key] ?? [] }
            .sorted { $0.time < $1.time }
    }

    func deleteAgenda(_ agenda: AgendaItem) {
        let key = dateKey(from: selectedDate)
        
        if let person = selectedPerson {
            _ = removeAgenda(
                receiverId: agenda.receiverId,
                dateKey: key,
                agenda: agenda
            )

        } else {
            _ = removeAgenda(
                receiverId: agenda.receiverId,
                dateKey: key,
                agenda: agenda
            )
        }
        
        // Always use agenda.id as Firestore docID
        Task {
            do {
                try await db.collection(tasksCollection)
                    .document(agenda.id)
                    .delete()
                
                print("🔥 Firestore permanently deleted docId = \(agenda.id)")
                await fetchTasksForSelectedReceiver()
                
            } catch {
                print("❌ Firestore delete failed: \(error.localizedDescription)")
            }
        }
    }

    @discardableResult
    private func removeAgenda(
        receiverId: Int,
        dateKey: String,
        agenda: AgendaItem
    ) -> Bool {


        var receiverMap = agendaData[receiverId] ?? [:]
        var dayList = receiverMap[dateKey] ?? []


        let before = dayList.count
        dayList.removeAll { $0.id == agenda.id }


        if before != dayList.count {
            receiverMap[dateKey] = dayList.isEmpty ? nil : dayList
            agendaData[receiverId] = receiverMap
            return true
        }
        return false
    }

    func loadMedicines() async {
        do {
            let snapshot = try await db.collection("Medicines").getDocuments()
            
            let meds = snapshot.documents.map { doc in
                Medicines(id: doc.documentID, data: doc.data())
            }
            
            DispatchQueue.main.async {
                self.medicines = meds
                print("📥 Loaded \(meds.count) medicines")
            }
        } catch {
            print("❌ Error loading medicines: \(error)")
        }
    }
    
    init() {
        Task {
            await loadMedicines() //LOAD MEDICINE DULU SUPAYA MEDICINE ID NYA GA NIL BARU FETCH TASKS
        }
    }
    
    /// Attach a real-time listener for the selected receiver (and forced caregiver if present).
    /// This keeps `agendaData` up-to-date automatically when any `is_completed` or other fields change.
    func setupTasksListener() async {
        // detach existing
        detachTasksListener()

        guard let receiver = selectedPerson else {
            print("⚠️ setupTasksListener aborted: no selectedPerson")
            return
        }

        print("setupTasksListener -> attaching for receiver='\(receiver.fullName)' (userId=\(receiver.userId))")

        var query: Query = db.collection(tasksCollection).whereField("careReceiver_id", isEqualTo: receiver.userId)

        if let giver = currentCaregiver {
            query = query.whereField("careGiver_id", isEqualTo: giver.userId)
            print("setupTasksListener: additionally filtering by careGiver_id=\(giver.userId)")
        }

        // attach snapshot listener
        tasksListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("❌ tasks listener error: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else {
                print("⚠️ tasks listener: snapshot nil")
                return
            }

            var newAgendaForReceiver: [String: [AgendaItem]] = [:]

            for doc in snapshot.documents {
                let data = doc.data()
                let caregiverUserId = data["careGiver_id"] as? Int ?? 0
                let caregiver = self.users.first { $0.userId == caregiverUserId }

                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let typeString = (data["type"] as? String) ?? UrgencyStatus.low.rawValue
                let medicineId = data["medicine_id"] as? Int
                let dueTimestamp = (data["due_time"] as? Timestamp)?.dateValue() ?? Date()
                let dateKey = self.dateKey(from: dueTimestamp)
                let timeString = self.timeFormatter.string(from: dueTimestamp)

                // parse completed
                let isCompleted = data["is_completed"] as? Bool ?? false

                var medName: String? = nil
                var medImage: String? = nil
                if let medId = medicineId {
                    if let med = self.medicines.first(where: { $0.medicineId == medId }) {
                        medName = med.medicineName
                        medImage = med.medicineImage
                    } else {
                        print("⚠️ MedicineID \(medId) not found in medicines list")
                    }
                }

                let agenda = AgendaItem(
                    id: doc.documentID,
                    title: title,
                    description: description,
                    time: timeString,
                    date: dateKey,
                    status: UrgencyStatus(rawValue: typeString) ?? .low,
                    type: (medicineId == nil ? .activity : .medicine),
                    ownerId: caregiver?.id ?? "",
                    ownerName: caregiver?.fullName ?? "Unknown",
                    receiverId: receiver.userId,
                    receiverName: receiver.fullName,
                    medicineId: medicineId,
                    medicineName: medName,
                    medicineImage: medImage,
                    isCompleted: isCompleted
                )


                var arr = newAgendaForReceiver[dateKey] ?? []
                arr.append(agenda)
                newAgendaForReceiver[dateKey] = arr
            }

            DispatchQueue.main.async {
                self.agendaData[receiver.userId] = newAgendaForReceiver
                print("🔔 tasksListener updated agendaData[\(receiver.fullName)] (keys: \(newAgendaForReceiver.keys.count))")
            }
        }
    }

    // MARK: - FIRESTORE: Fetch tasks for selected receiver
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
                
                var medName: String? = nil
                var medImage: String? = nil
                
                if let medId = medicineId {
                    if let med = medicines.first(where: { $0.medicineId == medId }) {
                        medName = med.medicineName
                        medImage = med.medicineImage
                    } else {
                        print("⚠️ MedicineID \(medId) not found in medicines list")
                    }
                }
                
                let isCompleted = data["is_completed"] as? Bool ?? false

                let agenda = AgendaItem(
                    id: doc.documentID,
                    title: title,
                    description: description,
                    time: timeString,
                    date: dateKey,
                    status: UrgencyStatus(rawValue: typeString) ?? .low,
                    type: (medicineId == nil ? .activity : .medicine),
                    ownerId: caregiver?.id ?? "",
                    ownerName: caregiver?.fullName ?? "Unknown",
                    receiverId: receiver.userId,
                    receiverName: receiver.fullName,
                    medicineId: medicineId,
                    medicineName: medName,
                    medicineImage: medImage,
                    isCompleted: isCompleted
                )


                print("  → parsed task docId=\(doc.documentID) title='\(title)' date=\(dateKey) time=\(timeString) caregiverUserId=\(caregiverUserId)")
                var arr = newAgendaForReceiver[dateKey] ?? []
                arr.append(agenda)
                newAgendaForReceiver[dateKey] = arr
            }
            // Update local cache
            DispatchQueue.main.async {
                self.agendaData[receiver.userId] = newAgendaForReceiver
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
        guard let receiver = newAgendaOwner else {
            print("saveNewAgenda -> abort: newAgendaOwner is nil")
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
        let localItem = AgendaItem(
            id: UUID().uuidString,
            title: finalTitle,
            description: newAgendaDescription,
            time: timeString,
            date: dateKey,
            status: newAgendaStatus,
            type: newAgendaType,
            ownerId: caregiver.id,
            ownerName: caregiver.fullName,
            receiverId: receiver.userId,
            receiverName: receiver.fullName,
            medicineId: selectedMedicine?.medicineId,
            medicineName: selectedMedicine?.medicineName,
            medicineImage: selectedMedicine?.medicineImage,
            isCompleted: false
        )

        // Store locally under receiver
        var receiverMap = agendaData[receiver.userId] ?? [:]
        var dayList = receiverMap[dateKey] ?? []
        dayList.append(localItem)
        receiverMap[dateKey] = dayList
        agendaData[receiver.userId] = receiverMap
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


        editAgendaTitle = agenda.medicineId != nil
            ? (agenda.medicineName ?? "")
            : agenda.title.replacingOccurrences(of: "💊 ", with: "")


        isTitleEditable = agenda.medicineId == nil
        editAgendaDescription = agenda.description


        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        editAgendaTimeDate = df.date(from: agenda.time) ?? Date()


        editAgendaStatus = agenda.status
        editAgendaType = agenda.medicineId != nil ? .medicine : .activity


        // ✅ FIX: set receiver correctly
        editAgendaOwner = users.first { $0.userId == agenda.receiverId }


        selectedMedicine = agenda.medicineId == nil ? nil : Medicines(
            id: agenda.id,
            data: [
                "medicine_id": agenda.medicineId ?? 0,
                "medicine_name": agenda.medicineName ?? "",
                "medicine_image": agenda.medicineImage ?? ""
            ]
        )


        showingEditAgenda = true
    }

    func saveEditedAgenda() {
        guard let original = editAgendaOriginal else { return }
        guard let caregiver = currentCaregiver else { return }
        guard let receiver = editAgendaOwner else { return }


        if selectedPerson == nil {
            // force listener to receiver being edited
            selectedPerson = receiver
        }

        let key = dateKey(from: selectedDate)
        let f = DateFormatter(); f.dateFormat = "hh:mm a"


        let updated = AgendaItem(
            id: original.id,
            title: editAgendaType == .medicine
                ? "💊 \(selectedMedicine?.medicineName ?? "")"
                : editAgendaTitle,
            description: editAgendaDescription,
            time: f.string(from: editAgendaTimeDate),
            date: key,
            status: editAgendaStatus,
            type: editAgendaType,
            ownerId: caregiver.id,
            ownerName: caregiver.fullName,
            receiverId: receiver.userId,
            receiverName: receiver.fullName,
            medicineId: editAgendaType == .medicine ? selectedMedicine?.medicineId : nil,
            medicineName: editAgendaType == .medicine ? selectedMedicine?.medicineName : nil,
            medicineImage: editAgendaType == .medicine ? selectedMedicine?.medicineImage : nil
        )


        // 🔥 MOVE agenda between receivers
        // remove from OLD receiver
        removeAgenda(
            receiverId: original.receiverId,
            dateKey: original.date,
            agenda: original
        )



        // add to NEW receiver
        // remove from old receiver
        removeAgenda(
            receiverId: original.receiverId,
            dateKey: original.date,
            agenda: original
        )


        // add to new receiver
        var receiverMap = agendaData[receiver.userId] ?? [:]
        receiverMap[key, default: []].append(updated)
        agendaData[receiver.userId] = receiverMap



        Task {
            let docRef = db.collection(tasksCollection).document(original.id)
            try await docRef.updateData([
                "title": updated.title,
                "description": updated.description,
                "type": updated.status.rawValue,
                "due_time": Timestamp(date: combine(date: selectedDate, time: editAgendaTimeDate)),
                "careReceiver_id": receiver.userId
            ])
        }


        showingEditAgenda = false
    }


    // MARK: - Colors / Helpers
    func colorForDay(_ day: Int) -> Color {
        let key = dateKey(forDay: day, in: dateByAddingMonths(currentMonthOffset))
        var statuses: [UrgencyStatus] = []
        func appendStatus(_ p: Users) {
            if let list = agendaData[p.userId]?[key] {
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
    
    
    func fetchTasksForAllReceivers() async {
        detachTasksListener()
        print("📥 fetchTasksForAllReceivers")

        var combinedAgenda: [Int: [String: [AgendaItem]]] = [:]

        for receiver in persons {
            do {
                var query: Query = db.collection(tasksCollection)
                    .whereField("careReceiver_id", isEqualTo: receiver.userId)

                if let giver = currentCaregiver {
                    query = query.whereField("careGiver_id", isEqualTo: giver.userId)
                }

                let snapshot = try await query.getDocuments()

                for doc in snapshot.documents {
                    let data = doc.data()

                    let caregiverUserId = data["careGiver_id"] as? Int ?? 0
                    let caregiver = users.first { $0.userId == caregiverUserId }

                    let title = data["title"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let typeString = data["type"] as? String ?? UrgencyStatus.low.rawValue
                    let medicineId = data["medicine_id"] as? Int
                    let isCompleted = data["is_completed"] as? Bool ?? false

                    let dueDate = (data["due_time"] as? Timestamp)?.dateValue() ?? Date()
                    let dateKey = dateKey(from: dueDate)
                    let timeString = timeFormatter.string(from: dueDate)

                    let med = medicines.first { $0.medicineId == medicineId }

                    let agenda = AgendaItem(
                        id: doc.documentID,
                        title: title,
                        description: description,
                        time: timeString,
                        date: dateKey,
                        status: UrgencyStatus(rawValue: typeString) ?? .low,
                        type: medicineId == nil ? .activity : .medicine,
                        ownerId: caregiver?.id ?? "",
                        ownerName: caregiver?.fullName ?? "Unknown",
                        receiverId: receiver.userId,
                        receiverName: receiver.fullName,
                        medicineId: medicineId,
                        medicineName: med?.medicineName,
                        medicineImage: med?.medicineImage,
                        isCompleted: isCompleted
                    )

                    combinedAgenda[receiver.userId, default: [:]][dateKey, default: []]
                        .append(agenda)

                }
            } catch {
                print("❌ fetchTasksForAllReceivers error:", error)
            }
        }

        DispatchQueue.main.async {
            self.agendaData = combinedAgenda
            print("✅ All receivers agenda loaded")
        }
    }




}





