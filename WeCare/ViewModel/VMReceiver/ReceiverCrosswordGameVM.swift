import SwiftUI
import Foundation
import Combine

class ReceiverCrosswordViewModel: ObservableObject {
    let numRows = 13
    let numCols = 9
    
    @Published var grid: [[CrosswordCell]] = []
    @Published var selectedCellID: UUID?
    @Published var isPuzzleSolved: Bool = false
    @Published var gameStatus: String = "General Knowledge"
    
    // Kita butuh menyimpan definisi kata untuk perhitungan skor berbasis soal
    private struct PlacedWord {
        let row: Int
        let col: Int
        let text: String
        let isAcross: Bool
    }
    private var placedWords: [PlacedWord] = []
    
    // MARK: - CLUES
    
    let cluesAcross = [
        "1. Camera image (5)",          // PHOTO
        "4. Clear liquid we drink (5)", // WATER
        "5. Knowledge checks (5)",      // TESTS
        "7. Sound you can hear (5)",    // AUDIO
        "9. Baked food made of flour (5)" // BREAD
    ]
    
    let cluesDown = [
        "1. Art medium or to color (5)",    // PAINT
        "2. Warm, browned breakfast bread (5)", // TOAST
        "3. Sense of feeling (5)",          // TOUCH
        "6. Large body of salt water (5)",  // OCEAN
        "8. Thoughts while sleeping (5)"    // DREAM
    ]
    
    init() {
        createPuzzle()
    }
    
    func createPuzzle() {
        // Reset daftar kata
        placedWords.removeAll()
        
        // Initialize grid with all blocked cells
        var newGrid = [[CrosswordCell]](
            repeating: [CrosswordCell](
                repeating: .init(row: 0, col: 0, answer: "", isBlocked: true),
                count: numCols
            ),
            count: numRows
        )
        
        // --- ACROSS WORDS ---
        addWord(row: 0, col: 0, word: "PHOTO", clue: 1, isAcross: true, to: &newGrid)
        addWord(row: 2, col: 2, word: "WATER", clue: 4, isAcross: true, to: &newGrid)
        addWord(row: 4, col: 0, word: "TESTS", clue: 5, isAcross: true, to: &newGrid)
        addWord(row: 6, col: 2, word: "AUDIO", clue: 7, isAcross: true, to: &newGrid)
        addWord(row: 8, col: 4, word: "BREAD", clue: 9, isAcross: true, to: &newGrid)
        
        // --- DOWN WORDS ---
        addWord(row: 0, col: 0, word: "PAINT", clue: 1, isAcross: false, to: &newGrid)
        addWord(row: 0, col: 3, word: "TOAST", clue: 2, isAcross: false, to: &newGrid)
        addWord(row: 4, col: 3, word: "TOUCH", clue: 3, isAcross: false, to: &newGrid)
        addWord(row: 6, col: 6, word: "OCEAN", clue: 6, isAcross: false, to: &newGrid)
        addWord(row: 8, col: 8, word: "DREAM", clue: 8, isAcross: false, to: &newGrid)
        
        grid = newGrid
        isPuzzleSolved = false
        selectedCellID = nil
        gameStatus = "General Knowledge"
    }
    
    private func addWord(row: Int, col: Int, word: String, clue: Int, isAcross: Bool, to grid: inout [[CrosswordCell]]) {
        // 1. Simpan definisi kata ke memori untuk scoring nanti
        placedWords.append(PlacedWord(row: row, col: col, text: word, isAcross: isAcross))
        
        // 2. Gambar kata ke Grid (Visual)
        let chars = Array(word.uppercased())
        for (i, char) in chars.enumerated() {
            let r = isAcross ? row : row + i
            let c = isAcross ? col + i : col
            
            if r < numRows && c < numCols {
                let existingCell = grid[r][c]
                let numberToSet = (existingCell.clueNumber != nil) ? existingCell.clueNumber : ((i == 0) ? clue : nil)
                
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
        // Langkah 1: Update status visual Cell (Hijau/Merah) di Grid
        // Kita tetap perlu loop grid untuk pewarnaan visual per kotak
        var visualAllCorrect = true
        for r in 0..<numRows {
            for c in 0..<numCols {
                if !grid[r][c].isBlocked {
                    if grid[r][c].input.uppercased() == grid[r][c].answer.uppercased() {
                        grid[r][c].isCorrect = true
                    } else {
                        grid[r][c].isCorrect = false
                        visualAllCorrect = false
                    }
                }
            }
        }
        
        // Langkah 2: Hitung Skor berdasarkan KATA (Bukan Kotak)
        // Ini memenuhi request: persimpangan dihitung 2x (sekali untuk mendatar, sekali untuk menurun)
        var totalLettersInQuestions = 0
        var correctLettersCount = 0
        
        for wordItem in placedWords {
            let chars = Array(wordItem.text.uppercased())
            
            for (i, char) in chars.enumerated() {
                totalLettersInQuestions += 1 // Menambah total poin
                
                let r = wordItem.isAcross ? wordItem.row : wordItem.row + i
                let c = wordItem.isAcross ? wordItem.col + i : wordItem.col
                
                // Cek apakah input user di kotak itu sesuai dengan huruf yang diharapkan kata ini
                // (Menggunakan char dari wordItem memastikan validasi per kata)
                if grid[r][c].input.uppercased() == String(char) {
                    correctLettersCount += 1
                }
            }
        }
        
        // Langkah 3: Tentukan Status Game
        // Jika visual grid benar semua, otomatis hitungan kata juga pasti benar semua
        if visualAllCorrect && totalLettersInQuestions > 0 {
            isPuzzleSolved = true
            gameStatus = "🥳 Perfect! All Correct!"
        } else {
            isPuzzleSolved = false
            // Tampilkan skor misal 50/50, bukan 41/41
            gameStatus = "\(correctLettersCount)/\(totalLettersInQuestions) Correct"
        }
    }
}
