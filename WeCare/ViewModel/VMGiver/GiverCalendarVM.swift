//
//  GiverCalendarVM.swift
//  WeCare
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore


@MainActor
final class GiverCalendarVM: ObservableObject {

    // USERS
    @Published var users: [Users] = []
    @Published var selectedUser: Users? = nil

    // UI STATE
    @Published var selectedDate: Date = Date()
    @Published var currentMonthOffset = 0
    @Published var selectedPerson: Users? = nil

    // ADD-AGENDA SHEET
    @Published var showingAddAgenda = false
    @Published var newAgendaTitle = ""
    @Published var newAgendaDescription = ""
    @Published var newAgendaOwner: Users? = nil
    @Published var newAgendaStatus: UrgencyStatus = .low
    @Published var newAgendaTimeDate = Date()
    @Published var newAgendaType: AgendaType = .activity
    @Published var selectedMedicine: Medicines? = nil
    @Published var newAgendaMedicine: Medicines? = nil

    // DETAIL
    @Published var selectedAgenda: AgendaItem? = nil
    @Published var showingAgendaDetail = false

    // EDIT AGENDA
    @Published var showingEditAgenda = false
    @Published var editAgendaOriginal: AgendaItem? = nil
    @Published var editAgendaTitle = ""
    @Published var editAgendaDescription = ""
    @Published var editAgendaTimeDate = Date()
    @Published var editAgendaStatus: UrgencyStatus = .low
    @Published var editAgendaOwner: Users? = nil
    @Published var editAgendaType: AgendaType = .activity

    // MARK: - DATA

    /// Replace your previous dummy list
    @Published var persons: [Users] = []

    // health data (placeholder until linked to firebase)
    let healthData: [String: [Int: UrgencyStatus]] = [:]

    // agendaData[fullName][date] -> [AgendaItem]
    @Published var agendaData: [String: [String: [AgendaItem]]] = [:]

    func updateUsers(_ newUsers: [Users]) {
        self.users = newUsers
        self.persons = newUsers
    }

//    // MARK: INIT
//    init() {
//        loadDummyUsers()
//        seedDemoAgenda()
//    }

//    func loadDummyUsers() {
//        persons = [
//            Users(id: "1", data: [
//                "user_id": 11,
//                "family_id": 1,
//                "full_name": "Nenek Siti",
//                "email": "",
//                "phone_number": "",
//                "password": "",
//                "role": "Grandmother",
//                "gender": "Female",
//                "is_admin": false,
//                "profile_image_url": "",
//            ]),
//            Users(id: "2", data: [
//                "user_id": 22,
//                "family_id": 1,
//                "full_name": "Kakek Budi",
//                "email": "",
//                "phone_number": "",
//                "password": "",
//                "role": "Grandfather",
//                "gender": "Male",
//                "is_admin": false,
//                "profile_image_url": "",
//            ])
//        ]
//    }
//
//    func seedDemoAgenda() {
//        agendaData = [
//            "Nenek Siti": [
//                "2025-11-13": [
//                    .init(
//                        title: "Check blood pressure",
//                        description: "Bring BP meter",
//                        time: "08:00 AM",
//                        status: .low,
//                        owner: "Nenek Siti"
//                    )
//                ]
//            ],
//            "Kakek Budi": [
//                "2025-11-03": [
//                    .init(
//                        title: "Leg therapy",
//                        description: "Clinic physio session",
//                        time: "09:00 AM",
//                        status: .high,
//                        owner: "Kakek Budi"
//                    )
//                ]
//            ]
//        ]
//    }

    // MARK: - COMPUTED PROPERTIES

    var currentDate: Date {
        Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
    }

