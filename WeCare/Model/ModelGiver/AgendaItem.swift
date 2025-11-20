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

    var id: String { rawValue }
}

struct AgendaItem: Identifiable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var time: String
    var status: UrgencyStatus
    var owner: String
    var type: AgendaType     // ← ADD THIS

    // Custom initializer (Fixes your error)
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        time: String,
        status: UrgencyStatus,
        owner: String,
        type: AgendaType = .activity   // ← ADD THIS

    ) {
        self.id = id
        self.title = title
        self.description = description
        self.time = time
        self.status = status
        self.owner = owner
        self.type = type
    }
}

