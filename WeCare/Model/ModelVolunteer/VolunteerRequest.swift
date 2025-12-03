//
//  VolunteerRequest.swift
//  WeCare
//
//  Created by student on 03/12/25.
//

import Foundation

struct VolunteerRequest: Identifiable {
    let id = UUID()
    let caregiverName: String
    let careReceiverName: String
    let taskDescription: String
    let distanceKm: Double
    let offeredReward: Int          // dalam rupiah
    let scheduledTime: String       // contoh: "Today, 15:30"
    let locationNote: String        // contoh: "Rumah, blok B3"
}

struct VolunteerChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromCaregiver: Bool
    let time: String
}

// MARK: - Rupiah Helper

extension Int {
    /// Format integer menjadi Rupiah, misal: 25000 -> "Rp 25.000"
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

