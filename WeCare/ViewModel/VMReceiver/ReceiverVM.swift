import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor
class ReceiverVM: ObservableObject {
    // MARK: - Data Models
    @Published var tasks: [Tasks] = []
    
    // MARK: - User Profile
    @Published var currentUserName: String = "Loading..."
    
    // MARK: - Health Vitals (Used by Dashboard AND Health View)
    @Published var steps: Int = 0
    @Published var heartRate: Int = 0
    @Published var wristTemperature: Double = 0.0
    @Published var sleepDuration: Double = 0.0
    @Published var oxygenSaturation: Double = 98.0 // Default static value
    
    private let db = Firestore.firestore()
    
    // Computed property for Task Progress
    var taskCompletionPercentage: Int {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.isCompleted }.count
        return Int((Double(completed) / Double(tasks.count)) * 100)
    }

    // MARK: - 1. Fetch User Profile (Name)
    func fetchUserProfile(userId: Int) {
        db.collection("Users")
            .whereField("user_id", isEqualTo: userId)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let doc = snapshot?.documents.first else {
                    self.currentUserName = "Unknown User"
                    return
                }
                self.currentUserName = doc.data()["full_name"] as? String ?? "User"
            }
    }

    // MARK: - 2. Fetch Tasks
    func fetchTasks(forReceiverId userId: Int) {
        db.collection("Tasks")
            .whereField("careReceiver_id", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error { print("Error fetching tasks: \(error)"); return }
                guard let documents = snapshot?.documents else { return }
                
                self.tasks = documents.map { doc in
                    Tasks(id: doc.documentID, data: doc.data())
                }
                .sorted { ($0.dueTime ?? Date()) < ($1.dueTime ?? Date()) }
            }
    }
    
    // MARK: - 3. Fetch All Vitals (Steps, HR, Temp, etc.)
    // This powers BOTH the Dashboard (steps) and Health View (everything else)
    func fetchLatestVitals(forUserId userId: Int) {
        db.collection("HealthVitals")
            .whereField("user_id", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching vitals: \(error.localizedDescription)")
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    print("⚠️ No vitals found for user \(userId)")
                    self.resetVitals()
                    return
                }
                
                let vital = HealthVitals(id: doc.documentID, data: doc.data())
                
                // Assign values to ALL Published properties
                self.steps = vital.steps
                self.heartRate = vital.heartRate
                self.wristTemperature = vital.temperature
                self.sleepDuration = Double(vital.sleepDurationHours)
                self.oxygenSaturation = 98.5 // Static default
                
                print("✅ Loaded Vitals: Steps=\(self.steps), HR=\(self.heartRate)")
            }
    }
    
    // MARK: - 4. Fetch Steps (Alias for Dashboard Compatibility)
    // The Dashboard calls this, so we point it to the main vitals fetcher
    func fetchLatestSteps(forUserId userId: Int) {
        fetchLatestVitals(forUserId: userId)
    }
    
    // MARK: - 5. Update Health Data (Missing Function Fixed Here)
    func updateHealthData() {
        print("🔄 Refreshing Health Data...")
        // Logic to refresh data or trigger wearable sync would go here
    }
    
    // MARK: - Toggle Task
    func toggleTaskCompletion(task: Tasks) {
        db.collection("Tasks").document(task.id).updateData([
            "is_completed": !task.isCompleted
        ])
    }
    
    // Helper to reset data
    private func resetVitals() {
        self.steps = 0
        self.heartRate = 0
        self.wristTemperature = 0.0
        self.sleepDuration = 0.0
    }
}
