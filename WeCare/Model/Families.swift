//
//  Families.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore


struct Families: Identifiable, Hashable {


    /// Firestore document ID
    let id: String


    /// Firestore fields
    let familyId: Int
    let familyName: String
    let familyCode: String
    let createdAt: Date?


    /// Init from Firestore document
    init(id: String, data: [String : Any]) {
        self.id = id


        self.familyId   = data["family_id"] as? Int ?? 0
        self.familyName = data["family_name"] as? String ?? ""
        self.familyCode = data["family_code"] as? String ?? ""


        if let ts = data["created_at"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }
    }
}






