import Combine
import Foundation
import SwiftUI
// BARU: Enum untuk Level Kesulitan
// Kita buat CaseIterable & Identifiable agar mudah dipakai di Picker
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { self.rawValue }
}
// MARK: - Memory Game Model & Logic
struct MemoryCard: Identifiable {
    let id = UUID()
    let content: String // Emoji or image
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    let identifier: Int
}
class ReceiverMemoryGameVM: ObservableObject {
    @Published var cards: [MemoryCard] = []
    @Published var moves: Int = 0
    @Published var gameStatus: String = "Find all the matching pairs!"
    @Published var isGameOver: Bool = false
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter { cards[$0].isFaceUp && !cards[$0].isMatched }.oneAndOnly }
        set { cards.indices.forEach { cards[$0].isFaceUp = ($0 == newValue) } }
    }
    
    // MARK: - Initialization
    
    init() {
        // DIMODIFIKASI: Mulai game dengan kesulitan default (Easy)
        startNewGame(difficulty: .easy)
    }
    
    // DIMODIFIKASI: Fungsi startNewGame sekarang menerima parameter Difficulty
    func startNewGame(difficulty: Difficulty = .easy) {
        
        // BARU: Kita butuh lebih banyak emoji untuk level Hard
        let cardContents = ["🍏", "🍊", "🍇", "🍓", "🍍", "🍌", "🍎", "🥝", "🍉", "🍒", "🍑", "🥥"] // 12 emoji
        
        // BARU: Tentukan jumlah pasangan berdasarkan kesulitan
        let pairsNeeded: Int
        switch difficulty {
        case .easy:
            pairsNeeded = 6  // 12 kartu (Grid 4x3)
        case .medium:
            pairsNeeded = 8  // 16 kartu (Grid 4x4)
        case .hard:
            pairsNeeded = 12 // 24 kartu (Grid 4x6)
        }
        
        var newCards: [MemoryCard] = []
        
        // Pastikan kita tidak crash jika emoji kurang
        let validPairs = min(pairsNeeded, cardContents.count)
        
        for identifier in 0..<validPairs {
            let content = cardContents[identifier]
            newCards.append(MemoryCard(content: content, identifier: identifier))
            newCards.append(MemoryCard(content: content, identifier: identifier))
        }
        
        cards = newCards.shuffled()
        moves = 0
        isGameOver = false
        gameStatus = "Find all the matching pairs!"
    }
    
    // MARK: - Card Tap Logic
    
    func choose(_ card: MemoryCard) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched {
            
            // Game Logic
            if let potentialMatchIndex = indexOfOneAndOnlyFaceUpCard {
                // SECOND CARD CLICKED
                moves += 1
                
                if cards[chosenIndex].identifier == cards[potentialMatchIndex].identifier {
                    // Match Found!
                    cards[chosenIndex].isFaceUp = true // Tampilkan kartu kedua
                    
                    // Jeda 0.7 detik agar pemain bisa melihat pasangannya
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.cards[chosenIndex].isMatched = true
                        self.cards[potentialMatchIndex].isMatched = true
                        self.checkForGameOver()
                    }
                    
                } else {
                    // Not a Match
                    cards[chosenIndex].isFaceUp = true
                    
                    // Delay untuk membalik kembali
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.cards[chosenIndex].isFaceUp = false
                        self.cards[potentialMatchIndex].isFaceUp = false
                        self.indexOfOneAndOnlyFaceUpCard = nil
                    }
                }
            } else {
                // FIRST CARD CLICKED
                indexOfOneAndOnlyFaceUpCard = chosenIndex
                moves += 1
            }
        }
    }
    
    // MARK: - Check Win Condition
    
    private func checkForGameOver() {
        if cards.allSatisfy({ $0.isMatched }) {
            gameStatus = "🥳 PERFECT! You won in \(moves) moves!"
            isGameOver = true
        } else if !isGameOver {
             // BARU: Reset status setelah jeda match (jika kita menghapus "Match Found!")
             gameStatus = "Find the next pair!"
        }
    }
}
// MARK: - Utility Extension
extension Array {
    var oneAndOnly: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }
}

