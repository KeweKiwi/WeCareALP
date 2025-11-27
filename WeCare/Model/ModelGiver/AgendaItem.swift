//
//  AgendaItem.swift
//  WeCare
//
//  Created by student on 20/11/25.
//
import Foundation

enum AgendaType: String, Codable {
    case activity = "Activity"
    case medicine = "Medicine"
}

struct AgendaItem: Identifiable, Hashable, Codable {

    var id: String                 // Firestore document ID
    var title: String
    var description: String
    var time: String               // "08:00 AM"
    var date: String               // "2025-11-12"
    var status: UrgencyStatus
    var type: AgendaType
    var ownerId: String            // Firestore user ID
    var ownerName: String          // For UI display only
    var medicineId: Int?
    var medicineName: String?
    var medicineImage: String?

    init(
        id: String,
        title: String,
        description: String,
        time: String,
        date: String,
        status: UrgencyStatus,
        type: AgendaType,
        ownerId: String,
        ownerName: String,
        medicineId: Int? = nil,
        medicineName: String? = nil,
        medicineImage: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.time = time
        self.date = date
        self.status = status
        self.type = type
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.medicineId = medicineId
        self.medicineName = medicineName
        self.medicineImage = medicineImage
    }
}

