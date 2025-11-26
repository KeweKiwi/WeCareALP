//
//  Medicines.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore


struct Medicines: Identifiable, Hashable {


    /// Firestore document ID
    let id: String


    /// Firestore fields
    let medicineId: Int
    let medicineName: String
    let medicineImage: String


    /// Init from Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id


        self.medicineId     = data["medicine_id"] as? Int ?? 0
        self.medicineName   = data["medicine_name"] as? String ?? ""
        self.medicineImage  = data["medicine_image"] as? String ?? ""
    }
}






