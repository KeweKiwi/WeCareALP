//
//  VolunteerModeVM.swift
//  WeCare
//
//  Created by student on 03/12/25.
//

import Foundation
import Combine

class VolunteerModeVM: ObservableObject {
    @Published var isAvailable: Bool = true
    
    @Published var incomingRequests: [VolunteerRequest] = [
        VolunteerRequest(
            caregiverName: "Rina",
            careReceiverName: "Mrs. Sari",
            taskDescription: "Buy hypertension medicine at the pharmacy and deliver it to her house.",
            distanceKm: 1.2,
            offeredReward: 25000,
            scheduledTime: "Today, 3:30 PM",
            locationNote: "Melati Residence, Block C5"
        ),
        VolunteerRequest(
            caregiverName: "Andi",
            careReceiverName: "Grandpa Budi",
            taskDescription: "Buy lunch (soft rice meal) and help check his blood pressure.",
            distanceKm: 2.8,
            offeredReward: 40000,
            scheduledTime: "Today, 5:00 PM",
            locationNote: "House near Al-Hikmah Mosque"
        )
    ]
    
    @Published var activeTask: VolunteerRequest? = nil
    
    // MARK: - Actions
    
    func accept(_ request: VolunteerRequest) {
        activeTask = request
        incomingRequests.removeAll { $0.id == request.id }
    }
    
    func decline(_ request: VolunteerRequest) {
        incomingRequests.removeAll { $0.id == request.id }
    }
    
    func completeActiveTask() {
        activeTask = nil
    }
}
