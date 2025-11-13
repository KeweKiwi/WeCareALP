import SwiftUI
// MARK: - Sudoku View
struct ReceiverSudokuGameView: View {
    @StateObject var game = ReceiverSudokuGameVM()
    @Environment(\.dismiss) var dismiss
    
    // Property to track the active cell
    var selectedCell: (row: Int, col: Int)? {
        if let cell = game.board.flatMap({ $0 }).first(where: { $0.isSelected }) {
            let row = game.board.firstIndex(where: { $0.contains(where: { $0.id == cell.id }) })!
            let col = game.board[row].firstIndex(where: { $0.id == cell.id })!
            return (row, col)
        }
        return nil
    }
    
    // <<< CHANGE: Also get the VALUE of the selected cell
    var selectedValue: Int? {
        guard let selected = selectedCell else { return nil }
        // Check the value on the board based on the selected coordinates
        return game.board[selected.row][selected.col].value
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header & Back Button
            HStack {
                Text("Sudoku Game")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(hex: "#387b38"))
                Spacer()
                Button("Back") {
                    dismiss()
                }
                .font(.title3.bold())
                .foregroundColor(.black)
                .padding(8)
                .background(Color(hex: "#fdcb46"))
                .cornerRadius(10)
            }
            .padding([.horizontal, .top])
            
            // MARK: - 1. Level Selector (Picker)
            Picker("Select Level", selection: $game.selectedLevel) {
                ForEach(DifficultyLevel.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            // 2. Monitor changes on the Picker
            .onChange(of: game.selectedLevel) { newLevel in
                game.startNewGame(level: newLevel)
            }
            
            // MARK: - Game Status (Green/Red)
            Text(game.gameStatus)
                .font(.title3.bold())
                .foregroundColor(game.gameStatus.contains("Congratulations") ? Color(hex: "#387b38") : Color(hex: "#fa6255"))
                .padding(.horizontal)
            
            // MARK: - Sudoku Grid
            VStack(spacing: 1) {
                ForEach(0..<9, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<9, id: \.self) { col in
                            CellView(cell: game.board[row][col],
                                     row: row,
                                     col: col,
                                     game: game,
                                     selectedCell: selectedCell,
                                     // <<< CHANGE: Send the selected value to the cell
                                     selectedValue: selectedValue)
                                .padding(.trailing, (col + 1) % 3 == 0 && col != 8 ? 2 : 0)
                                .padding(.bottom, (row + 1) % 3 == 0 && row != 8 ? 2 : 0)
                        }
                    }
                }
            }
            .background(Color.black)
            .padding(.horizontal)
            
            Spacer()
            // MARK: - Number Input (Only shows if board is not full)
            if !game.isBoardFull {
                NumberPad(game: game)
                    .padding(.bottom, 10)
            }
            
            // MARK: - Action Button
            Button("Start New Game") {
                // 3. Use the currently selected level
                game.startNewGame(level: game.selectedLevel)
            }
            .font(.title2.bold())
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#fa6255"))
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding(.horizontal)
            
        }
        .padding(.top, 20)
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
// MARK: - CellView (New Highlight Logic)
struct CellView: View {
    let cell: SudokuCell
    let row: Int
    let col: Int
    @ObservedObject var game: ReceiverSudokuGameVM
    let selectedCell: (row: Int, col: Int)?
    let selectedValue: Int? // <<< CHANGE: Receives the selected value
    
    // Property to highlight row/column/box (gray)
    var isInSameRowColBox: Bool {
        guard let selected = selectedCell else { return false }
        
        // Don't highlight the selected cell itself
        if row == selected.row && col == selected.col { return false }
        
        if row == selected.row || col == selected.col { return true }
        
        let selectedBox = (selected.row / 3, selected.col / 3)
        let currentBox = (row / 3, col / 3)
        return selectedBox == currentBox
    }
    
    // <<< CHANGE: New property to highlight the same number (green)
    var isSameNumberAsSelected: Bool {
        guard let sValue = selectedValue, let cValue = cell.value else { return false }
        
        // Don't highlight the selected cell itself
        if cell.isSelected { return false }
        
        return sValue == cValue
    }
    
    var body: some View {
        Text(cell.value != nil ? "\(cell.value!)" : "")
            .font(.title.bold())
            .frame(width: 40, height: 40)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .border(Color.black.opacity(0.1), width: 0.5)
            .contentShape(Rectangle())
            .onTapGesture {
                game.selectCell(row: row, col: col)
            }
    }
    
    var foregroundColor: Color {
        if cell.isError {
            return Color(hex: "#fa6255") // Red
        }
        
        if cell.isEditable {
            return .blue // Player input: Blue
        } else {
            return .black // Initial value: Black
        }
    }
    
    // <<< MAJOR CHANGE: 'backgroundColor' Logic
    var backgroundColor: Color {
        // 1. Highest priority: Selected cell (Yellow)
        if cell.isSelected {
            return Color(hex: "#fdcb46").opacity(0.9)
        }
        
        // 2. Second priority: Same number (Green)
        if isSameNumberAsSelected {
            return Color(hex: "#a6d17d").opacity(0.5)
        }
        
        // 3. Third priority: Row/Column/Box (Gray)
        if isInSameRowColBox {
            return Color(.systemGray5) // "A light gray"
        }
        // 4. Default: White (Includes initial numbers which are no longer gray)
        return .white
    }
}
// MARK: - NumberPad, NumberButton, ClearButton (No changes here)
struct NumberPad: View {
    @ObservedObject var game: ReceiverSudokuGameVM
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                ForEach(1...5, id: \.self) { number in
                    NumberButton(number: number, game: game)
                }
            }
            HStack(spacing: 15) {
                ForEach(6...9, id: \.self) { number in
                    NumberButton(number: number, game: game)
                }
                ClearButton(game: game)
            }
        }
        .padding(.horizontal)
    }
}
struct NumberButton: View {
    let number: Int
    @ObservedObject var game: ReceiverSudokuGameVM
    
    var body: some View {
        Button(action: {
            game.enterValue(value: number)
        }) {
            Text("\(number)")
                .font(.title2.bold())
                .frame(width: 55, height: 55)
                .background(Color(hex: "#387b38"))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(game.board.flatMap { $0 }.first(where: { $0.isSelected && $0.isEditable }) == nil)
    }
}
struct ClearButton: View {
    @ObservedObject var game: ReceiverSudokuGameVM
    
    var body: some View {
        Button(action: {
            game.enterValue(value: nil)
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2.bold())
                .frame(width: 55, height: 55)
                .background(Color(.systemGray3))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(game.board.flatMap { $0 }.first(where: { $0.isSelected && $0.isEditable }) == nil)
    }
}
#Preview{
    ReceiverSudokuGameView()
}



