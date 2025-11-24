import SwiftUI

struct ReceiverCrosswordGameView: View {
    
    @StateObject private var viewModel = CrosswordViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            headerView
            
            ScrollView {
                VStack(spacing: 20) {
                    // 2. Status Text
                    Text(viewModel.gameStatus)
                        .font(.headline)
                        .foregroundColor(viewModel.isPuzzleSolved ? .green : .secondary)
                        .padding(.top, 10)
                    
                    // 3. Grid Area - FIXED VERSION
                    crosswordGridFixed
                        .padding(.horizontal)
                    
                    // 4. Clues
                    ClueListView(across: viewModel.cluesAcross, down: viewModel.cluesDown)
                    
                    // 5. Action Buttons
                    actionButtons
                }
                .padding(.bottom, 20)
            }
            
            // 6. Keyboard
            customKeyboard
                .background(Color(.systemGray6))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // MARK: - Sub-Views
    
    private var headerView: some View {
        HStack {
            Text("General Puzzle")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(Color.black)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
    
    // FIXED: Menggunakan pendekatan yang lebih stabil
    private var crosswordGridFixed: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let cellSize = availableWidth / CGFloat(viewModel.numCols)
            let totalHeight = cellSize * CGFloat(viewModel.numRows)
            
            VStack(spacing: 0) {
                ForEach(0..<viewModel.numRows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<viewModel.numCols, id: \.self) { col in
                            let cell = viewModel.grid[row][col]
                            CrosswordCellView(
                                cell: cell,
                                isSelected: cell.id == viewModel.selectedCellID,
                                size: cellSize
                            )
                            .onTapGesture {
                                viewModel.selectCell(cell)
                            }
                        }
                    }
                }
            }
            .frame(width: availableWidth, height: totalHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: UIScreen.main.bounds.width - 32) // Fixed height based on screen width
    }
    
    private var actionButtons: some View {
        HStack(spacing: 15) {
            Button(action: { viewModel.checkAnswers() }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Check")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#a6d17d"),
                            Color(hex: "#8bc34a")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color(hex: "#a6d17d").opacity(0.4), radius: 6, y: 3)
            }
            
            Button(action: { viewModel.createPuzzle() }) {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                    Text("Reset")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#fa6255"),
                            Color(hex: "#ef4444")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color(hex: "#fa6255").opacity(0.4), radius: 6, y: 3)
            }
        }
        .padding(.horizontal)
    }
    
    private var customKeyboard: some View {
        KeyboardView(
            onLetterTapped: { viewModel.inputLetter($0) },
            onDeleteTapped: { viewModel.deleteLetter() }
        )
        .padding(.bottom, 20)
        .padding(.top, 10)
    }
}

// MARK: - Visual Kotak (Criss-Cross Style)
struct CrosswordCellView: View {
    let cell: CrosswordCell
    let isSelected: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // HANYA gambar jika sel memiliki jawaban (bukan blocked)
            if !cell.isBlocked {
                // 1. Background Putih
                Rectangle()
                    .fill(Color.white)
                
                // 2. Border Hitam Tegas
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5)
                
                // 3. Highlight jika dipilih
                if isSelected {
                    Rectangle()
                        .fill(Color(hex: "#fef08a").opacity(0.5))
                    Rectangle()
                        .stroke(Color(hex: "#3b82f6"), lineWidth: 3)
                }
                
                // 4. Nomor Petunjuk
                if let clueNo = cell.clueNumber {
                    Text("\(clueNo)")
                        .font(.system(size: max(8, size * 0.25), weight: .semibold, design: .serif))
                        .foregroundColor(.black)
                        .frame(width: size, height: size, alignment: .topLeading)
                        .padding(2)
                }
                
                // 5. Input Huruf
                Text(cell.input)
                    .font(.system(size: max(14, size * 0.55), weight: .bold, design: .serif))
                    .foregroundColor(cell.isCorrect ? Color(hex: "#16a34a") : .black)
                    .frame(width: size, height: size)
            } else {
                // JIKA BLOCKED: Transparan total
                Color.clear
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
    }
}

// MARK: - Clue List View
struct ClueListView: View {
    let across: [String]
    let down: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Clues")
                .font(.title2.bold())
                .foregroundColor(.black)
            
            HStack(alignment: .top, spacing: 15) {
                // Across
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color(hex: "#3b82f6"))
                        Text("Across")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#3b82f6"))
                    }
                    
                    ForEach(across, id: \.self) { clue in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .foregroundColor(Color(hex: "#3b82f6"))
                            Text(clue)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#dbeafe").opacity(0.5))
                )
                
                // Down
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color(hex: "#10b981"))
                        Text("Down")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#10b981"))
                    }
                    
                    ForEach(down, id: \.self) { clue in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .foregroundColor(Color(hex: "#10b981"))
                            Text(clue)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#d1fae5").opacity(0.5))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

// MARK: - Keyboard View
struct KeyboardView: View {
    let onLetterTapped: (String) -> Void
    let onDeleteTapped: () -> Void
    let rows = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { i in
                HStack(spacing: 5) {
                    if i == 2 { Spacer() }
                    ForEach(Array(rows[i]), id: \.self) { char in
                        Button(action: { onLetterTapped(String(char)) }) {
                            Text(String(char))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 34, height: 46)
                                .background(Color.white)
                                .cornerRadius(6)
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        }
                    }
                    if i == 2 {
                        Button(action: onDeleteTapped) {
                            Image(systemName: "delete.left.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 46)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#ef4444"),
                                            Color(hex: "#dc2626")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(6)
                                .shadow(color: Color(hex: "#ef4444").opacity(0.4), radius: 3, y: 2)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ReceiverCrosswordGameView()
}
