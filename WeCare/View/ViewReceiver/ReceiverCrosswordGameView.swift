import Combine
import SwiftUI
// MARK: - 1. Model Data (Tidak berubah)
struct CrosswordCell: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    let clueNumber: Int?
    let answer: String
    var input: String = ""
    var isCorrect: Bool = false
    var isBlocked: Bool { answer.isEmpty }
    
    init(row: Int, col: Int, clueNumber: Int? = nil, answer: String) {
        self.row = row
        self.col = col
        self.clueNumber = clueNumber
        self.answer = answer.uppercased()
    }
}
// MARK: - 2. View Model (Logika Game) (DITERJEMAHKAN)
class CrosswordViewModel: ObservableObject {
    let numRows = 7
    let numCols = 7
    
    @Published var grid: [[CrosswordCell]] = []
    @Published var selectedCellID: UUID?
    @Published var isPuzzleSolved: Bool = false
    
    // --- CLUES BARU (BAHASA INGGRIS) ---
    let cluesAcross = [
        "1. A happy facial expression (5)", // SMILE
        "4. A round, citrus fruit (6)" // ORANGE
    ]
    
    let cluesDown = [
        "2. A long, yellow fruit (6)", // BANANA
        "3. A large, wild cat (4)" // LION
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
        
        // --- PUZZLE BARU (BAHASA INGGRIS) ---
        
        // 1-Across: SMILE (row 0)
        newGrid[0][1] = CrosswordCell(row: 0, col: 1, clueNumber: 1, answer: "S")
        newGrid[0][2] = CrosswordCell(row: 0, col: 2, answer: "M")
        newGrid[0][3] = CrosswordCell(row: 0, col: 3, answer: "I")
        newGrid[0][4] = CrosswordCell(row: 0, col: 4, answer: "L") // Intersects with 3-Down
        newGrid[0][5] = CrosswordCell(row: 0, col: 5, answer: "E")
        
        // 4-Across: ORANGE (row 4)
        newGrid[4][0] = CrosswordCell(row: 4, col: 0, clueNumber: 4, answer: "O")
        newGrid[4][1] = CrosswordCell(row: 4, col: 1, answer: "R")
        newGrid[4][2] = CrosswordCell(row: 4, col: 2, answer: "A") // Intersects with 2-Down
        newGrid[4][3] = CrosswordCell(row: 4, col: 3, answer: "N")
        newGrid[4][4] = CrosswordCell(row: 4, col: 4, answer: "G")
        newGrid[4][5] = CrosswordCell(row: 4, col: 5, answer: "E")
        // 2-Down: BANANA (col 2)
        newGrid[1][2] = CrosswordCell(row: 1, col: 2, clueNumber: 2, answer: "B")
        newGrid[2][2] = CrosswordCell(row: 2, col: 2, answer: "A")
        newGrid[3][2] = CrosswordCell(row: 3, col: 2, answer: "N")
        // newGrid[4][2] is 'A' from ORANGE (Correct)
        newGrid[5][2] = CrosswordCell(row: 5, col: 2, answer: "N")
        newGrid[6][2] = CrosswordCell(row: 6, col: 2, answer: "A")
        
        // 3-Down: LION (col 4)
        // newGrid[0][4] is 'L' from SMILE (Correct)
        newGrid[1][4] = CrosswordCell(row: 1, col: 4, clueNumber: 3, answer: "I")
        newGrid[2][4] = CrosswordCell(row: 2, col: 4, answer: "O")
        newGrid[3][4] = CrosswordCell(row: 3, col: 4, answer: "N")
        self.grid = newGrid
        self.isPuzzleSolved = false
        self.selectedCellID = nil
        self.gameStatus = "Fill in the grid!" // Status default baru
    }
    
    func selectCell(_ cell: CrosswordCell) {
        if cell.isBlocked {
            selectedCellID = nil
        } else {
            selectedCellID = cell.id
        }
    }
    
    func inputLetter(_ letter: String) {
        guard let selectedID = selectedCellID else { return }
        for r in 0..<numRows {
            if let c = grid[r].firstIndex(where: { $0.id == selectedID }) {
                grid[r][c].input = letter.uppercased()
                break
            }
        }
    }
    
    func deleteLetter() {
        guard let selectedID = selectedCellID else { return }
        for r in 0..<numRows {
            if let c = grid[r].firstIndex(where: { $0.id == selectedID }) {
                grid[r][c].input = ""
                break
            }
        }
    }
    
    func checkAnswers() {
        var allCorrect = true
        for r in 0..<numRows {
            for c in 0..<numCols {
                if grid[r][c].isBlocked { continue }
                if grid[r][c].input == grid[r][c].answer {
                    grid[r][c].isCorrect = true
                } else {
                    grid[r][c].isCorrect = false
                    allCorrect = false
                }
            }
        }
        
        // --- Status Diterjemahkan ---
        if allCorrect {
            isPuzzleSolved = true
            gameStatus = "🥳 Congratulations! You solved it!"
        } else {
            gameStatus = "Some answers are incorrect. Try again!"
        }
    }
    
