//
//  HealthVitals.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore


struct HealthVitals: Identifiable, Hashable {


    /// Firestore document ID
    let id: String


    /// Firestore fields
    let vitalId: Int
    let userId: Int
    let heartRate: Int
    let sleepDurationHours: Int
    let steps: Int
    let temperature: Double
    let timestamp: Date?


    /// Init from Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id


        self.vitalId             = data["vital_id"] as? Int ?? 0
        self.userId              = data["user_id"] as? Int ?? 0
        self.heartRate           = data["heart_rate"] as? Int ?? 0
        self.sleepDurationHours  = data["sleep_duration_hours"] as? Int ?? 0
        self.steps               = data["steps"] as? Int ?? 0
        self.temperature         = data["temperature"] as? Double ?? 0.0


        if let ts = data["timestamp"] as? Timestamp {
            self.timestamp = ts.dateValue()
        } else {
            self.timestamp = nil
        }
    }
}






