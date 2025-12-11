//import Foundation
//import FirebaseFirestore
//import SwiftUI
//import Combine
//
//@MainActor
//class ReceiverVM: ObservableObject {
//    // MARK: - Data Models
//    @Published var tasks: [Tasks] = []
//    
//    // MARK: - User Profile
//    @Published var currentUserName: String = "Loading..."
//    
//    // MARK: - Health Vitals (Used by Dashboard AND Health View)
//    @Published var steps: Int = 0
//    @Published var heartRate: Int = 0
//    @Published var wristTemperature: Double = 0.0
//    @Published var sleepDuration: Double = 0.0
//    @Published var oxygenSaturation: Double = 98.0 // Default static value
//    
//    private let db = Firestore.firestore()
//    
//    // Computed property for Task Progress
//    var taskCompletionPercentage: Int {
//        guard !tasks.isEmpty else { return 0 }
//        let completed = tasks.filter { $0.isCompleted }.count
//        return Int((Double(completed) / Double(tasks.count)) * 100)
//    }
//
//    // MARK: - 1. Fetch User Profile (Name)
//    func fetchUserProfile(userId: Int) {
//        db.collection("Users")
//            .whereField("user_id", isEqualTo: userId)
//            .limit(to: 1)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//                guard let doc = snapshot?.documents.first else {
//                    self.currentUserName = "Unknown User"
//                    return
//                }
//                self.currentUserName = doc.data()["full_name"] as? String ?? "User"
//            }
//    }
//
//    // MARK: - 2. Fetch Tasks
//    func fetchTasks(forReceiverId userId: Int) {
//        db.collection("Tasks")
//            .whereField("careReceiver_id", isEqualTo: userId)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//                if let error = error { print("Error fetching tasks: \(error)"); return }
//                guard let documents = snapshot?.documents else { return }
//                
//                self.tasks = documents.map { doc in
//                    Tasks(id: doc.documentID, data: doc.data())
//                }
//                .sorted { ($0.dueTime ?? Date()) < ($1.dueTime ?? Date()) }
//            }
//    }
//    
//    // MARK: - 3. Fetch All Vitals (Steps, HR, Temp, etc.)
//    // This powers BOTH the Dashboard (steps) and Health View (everything else)
//    func fetchLatestVitals(forUserId userId: Int) {
//        db.collection("HealthVitals")
//            .whereField("user_id", isEqualTo: userId)
//            .order(by: "timestamp", descending: true)
//            .limit(to: 1)
//            .addSnapshotListener { [weak self] snapshot, error in
//                guard let self = self else { return }
//                
//                if let error = error {
//                    print("Error fetching vitals: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let doc = snapshot?.documents.first else {
//                    print("⚠️ No vitals found for user \(userId)")
//                    self.resetVitals()
//                    return
//                }
//                
//                let vital = HealthVitals(id: doc.documentID, data: doc.data())
//                
//                // Assign values to ALL Published properties
//                self.steps = vital.steps
//                self.heartRate = vital.heartRate
//                self.wristTemperature = vital.temperature
//                self.sleepDuration = Double(vital.sleepDurationHours)
//                self.oxygenSaturation = 98.5 // Static default
//                
//                print("✅ Loaded Vitals: Steps=\(self.steps), HR=\(self.heartRate)")
//            }
//    }
//    
//    // MARK: - 4. Fetch Steps (Alias for Dashboard Compatibility)
//    // The Dashboard calls this, so we point it to the main vitals fetcher
//    func fetchLatestSteps(forUserId userId: Int) {
//        fetchLatestVitals(forUserId: userId)
//    }
//    
//    // MARK: - 5. Update Health Data (Missing Function Fixed Here)
//    func updateHealthData() {
//        print("🔄 Refreshing Health Data...")
//        // Logic to refresh data or trigger wearable sync would go here
//    }
//    
//    // MARK: - Toggle Task
//    func toggleTaskCompletion(task: Tasks) {
//        db.collection("Tasks").document(task.id).updateData([
//            "is_completed": !task.isCompleted
//        ])
//    }
//    
//    // Helper to reset data
//    private func resetVitals() {
//        self.steps = 0
//        self.heartRate = 0
//        self.wristTemperature = 0.0
//        self.sleepDuration = 0.0
//    }
//}