    var currentMonthName: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: currentDate)
    }

    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
    }

    var currentAgenda: [AgendaItem] {
        let key = dateKey(from: selectedDate)

        if let person = selectedPerson {
            return agendaData[person.fullName]?[key] ?? []
        }

        return persons.flatMap { agendaData[$0.fullName]?[key] ?? [] }
    }

    // MARK: - DELETE AGENDA

    func deleteAgenda(_ agenda: AgendaItem) {
        let key = dateKey(from: selectedDate)

        if let person = selectedPerson {
            removeAgenda(ownerName: person.fullName, dateKey: key, agenda: agenda)
            return
        }

        for person in persons {
            if removeAgenda(ownerName: person.fullName, dateKey: key, agenda: agenda) {
                break
            }
        }
    }

    @discardableResult
    private func removeAgenda(ownerName: String, dateKey: String, agenda: AgendaItem) -> Bool {
        var personAgendas = agendaData[ownerName] ?? [:]
        var agendasForDay = personAgendas[dateKey] ?? []

        let before = agendasForDay.count
        agendasForDay.removeAll { $0.id == agenda.id }

        if before != agendasForDay.count {
            personAgendas[dateKey] = agendasForDay.isEmpty ? nil : agendasForDay
            agendaData[ownerName] = personAgendas
            return true
        }
        return false
    }


    // MARK: - NEW AGENDA

    func saveNewAgenda() {
        guard let owner = newAgendaOwner else { return }

        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        let timeString = f.string(from: newAgendaTimeDate)

        let finalTitle: String =
            newAgendaType == .medicine ? "💊 \(newAgendaTitle)" : newAgendaTitle

        let dateKey = dateKey(from: selectedDate)

        let newItem = AgendaItem(
            id: UUID().uuidString,
            title: finalTitle,
            description: newAgendaDescription,
            time: timeString,
            date: dateKey,
            status: newAgendaStatus,
            type: newAgendaType,
            ownerId: owner.id,              // Firestore user doc ID
            ownerName: owner.fullName,
            medicineId: selectedMedicine?.medicineId,
            medicineName: selectedMedicine?.medicineName,
            medicineImage: selectedMedicine?.medicineImage
        )

        var ownerAgenda = agendaData[owner.fullName] ?? [:]
        var dayList = ownerAgenda[dateKey] ?? []
        dayList.append(newItem)
        ownerAgenda[dateKey] = dayList
        agendaData[owner.fullName] = ownerAgenda

        resetNewAgendaFields()
    }

    func resetNewAgendaFields() {
        newAgendaTitle = ""
        newAgendaDescription = ""
        newAgendaOwner = nil
        newAgendaStatus = .low
        newAgendaTimeDate = Date()
        newAgendaType = .activity
    }

    // MARK: - EDITING

    func startEditing(_ agenda: AgendaItem) {
        editAgendaOriginal = agenda
        editAgendaTitle = agenda.title
        editAgendaDescription = agenda.description

        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        editAgendaTimeDate = f.date(from: agenda.time) ?? Date()

        editAgendaStatus = agenda.status
        editAgendaOwner = persons.first { $0.fullName == agenda.ownerName }

        // Attempt detect type
        editAgendaType = agenda.title.starts(with: "💊") ? .medicine : .activity

        showingEditAgenda = true
    }

    func saveEditedAgenda() {
        guard let original = editAgendaOriginal else { return }
        guard let owner = editAgendaOwner else { return }

        let key = dateKey(from: selectedDate)

        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        let timeString = f.string(from: editAgendaTimeDate)

        let updatedItem = AgendaItem(
            id: original.id,
            title: editAgendaType == .medicine ? "💊 \(editAgendaTitle)" : editAgendaTitle,
            description: editAgendaDescription,
            time: timeString,
            date: key,
            status: editAgendaStatus,
            type: editAgendaType,
            ownerId: owner.id,
            ownerName: owner.fullName,
            medicineId: selectedMedicine?.medicineId,
            medicineName: selectedMedicine?.medicineName,
            medicineImage: selectedMedicine?.medicineImage
        )

        // Remove old agenda
        for person in persons {
            if removeAgenda(ownerName: person.fullName, dateKey: key, agenda: original) {
                break
            }
        }

        // Insert new
        var ownerAgenda = agendaData[owner.fullName] ?? [:]
        var dayList = ownerAgenda[key] ?? []
        dayList.append(updatedItem)
        ownerAgenda[key] = dayList
        agendaData[owner.fullName] = ownerAgenda

        showingEditAgenda = false
    }

    // MARK: - COLORS

    func colorForDay(_ day: Int) -> Color {
        let key = dateKey(forDay: day, in: currentDate)
        var statuses: [UrgencyStatus] = []

        func add(for person: Users) {
            if let agendas = agendaData[person.fullName]?[key] {
                statuses.append(contentsOf: agendas.map { $0.status })
            }
        }

        if let selected = selectedPerson {
            add(for: selected)
        } else {
            persons.forEach(add)
        }

        if statuses.contains(.critical) { return Color.red.opacity(0.8) }
        if statuses.contains(.high) { return Color.yellow.opacity(0.7) }
        if statuses.contains(.medium) { return Color.blue.opacity(0.7) }
        if statuses.contains(.low) { return Color.green.opacity(0.7) }

        return Color.gray.opacity(0.15)
    }


    // MARK: HELPERS

    func dateKey(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func dateKey(forDay day: Int, in base: Date) -> String {
        var comps = Calendar.current.dateComponents([.year, .month], from: base)
        comps.day = day
        return dateKey(from: Calendar.current.date(from: comps) ?? base)
    }
    
    func dateForDay(_ day: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month], from: currentDate)
        comps.day = day
        return Calendar.current.date(from: comps) ?? currentDate
    }

}
