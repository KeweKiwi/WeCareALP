import Foundation
import SwiftUI
import Combine
// MARK: - 1. MODELS & ENUMS
// Enum untuk Tingkat Kesulitan
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { self.rawValue }
}
// Model Data Kartu
struct MemoryCard: Identifiable {
    let id = UUID()
    let content: String // Emoji
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    let identifier: Int
}
// Extension Helper untuk Array
extension Array {
    var oneAndOnly: Element? {
        count == 1 ? first : nil
    }
}
// MARK: - 2. VIEW MODEL (LOGIKA GAME)
class ReceiverMemoryGameVM: ObservableObject {
    @Published var cards: [MemoryCard] = []
    @Published var moves: Int = 0
    @Published var gameStatus: String = "Tap a card to start!"
    @Published var isGameOver: Bool = false
    
    // Helper untuk melacak indeks kartu pertama yang sedang terbuka (belum match)
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter { cards[$0].isFaceUp && !cards[$0].isMatched }.oneAndOnly }
        set {
            // Setter dikosongkan agar kontrol animasi dilakukan manual di View
        }
    }
    
    init() {
        startNewGame(difficulty: .easy)
    }
    
    func startNewGame(difficulty: Difficulty) {
        // Daftar Emoji Buah-buahan
        let cardContents = ["🍓", "🍉", "🍌", "🍇", "🍎", "🍒", "🥝", "🍍", "🥥", "🍋", "🍊", "🍐", "🥭", "🫐", "🍈"]
        
        // Tentukan jumlah pasangan berdasarkan kesulitan
        let pairsNeeded: Int
        switch difficulty {
        case .easy:   pairsNeeded = 6  // 12 kartu
        case .medium: pairsNeeded = 8  // 16 kartu
        case .hard:   pairsNeeded = 15 // 30 kartu
        }
        
        var newCards: [MemoryCard] = []
        // Ambil emoji sesuai jumlah yang dibutuhkan
        let validPairs = min(pairsNeeded, cardContents.count)
        
        // Buat pasangan kartu
        for identifier in 0..<validPairs {
            let content = cardContents[identifier]
            newCards.append(MemoryCard(content: content, identifier: identifier))
            newCards.append(MemoryCard(content: content, identifier: identifier))
        }
        
        // Acak kartu dan reset status
        cards = newCards.shuffled()
        moves = 0
        isGameOver = false
        indexOfOneAndOnlyFaceUpCard = nil
        gameStatus = "Find all pairs!"
    }
    
    func choose(_ card: MemoryCard) {
        // Cari index kartu yang dipilih
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched {
            
            if let potentialMatchIndex = indexOfOneAndOnlyFaceUpCard {
                // --- KARTU KEDUA DIPILIH ---
                moves += 1
                cards[chosenIndex].isFaceUp = true
                
                if cards[chosenIndex].identifier == cards[potentialMatchIndex].identifier {
                    // MATCH!
                    // Beri jeda sedikit agar animasi selesai
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.cards[chosenIndex].isMatched = true
                        self.cards[potentialMatchIndex].isMatched = true
                        self.checkForGameOver()
                    }
                } else {
                    // TIDAK MATCH
                    // Beri waktu user melihat kartu, lalu tutup kembali
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.cards[chosenIndex].isFaceUp = false
                        self.cards[potentialMatchIndex].isFaceUp = false
                    }
                }
                // Reset pelacak kartu pertama
                indexOfOneAndOnlyFaceUpCard = nil
                
            } else {
                // --- KARTU PERTAMA DIPILIH ---
                // Safety check: Tutup semua kartu lain yang mungkin masih terbuka
                for index in cards.indices {
                    if !cards[index].isMatched {
                        cards[index].isFaceUp = false
                    }
                }
                
                cards[chosenIndex].isFaceUp = true
                indexOfOneAndOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    private func checkForGameOver() {
        if cards.allSatisfy({ $0.isMatched }) {
            gameStatus = "🏆 You Won in \(moves) moves!"
            isGameOver = true
        } else {
            gameStatus = "Great! Keep going."
        }
    }
}
