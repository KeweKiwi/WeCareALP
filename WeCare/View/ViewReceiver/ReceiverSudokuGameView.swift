import SwiftUI

// MARK: - Sudoku View
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
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#f0f9ff"),
                    Color(hex: "#e0f2fe")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Modern Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sudoku")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color(hex: "#1e40af"))
                        }
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#64748b"))
                        }
                    }
                    
                    // MARK: - Level Selector with Modern Design
                    HStack(spacing: 12) {
                        ForEach(DifficultyLevel.allCases) { level in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    game.startNewGame(level: level)
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Text(level.icon)
                                        .font(.title2)
                                    Text(level.rawValue)
                                        .font(.caption.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(game.selectedLevel == level ?
                                              Color(hex: level.color) :
                                              Color.white.opacity(0.7))
                                        .shadow(color: game.selectedLevel == level ?
                                               Color(hex: level.color).opacity(0.4) :
                                               Color.black.opacity(0.05),
                                               radius: game.selectedLevel == level ? 8 : 2,
                                               y: game.selectedLevel == level ? 4 : 1)
                                )
                                .foregroundColor(game.selectedLevel == level ? .white : Color(hex: "#475569"))
                            }
                        }
                    }
                    
                    // MARK: - Game Status with Icon
                    HStack(spacing: 8) {
                        Image(systemName: game.gameStatus.contains("Congratulations") ? "checkmark.circle.fill" :
                              game.gameStatus.contains("incorrect") ? "xmark.circle.fill" : "play.circle.fill")
                            .foregroundColor(game.gameStatus.contains("Congratulations") ? Color(hex: "#16a34a") :
                                           game.gameStatus.contains("incorrect") ? Color(hex: "#dc2626") : Color(hex: "#3b82f6"))
                        
                        Text(game.gameStatus)
                            .font(.callout.weight(.medium))
                            .foregroundColor(game.gameStatus.contains("Congratulations") ? Color(hex: "#16a34a") :
                                           game.gameStatus.contains("incorrect") ? Color(hex: "#dc2626") : Color(hex: "#475569"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(game.gameStatus.contains("Congratulations") ? Color(hex: "#dcfce7") :
                                 game.gameStatus.contains("incorrect") ? Color(hex: "#fee2e2") : Color.white.opacity(0.6))
                    )
                }
                .padding()

                
                // MARK: - Enhanced Sudoku Grid
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
                                .border(width: (col + 1) % 3 == 0 && col != 8 ? 3 : 1,
                                       edges: [.trailing],
                                       color: Color(hex: "#1e40af"))
                            }
                        }
                        .border(width: (row + 1) % 3 == 0 && row != 8 ? 3 : 1,
                               edges: [.bottom],
                               color: Color(hex: "#1e40af"))
                    }
                }
                .background(Color(hex: "#1e40af"))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.15), radius: 12, y: 6)

                .padding(.bottom,10)
                

                
                // MARK: - Modern Number Pad
                if !game.isBoardFull {
                    ModernNumberPad(game: game)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                
                // MARK: - Action Buttons
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            game.startNewGame(level: game.selectedLevel)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title3)
                            Text("New Game")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#3b82f6"),
                                    Color(hex: "#2563eb")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "#3b82f6").opacity(0.4), radius: 8, y: 4)
                    }
                }
                .padding(.leading,10)
                .padding(.trailing,13)
                
            }
        }
        .onChange(of: game.gameStatus) { status in
            if status.contains("Congratulations") {
                showConfetti = true
            }
        }
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
                    .font(.system(size: 24, weight: cell.isEditable ? .semibold : .bold))
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
            return Color(hex: "#dc2626")
        }
        if cell.isEditable {
            return Color(hex: "#3b82f6")
        }
        return Color(hex: "#1e293b")
    }
    
    var backgroundColor: Color {
        if cell.isSelected {
            return Color(hex: "#fbbf24").opacity(0.9)
        }
        if isSameNumberAsSelected {
            return Color(hex: "#86efac").opacity(0.6)
        }
        if isInSameRowColBox {
            return Color(hex: "#e0e7ff").opacity(0.8)
        }
        return Color.white
    }
}

// MARK: - Modern Number Pad
struct ModernNumberPad: View {
    @ObservedObject var game: ReceiverSudokuGameVM
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...9, id: \.self) { number in
                    ModernNumberButton(number: number, game: game)
                }
                
                ModernClearButton(game: game)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

struct ModernNumberButton: View {
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
                .font(.title2.bold())
                .frame(width: 60, height: 60)
                .background(
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: isDisabled ?
                                        [Color(hex: "#cbd5e1"), Color(hex: "#94a3b8")] :
                                        [Color(hex: "#3b82f6"), Color(hex: "#2563eb")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: isDisabled ? Color.clear : Color(hex: "#3b82f6").opacity(0.4),
                                   radius: isPressed ? 2 : 6,
                                   y: isPressed ? 1 : 3)
                    }
                )
                .foregroundColor(.white)
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .disabled(isDisabled)
    }
}

struct ModernClearButton: View {
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
            Image(systemName: "eraser.fill")
                .font(.title2.bold())
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: isDisabled ?
                                    [Color(hex: "#cbd5e1"), Color(hex: "#94a3b8")] :
                                    [Color(hex: "#ef4444"), Color(hex: "#dc2626")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: isDisabled ? Color.clear : Color(hex: "#ef4444").opacity(0.4),
                               radius: isPressed ? 2 : 6,
                               y: isPressed ? 1 : 3)
                )
                .foregroundColor(.white)
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .disabled(isDisabled)
    }
}

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
        case .easy: return "#10b981"
        case .medium: return "#f59e0b"
        case .hard: return "#ef4444"
        }
    }
}

#Preview {
    ReceiverSudokuGameView()
}
