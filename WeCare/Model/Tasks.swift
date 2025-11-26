//
//  Tasks.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore


struct Tasks: Identifiable, Hashable {


    /// Firestore document ID
    let id: String


    /// Firestore fields
    let taskId: Int
    let careGiverId: Int
    let careReceiverId: Int
    let medicineId: Int
    let title: String
    let description: String
    let type: String
    let isCompleted: Bool
    let createdAt: Date?
    let dueTime: Date?


    /// Init from Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id


        self.taskId         = data["task_id"] as? Int ?? 0
        self.careGiverId    = data["careGiver_id"] as? Int ?? 0
        self.careReceiverId = data["careReceiver_id"] as? Int ?? 0
        self.medicineId     = data["medicine_id"] as? Int ?? 0


        self.title          = data["title"] as? String ?? ""
        self.description    = data["description"] as? String ?? ""
        self.type           = data["type"] as? String ?? ""
        self.isCompleted    = data["is_completed"] as? Bool ?? false


        // Convert Firestore timestamps → Date
        if let ts = data["created_at"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }


        if let ts = data["due_time"] as? Timestamp {
            self.dueTime = ts.dateValue()
        } else {
            self.dueTime = nil
        }
    }
}






