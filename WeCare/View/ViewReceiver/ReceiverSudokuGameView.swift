import SwiftUI

struct ReceiverSudokuGameView: View {
    @StateObject var game = ReceiverSudokuGameVM()
    @Environment(\.dismiss) var dismiss
    @State private var showConfetti = false
    
    var selectedCell: (row: Int, col: Int)? {
        if let cell = game.board.flatMap({ $0 }).first(where: { $0.isSelected }) {
            let row = game.board.firstIndex(where: { $0.contains(where: { $0.id == cell.id }) })!
            let col = game.board[row].firstIndex(where: { $0.id == cell.id })!
            return (row, col)
        }
        return nil
    }
    
    var selectedValue: Int? {
        guard let selected = selectedCell else { return nil }
        return game.board[selected.row][selected.col].value
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Header
            header
            
            // MARK: - Level Selector
            levelSelector
            
            // MARK: - Game Status
            gameStatus
            
            // MARK: - Sudoku Grid
            sudokuGrid
            
            Spacer(minLength: 8)
            
            // MARK: - Number Pad
            if !game.isBoardFull {
                numberPad
            }
            
            // MARK: - New Game Button
            newGameButton
        }
        .padding(.top, 8)
        .background(Color.white.ignoresSafeArea())
        .onChange(of: game.gameStatus) { status in
            if status.contains("Congratulations") {
                showConfetti = true
            }
        }
    }
}

// MARK: - Header
extension ReceiverSudokuGameView {
    private var header: some View {
        HStack {
            Text("Sudoku")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(Color(hex: "#f67c5f"))
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("Close")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(hex: "#f67c5f"))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Level Selector
extension ReceiverSudokuGameView {
    private var levelSelector: some View {
        HStack(spacing: 12) {
            ForEach(DifficultyLevel.allCases) { level in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        game.startNewGame(level: level)
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(level.icon)
                            .font(.title2)
                        Text(level.rawValue)
                            .font(.caption.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        game.selectedLevel == level ?
                        Color(hex: level.color) :
                        Color(hex: "#fff9e6")
                    )
                    .foregroundColor(
                        game.selectedLevel == level ?
                        .white :
                        Color(hex: "#776e65")
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Game Status
extension ReceiverSudokuGameView {
    private var gameStatus: some View {
        HStack(spacing: 10) {
            Image(systemName: game.gameStatus.contains("Congratulations") ?
                  "checkmark.circle.fill" :
                  game.gameStatus.contains("incorrect") ?
                  "xmark.circle.fill" : "gamecontroller.fill")
                .font(.system(size: 20))
                .foregroundColor(
                    game.gameStatus.contains("Congratulations") ?
                    Color(hex: "#edcf72") :
                    game.gameStatus.contains("incorrect") ?
                    Color(hex: "#f67c5f") :
                    Color(hex: "#edc53f")
                )
            
            Text(game.gameStatus)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#776e65"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(hex: "#fff9e6"))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        .padding(.horizontal, 24)
    }
}

// MARK: - Sudoku Grid
extension ReceiverSudokuGameView {
    private var sudokuGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { col in
                        EnhancedCellView(
                            cell: game.board[row][col],
                            row: row,
                            col: col,
                            game: game,
                            selectedCell: selectedCell,
                            selectedValue: selectedValue
                        )
                        .border(
                            width: (col + 1) % 3 == 0 && col != 8 ? 2 : 1,
                            edges: [.trailing],
                            color: Color(hex: "#bbada0")
                        )
                    }
                }
                .border(
                    width: (row + 1) % 3 == 0 && row != 8 ? 2 : 1,
                    edges: [.bottom],
                    color: Color(hex: "#bbada0")
                )
            }
        }
        .background(Color(hex: "#bbada0"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .padding(.horizontal, 24)
    }
}

// MARK: - Number Pad
extension ReceiverSudokuGameView {
    private var numberPad: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { number in
                    NumberButton(number: number, game: game)
                }
            }
            
            HStack(spacing: 10) {
                ForEach(6...9, id: \.self) { number in
                    NumberButton(number: number, game: game)
                }
                ClearButton(game: game)
            }
        }
        .padding(16)
        .background(Color(hex: "#fff9e6"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        .padding(.horizontal, 24)
    }
}

// MARK: - New Game Button
extension ReceiverSudokuGameView {
    private var newGameButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                game.startNewGame(level: game.selectedLevel)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .bold))
                Text("New Game")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "#f67c5f"))
            .cornerRadius(16)
            .shadow(color: Color(hex: "#f67c5f").opacity(0.4), radius: 8, y: 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

// MARK: - Enhanced Cell View
struct EnhancedCellView: View {
    let cell: SudokuCell
    let row: Int
    let col: Int
    @ObservedObject var game: ReceiverSudokuGameVM
    let selectedCell: (row: Int, col: Int)?
    let selectedValue: Int?
    @State private var scale: CGFloat = 1.0
    
    var isInSameRowColBox: Bool {
        guard let selected = selectedCell else { return false }
        if row == selected.row && col == selected.col { return false }
        if row == selected.row || col == selected.col { return true }
        let selectedBox = (selected.row / 3, selected.col / 3)
        let currentBox = (row / 3, col / 3)
        return selectedBox == currentBox
    }
    
    var isSameNumberAsSelected: Bool {
        guard let sValue = selectedValue, let cValue = cell.value else { return false }
        if cell.isSelected { return false }
        return sValue == cValue
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
            
            if let value = cell.value {
                Text("\(value)")
                    .font(.system(size: 22, weight: cell.isEditable ? .semibold : .bold))
                    .foregroundColor(foregroundColor)
                    .scaleEffect(scale)
            }
        }
        .frame(width: 38, height: 38)
        .contentShape(Rectangle())
        .onTapGesture {
            game.selectCell(row: row, col: col)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                scale = 1.15
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.1)) {
                scale = 1.0
            }
        }
    }
    