// VERSI NON DATABASE BISA REFRESH
//import Combine
//import Foundation
//import SwiftUI
//// MARK: - ViewModel
//class ReceiverVM: ObservableObject {
//    
//    // Vital Health Data (Diperbarui untuk Apple Watch)
//    @Published var heartRate: Int = 78
//    @Published var oxygenSaturation: Double = 98.5
//    @Published var steps: Int = 5230
//    @Published var wristTemperature: Double = 36.8 // Dalam Celsius
//    @Published var sleepDuration: Double = 7.2 // Dalam Jam
//    
//    // --- Properti Tekanan Darah Dihapus ---
//    // @Published var systolicPressure: Int = 125
//    // @Published var diastolicPressure: Int = 80
//    
//    // Daily Task / Reminder Data
//    @Published var tasks: [TaskItem] = [
//        TaskItem(time: "07:00", title: "Take Morning Medicine", isCompleted: false),
//        TaskItem(time: "09:00", title: "Morning Walk (10 mins)", isCompleted: false),
//        TaskItem(time: "13:00", title: "Take Noon Medicine", isCompleted: false),
//        TaskItem(time: "19:00", title: "Take Evening Medicine", isCompleted: false)
//    ]
//    
//    // Computed Property: Task Completion Percentage
//    var taskCompletionPercentage: Int {
//        let completedCount = tasks.filter { $0.isCompleted }.count
//        let totalCount = tasks.count
//        return totalCount > 0 ? (completedCount * 100) / totalCount : 0
//    }
//    
//    // --- bloodPressureStatus Dihapus ---
//    // var bloodPressureStatus: (String, Color) { ... }
//    
//    // BARU: Computed Property untuk Kualitas Tidur
//    var sleepStatus: (String, Color) {
//        if sleepDuration >= 7.0 {
//            return ("Good", Color(hex: "#a6d17d"))
//        } else if sleepDuration >= 6.0 {
//            return ("Okay", Color(hex: "#fdcb46"))
//        } else {
//            return ("Poor", Color(hex: "#fa6255"))
//        }
//    }
//    
//    // Function: Update Health Data (Simulasi Diperbarui)
//    func updateHealthData() {
//        heartRate = Int.random(in: 70...90)
//        oxygenSaturation = Double.random(in: 95.0...100.0)
//        steps = Int.random(in: 3000...8000)
//        wristTemperature = Double.random(in: 36.1...37.2)
//        sleepDuration = Double.random(in: 6.0...8.5)
//    }
//    
//    // Function: Toggle Task Completion
//    func toggleTaskCompletion(for taskID: UUID) {
//        if let index = tasks.firstIndex(where: { $0.id == taskID }) {
//            tasks[index].isCompleted.toggle()
//        }
//    }
//}


