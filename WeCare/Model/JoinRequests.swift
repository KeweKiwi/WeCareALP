//
//  JoinRequests.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore


struct JoinRequests: Identifiable, Hashable {


    /// Firestore document ID
    let id: String


    /// Firestore fields
    let requestId: Int
    let familyId: Int
    let userId: Int
    let status: String
    let requestedAt: Date?


    /// Init from Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id


        self.requestId  = data["request_id"] as? Int ?? 0
        self.familyId   = data["family_id"] as? Int ?? 0
        self.userId     = data["user_id"] as? Int ?? 0
        self.status     = data["status"] as? String ?? ""


        if let ts = data["requested_at"] as? Timestamp {
            self.requestedAt = ts.dateValue()
        } else {
            self.requestedAt = nil
        }
    }
}