    var foregroundColor: Color {
        if cell.isError {
            return Color(hex: "#f67c5f")
        }
        if cell.isEditable {
            return Color(hex: "#edc53f")
        }
        return Color(hex: "#776e65")
    }
    
    var backgroundColor: Color {
        if cell.isSelected {
            return Color(hex: "#edcf72").opacity(0.6)
        }
        if isSameNumberAsSelected {
            return Color(hex: "#f2b179").opacity(0.4)
        }
        if isInSameRowColBox {
            return Color(hex: "#eee4da")
        }
        return Color.white
    }
}

// MARK: - Number Button
struct NumberButton: View {
    let number: Int
    @ObservedObject var game: ReceiverSudokuGameVM
    @State private var isPressed = false
    
    var isDisabled: Bool {
        game.board.flatMap { $0 }.first(where: { $0.isSelected && $0.isEditable }) == nil
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            game.enterValue(value: number)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    isPressed = false
                }
            }
        } label: {
            Text("\(number)")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    isDisabled ?
                    Color(hex: "#cdc1b4") :
                    Color(hex: "#edc53f")
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(isDisabled ? 0 : 0.15), radius: isPressed ? 2 : 4, y: isPressed ? 1 : 2)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Clear Button
struct ClearButton: View {
    @ObservedObject var game: ReceiverSudokuGameVM
    @State private var isPressed = false
    
    var isDisabled: Bool {
        game.board.flatMap { $0 }.first(where: { $0.isSelected && $0.isEditable }) == nil
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            game.enterValue(value: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    isPressed = false
                }
            }
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    isDisabled ?
                    Color(hex: "#cdc1b4") :
                    Color(hex: "#f67c5f")
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(isDisabled ? 0 : 0.15), radius: isPressed ? 2 : 4, y: isPressed ? 1 : 2)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Extensions
extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}

extension DifficultyLevel {
    var icon: String {
        switch self {
        case .easy: return "🌱"
        case .medium: return "🔥"
        case .hard: return "⚡"
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "#edcf72"    // Gold dari 2048
        case .medium: return "#f2b179"  // Orange soft dari 2048
        case .hard: return "#f67c5f"    // Coral dari 2048
        }
    }
}


#Preview {
    ReceiverSudokuGameView()
}
