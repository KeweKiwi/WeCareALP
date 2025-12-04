//
//  VolunteerModeVM.swift
//  WeCare
//
//  Created by student on 03/12/25.
//

import Foundation
import Combine
import CoreLocation

class VolunteerModeVM: ObservableObject {
    let volunteerCoordinate = CLLocationCoordinate2D(latitude: -6.200000, longitude: 106.816666)
    
    // Registration
    @Published var isRegistered: Bool = false
    @Published var profile: VolunteerProfile? = nil
    
    // Availability
    @Published var isAvailable: Bool = true
    
    // Incoming requests
    @Published var incomingRequests: [VolunteerRequest] = [
        VolunteerRequest(
            caregiverName: "Rina",
            careReceiverName: "Grandma Jacqueline",
            taskDescription: "Buy hypertension medicine at the pharmacy and deliver it to her house.",
            distanceKm: 1.2,
            offeredReward: 25000,
            scheduledTime: "Today, 3:30 PM",
            locationNote: "Melati Residence, Block C5",
            careReceiverCoordinate: CLLocationCoordinate2D(latitude: -6.210, longitude: 106.820)
        ),
        VolunteerRequest(
            caregiverName: "Andi",
            careReceiverName: "Grandpa Budi",
            taskDescription: "Buy lunch (soft rice meal) and help check his blood pressure.",
            distanceKm: 2.8,
            offeredReward: 40000,
            scheduledTime: "Today, 5:00 PM",
            locationNote: "House near Al-Hikmah Mosque",
            careReceiverCoordinate: CLLocationCoordinate2D(latitude: -6.205, longitude: 106.810)
        )
    ]
    
    // 🔹 Multiple current tasks
    @Published var currentTasks: [VolunteerRequest] = []
    
    // 🔹 History of completed tasks
    @Published var historyTasks: [CompletedVolunteerTask] = []
    
    // MARK: - Registration
    
    func registerVolunteer(name: String,
                           age: Int,
                           gender: String,
                           specialty: String,
                           restrictions: String) {
        let newProfile = VolunteerProfile(
            name: name,
            age: age,
            gender: gender,
            specialty: specialty,
            restrictions: restrictions
        )
        self.profile = newProfile
        self.isRegistered = true
    }
    
    // MARK: - Request Actions
    
    func accept(_ request: VolunteerRequest) {
        if !currentTasks.contains(where: { $0.id == request.id }) {
            currentTasks.append(request)
        }
        incomingRequests.removeAll { $0.id == request.id }
    }
    
    func decline(_ request: VolunteerRequest) {
        incomingRequests.removeAll { $0.id == request.id }
    }
    
    /// Dipanggil ketika caregiver menandai task selesai (disimulasikan dari POV volunteer).
    func markTaskCompleted(_ task: VolunteerRequest, tip: Int?, rating: Int?) {
        // Remove from current tasks
        currentTasks.removeAll { $0.id == task.id }
        
        // Add to history
        let completed = CompletedVolunteerTask(
            originalRequest: task,
            completedAt: Date(),
            tipAmount: tip,
            rating: rating
        )
        // Insert at top
        historyTasks.insert(completed, at: 0)
    }
}


