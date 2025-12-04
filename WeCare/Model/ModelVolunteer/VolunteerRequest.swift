//
//  VolunteerRequest.swift
//  WeCare
//
//  Created by student on 03/12/25.
//

import Foundation
import CoreLocation   // ⬅️ tambahkan ini

struct VolunteerRequest: Identifiable {
    let id = UUID()
    let caregiverName: String
    let careReceiverName: String
    let taskDescription: String
    let distanceKm: Double
    let offeredReward: Int
    let scheduledTime: String
    let locationNote: String
    
    // ⬅️ NEW: coordinate of care receiver
    let careReceiverCoordinate: CLLocationCoordinate2D
}


// NEW: completed task model
struct CompletedVolunteerTask: Identifiable {
    let id = UUID()
    let originalRequest: VolunteerRequest
    let completedAt: Date
    let tipAmount: Int?    // tip from caregiver, in rupiah
    let rating: Int?       // 1–5 stars
}

struct VolunteerChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCaregiver: Bool
    let time: String
}

// Rupiah helper (sudah ada sebelumnya, ulang kalau perlu)
extension Int {
    func asRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: self)) ?? "Rp \(self)"
    }
}



