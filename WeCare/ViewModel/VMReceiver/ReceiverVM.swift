import Combine
import Foundation
import SwiftUI
// MARK: - ViewModel
class ReceiverVM: ObservableObject {
    
    // Vital Health Data (Diperbarui untuk Apple Watch)
    @Published var heartRate: Int = 78
    @Published var oxygenSaturation: Double = 98.5
    @Published var steps: Int = 5230
    @Published var wristTemperature: Double = 36.8 // Dalam Celsius
    @Published var sleepDuration: Double = 7.2 // Dalam Jam
    
    // --- Properti Tekanan Darah Dihapus ---
    // @Published var systolicPressure: Int = 125
    // @Published var diastolicPressure: Int = 80
    
    // Daily Task / Reminder Data
    @Published var tasks: [TaskItem] = [
        TaskItem(time: "07:00", title: "Take Morning Medicine", isCompleted: false),
        TaskItem(time: "09:00", title: "Morning Walk (10 mins)", isCompleted: false),
        TaskItem(time: "13:00", title: "Take Noon Medicine", isCompleted: false),
        TaskItem(time: "19:00", title: "Take Evening Medicine", isCompleted: false)
    ]
    
    // Computed Property: Task Completion Percentage
    var taskCompletionPercentage: Int {
        let completedCount = tasks.filter { $0.isCompleted }.count
        let totalCount = tasks.count
        return totalCount > 0 ? (completedCount * 100) / totalCount : 0
    }
    
    // --- bloodPressureStatus Dihapus ---
    // var bloodPressureStatus: (String, Color) { ... }
    
    // BARU: Computed Property untuk Kualitas Tidur
    var sleepStatus: (String, Color) {
        if sleepDuration >= 7.0 {
            return ("Good", Color(hex: "#a6d17d"))
        } else if sleepDuration >= 6.0 {
            return ("Okay", Color(hex: "#fdcb46"))
        } else {
            return ("Poor", Color(hex: "#fa6255"))
        }
    }
    
    // Function: Update Health Data (Simulasi Diperbarui)
    func updateHealthData() {
        heartRate = Int.random(in: 70...90)
        oxygenSaturation = Double.random(in: 95.0...100.0)
        steps = Int.random(in: 3000...8000)
        wristTemperature = Double.random(in: 36.1...37.2)
        sleepDuration = Double.random(in: 6.0...8.5)
    }
    
    // Function: Toggle Task Completion
    func toggleTaskCompletion(for taskID: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskID }) {
            tasks[index].isCompleted.toggle()
        }
    }
}