//
//// ini yg no database
//import SwiftUI
//import Foundation
//import Combine
//import FirebaseFirestore
//
//enum ReceiverMode {
//    case firestore
//    case local
//}
//
//@MainActor
//class ReceiverVM: ObservableObject {
//    
//    // Mode
//    let mode: ReceiverMode
//    
//    // Firestore reference
//    private let db = Firestore.firestore()
//    
//    // MARK: - Published Variables (Shared)
//    @Published var currentUserName: String = "Loading..."
//    
//    @Published var steps: Int = 0
//    @Published var heartRate: Int = 80
//    @Published var wristTemperature: Double = 36.7
//    @Published var sleepDuration: Double = 7.0
//    @Published var oxygenSaturation: Double = 98.0
//    
//    // Firestore Task Model
//    @Published var tasks: [Tasks] = []
//    
//    // Local Task Model
//    @Published var localTasks: [TaskItem] = []
//    
//    // MARK: - INIT
//    init(mode: ReceiverMode) {
//        self.mode = mode
//        
//        if mode == .local {
//            self.localTasks = [
//                TaskItem(time: "07:00", title: "Take Morning Medicine", isCompleted: false),
//                TaskItem(time: "09:00", title: "Morning Walk", isCompleted: false),
//                TaskItem(time: "13:00", title: "Take Noon Medicine", isCompleted: false),
//                TaskItem(time: "19:00", title: "Take Evening Medicine", isCompleted: false)
//            ]
//        }
//    }
//    
//    // MARK: - Computed Task Percentage
//    var taskCompletionPercentage: Int {
//        switch mode {
//        case .firestore:
//            guard !tasks.isEmpty else { return 0 }
//            return (tasks.filter { $0.isCompleted }.count * 100) / tasks.count
//            
//        case .local:
//            guard !localTasks.isEmpty else { return 0 }
//            return (localTasks.filter { $0.isCompleted }.count * 100) / localTasks.count
//        }
//    }
//    
//    // MARK: - FIRESTORE FUNCTIONS ONLY FOR DASHBOARD
//    func fetchUserProfile(userId: Int) {
//        guard mode == .firestore else { return }
//        
//        db.collection("Users")
//            .whereField("user_id", isEqualTo: userId)
//            .limit(to: 1)
//            .addSnapshotListener { [weak self] snap, err in
//                guard let self = self else { return }
//                guard let doc = snap?.documents.first else {
//                    self.currentUserName = "Unknown User"
//                    return
//                }
//                
//                self.currentUserName = doc["full_name"] as? String ?? "User"
//            }
//    }
//    
//    func fetchTasks(forReceiverId id: Int) {
//        guard mode == .firestore else { return }
//        
//        db.collection("Tasks")
//            .whereField("careReceiver_id", isEqualTo: id)
//            .addSnapshotListener { [weak self] snap, err in
//                guard let self = self else { return }
//                if let docs = snap?.documents {
//                    self.tasks = docs.map { Tasks(id: $0.documentID, data: $0.data()) }
//                }
//            }
//    }
//    
//    func fetchLatestVitals(forUserId id: Int) {
//        guard mode == .firestore else { return }
//        
//        db.collection("HealthVitals")
//            .whereField("user_id", isEqualTo: id)
//            .order(by: "timestamp", descending: true)
//            .limit(to: 1)
//            .addSnapshotListener { [weak self] snap, err in
//                guard let self = self else { return }
//                guard let doc = snap?.documents.first else { return }
//                
//                let vital = doc.data()
//                self.steps = vital["steps"] as? Int ?? 0
//                self.heartRate = vital["heartRate"] as? Int ?? 80
//                self.wristTemperature = vital["temperature"] as? Double ?? 36.7
//                self.sleepDuration = vital["sleepHours"] as? Double ?? 7.0
//            }
//    }
//    
//    func toggleFirestoreTask(_ task: Tasks) {
//        guard mode == .firestore else { return }
//        
//        db.collection("Tasks").document(task.id).updateData([
//            "is_completed": !task.isCompleted
//        ])
//    }
//    
//    // MARK: - LOCAL MODE: USED BY HEALTH VIEW
//    func updateHealthData() {
//        guard mode == .local else { return }
//        
//        heartRate = Int.random(in: 72...95)
//        oxygenSaturation = Double.random(in: 96.0...100.0)
//        steps = Int.random(in: 3000...9000)
//        wristTemperature = Double.random(in: 36.3...37.4)
//        sleepDuration = Double.random(in: 6.0...8.5)
//    }
//    
//    func toggleLocalTask(_ id: UUID) {
//        if let index = localTasks.firstIndex(where: { $0.id == id }) {
//            localTasks[index].isCompleted.toggle()
//        }
//    }
//}

