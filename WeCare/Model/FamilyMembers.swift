//
//  FamilyMembers.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore


struct FamilyMembers: Identifiable, Hashable {


    /// Firestore document ID
    let id: String


    /// Firestore fields
    let membershipId: Int
    let familyId: Int
    let userId: Int
    let isAdmin: Bool
    let joinedAt: Date?


    /// Init from Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id


        self.membershipId = data["membership_id"] as? Int ?? 0
        self.familyId     = data["family_id"] as? Int ?? 0
        self.userId       = data["user_id"] as? Int ?? 0
        self.isAdmin      = data["is_admin"] as? Bool ?? false


        if let ts = data["joined_at"] as? Timestamp {
            self.joinedAt = ts.dateValue()
        } else {
            self.joinedAt = nil
        }
    }
}






