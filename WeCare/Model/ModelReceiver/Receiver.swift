import Foundation
import SwiftUI
// MARK: - App Models
struct TaskItem: Identifiable {
    let id = UUID()
    let time: String
    let title: String
    var isCompleted: Bool = false
}
struct GameRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}
// MARK: - Crossword Models
struct CrosswordCell: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    let clueNumber: Int? // Angka kecil di pojok
    let answer: String
    var input: String = ""
    var isCorrect: Bool = false
    
    // Jika tidak ada jawaban (answer kosong), maka sel ini "blocked" (tembok hitam/kosong)
    var isBlocked: Bool { answer.isEmpty }
    
    init(row: Int, col: Int, clueNumber: Int? = nil, answer: String) {
        self.row = row
        self.col = col
        self.clueNumber = clueNumber
        self.answer = answer.uppercased()
    }
}
// MARK: - Utility Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
