import SwiftUI
import Foundation
import Combine

class ReceiverCrosswordViewModel: ObservableObject {
    let numRows = 10
    let numCols = 10
    
    @Published var grid: [[CrosswordCell]] = []
    @Published var selectedCellID: UUID?
    @Published var isPuzzleSolved: Bool = false
    @Published var gameStatus: String = "General Knowledge"
    
    let cluesAcross = [
        "1. Sheets in a book (5)",          // PAGES
        "4. Clear liquid we drink (5)",     // WATER
        "5. Time when it's dark (5)",       // NIGHT
        "7. The final frontier (5)",        // SPACE
        "9. Baked food made of flour (5)"   // BREAD
    ]
    
    let cluesDown = [
        "1. Art medium or to color (5)",    // PAINT
        "2. A way in (5)",                  // ENTRY
        "3. Feeling joyful (5)",            // HAPPY
        "6. Large body of salt water (5)",  // OCEAN
        "8. Thoughts while sleeping (5)"    // DREAM
    ]
    
    init() {
        createPuzzle()
    }
    
    func createPuzzle() {
        var newGrid = [[CrosswordCell]](
            repeating: [CrosswordCell](
                repeating: .init(row: 0, col: 0, answer: ""),
                count: numCols
            ),
            count: numRows
        )
        
        addWord(row: 0, col: 0, word: "PAGES", clue: 1, isAcross: true, to: &newGrid)
        addWord(row: 2, col: 2, word: "WATER", clue: 4, isAcross: true, to: &newGrid)
        addWord(row: 4, col: 0, word: "NIGHT", clue: 5, isAcross: true, to: &newGrid)
        addWord(row: 6, col: 2, word: "SPACE", clue: 7, isAcross: true, to: &newGrid)
        addWord(row: 8, col: 4, word: "BREAD", clue: 9, isAcross: true, to: &newGrid)
        
        addWord(row: 0, col: 0, word: "PAINT", clue: 1, isAcross: false, to: &newGrid)
        addWord(row: 0, col: 3, word: "ENTRY", clue: 2, isAcross: false, to: &newGrid)
        addWord(row: 4, col: 3, word: "HAPPY", clue: 3, isAcross: false, to: &newGrid)
        addWord(row: 6, col: 6, word: "OCEAN", clue: 6, isAcross: false, to: &newGrid)
        addWord(row: 8, col: 8, word: "DREAM", clue: 8, isAcross: false, to: &newGrid)
        
        grid = newGrid
        isPuzzleSolved = false
        selectedCellID = nil
        gameStatus = "General Knowledge"
    }
    
    private func addWord(row: Int, col: Int, word: String, clue: Int, isAcross: Bool, to grid: inout [[CrosswordCell]]) {
        let chars = Array(word.uppercased())
        for (i, char) in chars.enumerated() {
            let r = isAcross ? row : row + i
            let c = isAcross ? col + i : col
            
            if r < numRows && c < numCols {
                let existingCell = grid[r][c]
                let numberToSet = (i == 0) ? clue : existingCell.clueNumber
                
                grid[r][c] = CrosswordCell(
                    row: r,
                    col: c,
                    clueNumber: numberToSet,
                    answer: String(char),
                    input: existingCell.input,
                    isCorrect: existingCell.isCorrect,
                    isBlocked: false
                )
            }
        }
    }
    
    func selectCell(_ cell: CrosswordCell) {
        if !cell.isBlocked {
            selectedCellID = cell.id
        }
    }
    
    func checkAnswers() {
        var allCorrect = true
        var correctCount = 0
        var totalFillable = 0
        
        for r in 0..<numRows {
            for c in 0..<numCols {
                let cell = grid[r][c]
                if cell.isBlocked { continue }
                totalFillable += 1
                if cell.input == cell.answer {
                    grid[r][c].isCorrect = true
                    correctCount += 1
                } else {
                    grid[r][c].isCorrect = false
                    allCorrect = false
                }
            }
        }
        
        if allCorrect && totalFillable > 0 {
            isPuzzleSolved = true
            gameStatus = "🥳 Perfect! All Correct!"
        } else {
            gameStatus = "\(correctCount)/\(totalFillable) Correct"
        }
    }
}