    @Published var gameStatus = ""
}
// MARK: - 3. View Utama (DITERJEMAHKAN)
struct ReceiverCrosswordGameView: View {
    
    @StateObject private var viewModel = CrosswordViewModel()
    @Environment(\.dismiss) var dismiss
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            crosswordGrid
            ClueListView(
                across: viewModel.cluesAcross,
                down: viewModel.cluesDown,
                status: viewModel.gameStatus,
                isSolved: viewModel.isPuzzleSolved
            )
            Spacer()
            actionButtons
            customKeyboard
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Text("🧩 Crossword") // Diterjemahkan
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "#91bef8"))
            Spacer()
            Button("Back") { dismiss() } // Sudah Inggris
                .font(.title3.bold())
                .foregroundColor(.black)
                .padding(8)
                .background(Color(hex: "#fdcb46"))
                .cornerRadius(10)
        }
        .padding([.horizontal, .top])
    }
    
    private var crosswordGrid: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(viewModel.grid.flatMap { $0 }) { cell in
                // Menggunakan CrosswordCellView dari file Anda
                CrosswordCellView(cell: cell, isSelected: cell.id == viewModel.selectedCellID)
                    .onTapGesture { viewModel.selectCell(cell) }
            }
        }
        .padding(10)
        .background(Color.black)
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
    private var actionButtons: some View {
        HStack {
            Button("Check Answers") { // Diterjemahkan
                viewModel.checkAnswers()
            }
            .font(.title3.bold())
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#a6d17d"))
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Reset") { // Sudah Inggris
                viewModel.createPuzzle()
            }
            .font(.title3.bold())
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#fa6255"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private var customKeyboard: some View {
        KeyboardView(
            onLetterTapped: { letter in
                viewModel.inputLetter(letter)
            },
            onDeleteTapped: {
                viewModel.deleteLetter()
            }
        )
        .padding(.bottom, 5)
    }
}
// MARK: - 4. Komponen (Sub-View) (DITERJEMAHKAN)
// Tampilan untuk satu kotak (CrosswordCellView)
struct CrosswordCellView: View {
    let cell: CrosswordCell
    let isSelected: Bool
    var body: some View {
        ZStack {
            if cell.isBlocked { Color.black } else { Color.white }
            if let number = cell.clueNumber {
                Text("\(number)")
                    .font(.system(size: 8).bold())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(3)
            }
            Text(cell.input)
                .font(.title2.bold())
                .foregroundColor(cell.isCorrect ? Color(hex: "#a6d17d") : .black)
            if isSelected {
                Rectangle()
                    .stroke(Color(hex: "#91bef8"), lineWidth: 4)
            }
        }
        .frame(height: 45)
    }
}
// Tampilan untuk daftar petunjuk (ClueListView)
struct ClueListView: View {
    let across: [String]
    let down: [String]
    let status: String
    let isSolved: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            if !status.isEmpty {
                Text(status)
                    .font(.headline)
                    .foregroundColor(isSolved ? Color(hex: "#a6d17d") : Color(hex: "#fa6255"))
                    .padding(5)
            }
            
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading) {
                    Text("Across") // Diterjemahkan
                        .font(.title3.bold())
                    ForEach(across, id: \.self) { clue in
                        Text(clue)
                            .font(.caption)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Down") // Diterjemahkan
                        .font(.title3.bold())
                    ForEach(down, id: \.self) { clue in
                        Text(clue)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: 120)
    }
}
// Tampilan untuk Keyboard Kustom (KeyboardView) (Tidak perlu diubah)
struct KeyboardView: View {
    var onLetterTapped: (String) -> Void
    var onDeleteTapped: () -> Void
    
    let row1 = "QWERTYUIOP"
    let row2 = "ASDFGHJKL"
    let row3 = "ZXCVBNM"
    
    var body: some View {
        VStack(spacing: 5) {
            keyboardRow1
            keyboardRow2
            keyboardRow3
        }
    }
    
    private var keyboardRow1: some View {
        HStack(spacing: 5) {
            ForEach(row1.map { String($0) }, id: \.self) { letter in
                KeyButton(letter: letter, onTap: onLetterTapped)
            }
        }
    }
    
    private var keyboardRow2: some View {
        HStack(spacing: 5) {
            ForEach(row2.map { String($0) }, id: \.self) { letter in
                KeyButton(letter: letter, onTap: onLetterTapped)
            }
        }
    }
    
    private var keyboardRow3: some View {
        HStack(spacing: 5) {
            ForEach(row3.map { String($0) }, id: \.self) { letter in
                KeyButton(letter: letter, onTap: onLetterTapped)
            }
            Button(action: onDeleteTapped) {
                Image(systemName: "delete.left.fill")
                    .font(.title3)
                    .frame(width: 45, height: 50)
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
    }
}
// Tombol individual untuk keyboard (KeyButton) (Tidak perlu diubah)
struct KeyButton: View {
    let letter: String
    let onTap: (String) -> Void
    
    var body: some View {
        Button(action: { onTap(letter) }) {
            Text(letter)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(8)
                .shadow(radius: 2, y: 1)
        }
    }
}
// MARK: - 5. Preview
#Preview {
    ReceiverCrosswordGameView()
}

