import Combine
import Foundation
import SwiftUI // Required for Color
// MARK: - 1. Level Definition
enum DifficultyLevel: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    var id: String { self.rawValue }
}
// MARK: - Sudoku Game Model & Logic
struct SudokuCell: Identifiable {
    let id = UUID()
    var value: Int?
    let initialValue: Int?
    var isSelected: Bool = false
    var isError: Bool = false
    
    var isEditable: Bool {
        return initialValue == nil
    }
}
class ReceiverSudokuGameVM: ObservableObject {
    @Published var board: [[SudokuCell]] = []
    @Published var gameStatus: String = "Happy playing!"
    @Published var selectedLevel: DifficultyLevel = .easy // Currently selected level
    
    private var solvedBoard: [[Int]] = []
    
    init() {
        // Start a new game with the default level (Easy)
        startNewGame(level: .easy)
    }
    
    private static func createBoard(initial: [[Int]], solution: [[Int]]) -> [[SudokuCell]] {
        var newBoard: [[SudokuCell]] = []
        for row in 0..<9 {
            var newRow: [SudokuCell] = []
            for col in 0..<9 {
                let initialVal = initial[row][col] == 0 ? nil : initial[row][col]
                newRow.append(SudokuCell(
                    value: initialVal,
                    initialValue: initialVal
                ))
            }
            newBoard.append(newRow)
        }
        return newBoard
    }
    
    // MARK: - Player Interaction
    
    func selectCell(row: Int, col: Int) {
        for r in 0..<9 {
            for c in 0..<9 {
                board[r][c].isSelected = false
            }
        }
        board[row][col].isSelected = true
    }
    
    func enterValue(value: Int?) {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col].isSelected && board[row][col].isEditable {
                    board[row][col].value = value
                    validateBoard()
                    checkForWin()
                    return
                }
            }
        }
    }
    
    // MARK: - Validation & Win Check (Correctness logic)
    
    private func validateBoard() {
        for row in 0..<9 {
            for col in 0..<9 {
                board[row][col].isError = false
                
                if board[row][col].isEditable, let currentValue = board[row][col].value {
                    if currentValue != solvedBoard[row][col] {
                        board[row][col].isError = true // Mark as INCORRECT
                    }
                }
            }
        }
    }
    func checkForWin() {
        let hasEmptyCells = board.flatMap { $0 }.contains { $0.value == nil }
        let hasErrors = board.flatMap { $0 }.contains { $0.isError }
        
        if hasErrors {
            gameStatus = "❌ A number is incorrect! Check the red ones."
            return
        }
        if hasEmptyCells {
            gameStatus = "Happy playing!"
            return
        }
        
        gameStatus = "🎉 Congratulations! You solved the Sudoku!"
    }
    
    // MARK: - 2. New Function to Start Game with Level
    
    func startNewGame(level: DifficultyLevel) {
        self.selectedLevel = level // Set the selected level
        let preset = SudokuGenerator.generateBoard(level: level) // Get a new board from the generator
        self.board = ReceiverSudokuGameVM.createBoard(initial: preset.initial, solution: preset.solution)
        self.solvedBoard = preset.solution
        self.gameStatus = "Happy playing!"
    }
    
    var isBoardFull: Bool {
        return board.flatMap { $0 }.allSatisfy { $0.value != nil }
    }
}
// MARK: - 3. SudokuGenerator (Updated with Levels)
struct SudokuGenerator {
    
    // Main function called by the ViewModel
    static func generateBoard(level: DifficultyLevel) -> (initial: [[Int]], solution: [[Int]]) {
        switch level {
        case .easy:
            return generateEasyBoard()
        case .medium:
            return generateMediumBoard()
        case .hard:
            return generateHardBoard()
        }
    }
    // Easy Board
    private static func generateEasyBoard() -> (initial: [[Int]], solution: [[Int]]) {
        let initialBoard: [[Int]] = [
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ]
        let solvedBoard: [[Int]] = [
            [5, 3, 4, 6, 7, 8, 9, 1, 2],
            [6, 7, 2, 1, 9, 5, 3, 4, 8],
            [1, 9, 8, 3, 4, 2, 5, 6, 7],
            [8, 5, 9, 7, 6, 1, 4, 2, 3],
            [4, 2, 6, 8, 5, 3, 7, 9, 1],
            [7, 1, 3, 9, 2, 4, 8, 5, 6],
            [9, 6, 1, 5, 3, 7, 2, 8, 4],
            [2, 8, 7, 4, 1, 9, 6, 3, 5],
            [3, 4, 5, 2, 8, 6, 1, 7, 9]
        ]
        return (initialBoard, solvedBoard)
    }
    
    // Medium Board
    private static func generateMediumBoard() -> (initial: [[Int]], solution: [[Int]]) {
        let initialBoard: [[Int]] = [
            [0, 0, 0, 6, 0, 0, 4, 0, 0],
            [7, 0, 0, 0, 0, 3, 6, 0, 0],
            [0, 0, 5, 0, 9, 1, 0, 0, 0],
            [8, 0, 4, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 0, 0, 5, 0],
            [0, 0, 0, 0, 0, 0, 1, 0, 7],
            [0, 0, 0, 3, 2, 0, 9, 0, 0],
            [0, 0, 9, 7, 0, 0, 0, 0, 5],
            [0, 0, 3, 0, 0, 8, 0, 0, 0]
        ]
        let solvedBoard: [[Int]] = [
            [1, 3, 2, 6, 8, 7, 4, 9, 5],
            [7, 9, 8, 2, 5, 3, 6, 1, 4],
            [6, 4, 5, 1, 9, 1, 7, 8, 2],
            [8, 7, 4, 5, 1, 9, 3, 2, 6],
            [9, 1, 6, 8, 3, 2, 5, 4, 7],
            [3, 2, 5, 4, 7, 6, 1, 9, 8],
            [5, 8, 7, 3, 2, 4, 9, 6, 1],
            [2, 6, 9, 7, 4, 1, 8, 3, 5],
            [4, 5, 3, 9, 6, 8, 2, 7, 1]
        ]
        return (initialBoard, solvedBoard)
    }
    // Hard Board
    private static func generateHardBoard() -> (initial: [[Int]], solution: [[Int]]) {
        let initialBoard: [[Int]] = [
            [8, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 3, 6, 0, 0, 0, 0, 0],
            [0, 7, 0, 0, 9, 0, 2, 0, 0],
            [0, 5, 0, 0, 0, 7, 0, 0, 0],
            [0, 0, 0, 0, 4, 5, 7, 0, 0],
            [0, 0, 0, 1, 0, 0, 0, 3, 0],
            [0, 0, 1, 0, 0, 0, 0, 6, 8],
            [0, 0, 8, 5, 0, 0, 0, 1, 0],
            [0, 9, 0, 0, 0, 0, 4, 0, 0]
        ]
        let solvedBoard: [[Int]] = [
            [8, 1, 2, 7, 5, 3, 6, 4, 9],
            [9, 4, 3, 6, 8, 2, 1, 7, 5],
            [6, 7, 5, 4, 9, 1, 2, 8, 3],
            [1, 5, 4, 2, 3, 7, 8, 9, 6],
            [3, 6, 9, 8, 4, 5, 7, 2, 1],
            [2, 8, 7, 1, 6, 9, 5, 3, 4],
            [5, 2, 1, 9, 7, 4, 3, 6, 8],
            [4, 3, 8, 5, 2, 6, 9, 1, 7],
            [7, 9, 6, 3, 1, 8, 4, 5, 2]
        ]
        return (initialBoard, solvedBoard)
    }
}

