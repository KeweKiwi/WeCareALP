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
    
    // ALERT for adding agenda in the past
    @Published var showPastDateAlert = false
    private var confirmSavePastAgenda = false

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
        let calendar = Calendar.current
        let now = Date()

        let startOfToday = calendar.startOfDay(for: now)
        let startOfAgendaDay = calendar.startOfDay(for: selectedDate)

        // 1. If full day is in the past
        if startOfAgendaDay < startOfToday && !confirmSavePastAgenda {
            showPastDateAlert = true
            return
        }

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
            ownerId: owner.id,
            ownerName: owner.fullName,
            medicineId: newAgendaType == .medicine ? selectedMedicine?.medicineId : nil,
            medicineName: newAgendaType == .medicine ? selectedMedicine?.medicineName : nil,
            medicineImage: newAgendaType == .medicine ? selectedMedicine?.medicineImage : nil
        )

        var ownerAgenda = agendaData[owner.fullName] ?? [:]
        var dayList = ownerAgenda[dateKey] ?? []
        dayList.append(newItem)
        ownerAgenda[dateKey] = dayList
        agendaData[owner.fullName] = ownerAgenda

        // Reset fields & state
        confirmSavePastAgenda = false
        resetNewAgendaFields()
    }
    
    func confirmSavingPastAgenda() {
        confirmSavePastAgenda = true
        showPastDateAlert = false
        saveNewAgenda()
    }


    func resetNewAgendaFields() {
        newAgendaTitle = ""
        newAgendaDescription = ""
        newAgendaOwner = nil
        newAgendaStatus = .low
        newAgendaTimeDate = Date()
        newAgendaType = .activity
        selectedMedicine = nil
        newAgendaMedicine = nil
    }

    // MARK: - EDITING

    func startEditing(_ agenda: AgendaItem) {
        editAgendaOriginal = agenda
        
        // If editing medicine agenda → use medicineName as the title
        if agenda.medicineName != nil {
            editAgendaTitle = agenda.medicineName ?? ""
        } else {
            // activity
            if agenda.title.starts(with: "💊 ") {
                editAgendaTitle = String(agenda.title.dropFirst(2))
            } else {
                editAgendaTitle = agenda.title
            }
        }

        editAgendaDescription = agenda.description

        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        editAgendaTimeDate = f.date(from: agenda.time) ?? Date()

        editAgendaStatus = agenda.status
        editAgendaOwner = persons.first { $0.fullName == agenda.ownerName }

        // FIX: detect type correctly
        editAgendaType = agenda.medicineId != nil ? .medicine : .activity

        // FIX: restore medicine selection
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
        guard let original = editAgendaOriginal else { return }
        guard let owner = editAgendaOwner else { return }
        
        let key = dateKey(from: selectedDate)

        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        let timeString = f.string(from: editAgendaTimeDate)

        let updatedItem = AgendaItem(
            id: original.id,
            title: editAgendaType == .medicine ?
                    "💊 \(selectedMedicine?.medicineName ?? "")"
                    : editAgendaTitle,
            description: editAgendaDescription,
            time: timeString,
            date: key,
            status: editAgendaStatus,
            type: editAgendaType,
            ownerId: owner.id,
            ownerName: owner.fullName,
            medicineId: editAgendaType == .medicine ? selectedMedicine?.medicineId : nil,
            medicineName: editAgendaType == .medicine ? selectedMedicine?.medicineName : nil,
            medicineImage: editAgendaType == .medicine ? selectedMedicine?.medicineImage : nil
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
