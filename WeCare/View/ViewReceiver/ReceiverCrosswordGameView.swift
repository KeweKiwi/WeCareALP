import SwiftUI
struct ReceiverCrosswordGameView: View {
    
    @StateObject private var viewModel = CrosswordViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Grid 10x10
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 10)
    
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
                    
                    // 3. Grid Area
                    // Tidak pakai border luar agar terlihat floating seperti Criss-Cross
                    crosswordGrid
                        .padding()
                        .aspectRatio(1, contentMode: .fit)
                    
                    // 4. Clues
                    ClueListView(across: viewModel.cluesAcross, down: viewModel.cluesDown)
                    
                    // 5. Action Buttons
                    actionButtons
                }
                .padding(.bottom, 100)
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
    
    private var crosswordGrid: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let cellSize = totalWidth / CGFloat(viewModel.numCols)
            
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(viewModel.grid.flatMap { $0 }) { cell in
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
    
    private var actionButtons: some View {
        HStack(spacing: 15) {
            Button(action: { viewModel.checkAnswers() }) {
                Text("Check")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#a6d17d"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: { viewModel.createPuzzle() }) {
                Text("Reset")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#fa6255"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
                
                // 2. Border Hitam Tegas (Agar terlihat seperti kotak teka-teki)
                Rectangle()
                    .stroke(Color.black, lineWidth: 1)
                
                // 3. Highlight jika dipilih
                if isSelected {
                    Rectangle()
                        .fill(Color.yellow.opacity(0.3))
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 2)
                }
                
                // 4. Nomor Petunjuk
                if let clueNo = cell.clueNumber {
                    Text("\(clueNo)")
                        .font(.system(size: size * 0.3, weight: .semibold, design: .serif))
                        .foregroundColor(.black)
                        .frame(width: size, height: size, alignment: .topLeading)
                        .padding(2)
                }
                
                // 5. Input Huruf
                Text(cell.input)
                    .font(.system(size: size * 0.6, weight: .bold, design: .serif))
                    .foregroundColor(cell.isCorrect ? Color(hex: "#66BB6A") : .black)
            } else {
                // JIKA BLOCKED: Transparan total
                Color.clear
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle()) // Memastikan tap gesture bekerja akurat
    }
}
// MARK: - Clue List View
struct ClueListView: View {
    let across: [String]
    let down: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Clues")
                .font(.title3.bold())
                .foregroundColor(.black)
            
            HStack(alignment: .top, spacing: 20) {
                // Across
                VStack(alignment: .leading, spacing: 8) {
                    Text("Across")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#4A90E2"))
                    ForEach(across, id: \.self) { clue in
                        Text(clue)
                            .font(.caption)
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Down
                VStack(alignment: .leading, spacing: 8) {
                    Text("Down")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#4A90E2"))
                    ForEach(down, id: \.self) { clue in
                        Text(clue)
                            .font(.caption)
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
}
struct KeyboardView: View {
    let onLetterTapped: (String) -> Void
    let onDeleteTapped: () -> Void
    let rows = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<rows.count, id: \.self) { i in
                HStack(spacing: 6) {
                    if i == 2 { Spacer() }
                    ForEach(Array(rows[i]), id: \.self) { char in
                        Button(action: { onLetterTapped(String(char)) }) {
                            Text(String(char))
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(width: 32, height: 44)
                                .background(Color.white)
                                .cornerRadius(4)
                                .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                        }
                    }
                    if i == 2 {
                        Button(action: onDeleteTapped) {
                            Image(systemName: "delete.left")
                                .foregroundColor(.red)
                                .frame(width: 42, height: 44)
                                .background(Color.white)
                                .cornerRadius(4)
                                .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
#Preview {
    ReceiverCrosswordGameView()
}