// ini yg hybrid (dashboard firebase, healthview prototype)
import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
class ReceiverVM: ObservableObject {
    // MARK: - Data Models
    @Published var tasks: [Tasks] = []
    
    // MARK: - User Profile
    @Published var currentUserName: String = "Loading..."
    
    // MARK: - Health Vitals (dipakai Dashboard & Health View)
    @Published var steps: Int = 0
    @Published var heartRate: Int = 0
    @Published var wristTemperature: Double = 0.0
    @Published var sleepDuration: Double = 0.0
    @Published var oxygenSaturation: Double = 98.5 // default
    
    private let db = Firestore.firestore()
    
    // Computed property untuk Task Progress (dipakai Dashboard)
    var taskCompletionPercentage: Int {
        guard !tasks.isEmpty else { return 0 }
        let completed = tasks.filter { $0.isCompleted }.count
        return Int((Double(completed) / Double(tasks.count)) * 100)
    }
    
    // OPTIONAL: Status tidur (kalau mau dipakai di UI lain)
    var sleepStatus: (String, Color) {
        if sleepDuration >= 7.0 {
            return ("Good", Color(hex: "#a6d17d"))
        } else if sleepDuration >= 6.0 {
            return ("Okay", Color(hex: "#fdcb46"))
        } else {
            return ("Poor", Color(hex: "#fa6255"))
        }
    }
    
    // MARK: - 1. Fetch User Profile (Name) → Firestore (Dashboard)
    func fetchUserProfile(userId: Int) {
        db.collection("Users")
            .whereField("user_id", isEqualTo: userId)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching user profile: \(error.localizedDescription)")
                    self.currentUserName = "Unknown User"
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    self.currentUserName = "Unknown User"
                    return
                }
                
                self.currentUserName = doc.data()["full_name"] as? String ?? "User"
            }
    }
    
    // MARK: - 2. Fetch Tasks → Firestore (Dashboard)
    func fetchTasks(forReceiverId userId: Int) {
        db.collection("Tasks")
            .whereField("careReceiver_id", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                self.tasks = documents.map { doc in
                    Tasks(id: doc.documentID, data: doc.data())
                }
                .sorted { ($0.dueTime ?? Date()) < ($1.dueTime ?? Date()) }
            }
    }
    
    // MARK: - 3. Fetch All Vitals dari Firestore (kalau koleksi HealthVitals sudah ada)
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
                
                self.steps = vital.steps
                self.heartRate = vital.heartRate
                self.wristTemperature = vital.temperature
                self.sleepDuration = Double(vital.sleepDurationHours)
                self.oxygenSaturation = 98.5 // atau dari Firestore kalau mau
            }
    }
    
    // MARK: - 4. Fetch Steps (alias buat Dashboard)
    func fetchLatestSteps(forUserId userId: Int) {
        // Kalau mau full dari Firestore:
        fetchLatestVitals(forUserId: userId)
        
        // Kalau nanti HealthView bener-bener harus 100% non-DB
        // kamu bisa pisah cara ambil steps di sini.
    }
    
    // MARK: - 5. Update Health Data (NON DATABASE untuk ReceiverHealthView)
    func updateHealthData() {
        print("🔄 Refreshing Health Data (LOCAL SIMULATION)...")
        heartRate = Int.random(in: 70...90)
        oxygenSaturation = Double.random(in: 95.0...100.0)
        steps = Int.random(in: 3000...8000)
        wristTemperature = Double.random(in: 36.1...37.2)
        sleepDuration = Double.random(in: 6.0...8.5)
    }
    
    // MARK: - Toggle Task (Dashboard)
    func toggleTaskCompletion(task: Tasks) {
        db.collection("Tasks").document(task.id).updateData([
            "is_completed": !task.isCompleted
        ]) { error in
            if let error = error {
                print("Error updating task completion: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper reset vitals
    private func resetVitals() {
        self.steps = 0
        self.heartRate = 0
        self.wristTemperature = 0.0
        self.sleepDuration = 0.0
        self.oxygenSaturation = 98.5
    }
}



