//
//  ChatMessage.swift
//  WeCare
//
//  Created by student on 24/11/25.
//

import Foundation

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromVolunteer: Bool
    let time: String
}
