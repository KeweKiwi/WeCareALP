import SwiftUI

struct ReceiverCrosswordGameView: View {
    // Menghubungkan ke ViewModel yang baru
    @StateObject private var viewModel = ReceiverCrosswordViewModel()
    
    @Environment(\.dismiss) var dismiss
    @FocusState private var isKeyboardFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            headerView
            
            ScrollView {
                VStack(spacing: 16) {
                    gameStatus
                    crosswordGrid
                    hiddenKeyboardTextField
                    cluesList
                    actionButtons
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            // Pastikan keyboard siap saat muncul (opsional)
            isKeyboardFocused = true
        }
    }
    
    
    // MARK: - HEADER
    private var headerView: some View {
        HStack {
            Text("Crossword")
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
        .padding(.vertical, 12)
        .background(.white)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    
    // MARK: - GAME STATUS
    private var gameStatus: some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.isPuzzleSolved ? "checkmark.circle.fill" : "gamecontroller.fill")
                .font(.system(size: 20))
                .foregroundColor(viewModel.isPuzzleSolved ? Color(hex: "#edcf72") : Color(hex: "#edc53f"))
            
            Text(viewModel.gameStatus)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#776e65"))
                // Animasi kecil saat status berubah
                .animation(.easeInOut, value: viewModel.gameStatus)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(hex: "#fff9e6"))
        .cornerRadius(14)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }
    
    
    // MARK: - CROSSWORD GRID
    private var crosswordGrid: some View {
        let gridSize = UIScreen.main.bounds.width - 48
        let cellSize = gridSize / CGFloat(viewModel.numCols)
        
        return VStack(spacing: 0) {
            ForEach(0..<viewModel.numRows, id: \.self) { r in
                HStack(spacing: 0) {
                    ForEach(0..<viewModel.numCols, id: \.self) { c in
                        CrosswordCellView(
                            cell: viewModel.grid[r][c],
                            isSelected: viewModel.grid[r][c].id == viewModel.selectedCellID,
                            size: cellSize
                        ) {
                            viewModel.selectCell(viewModel.grid[r][c])
                            isKeyboardFocused = true
                        }
                    }
                }
            }
        }
        .frame(width: gridSize)
        .background(Color(hex: "#bbada0"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.horizontal, 24)
    }
    
    
    // MARK: - HIDDEN KEYBOARD INPUT
    private var hiddenKeyboardTextField: some View {
        // TextField tersembunyi untuk menangkap input keyboard
        TextField("", text: selectedCellBinding)
            .keyboardType(.alphabet)
            .textInputAutocapitalization(.characters)
            .disableAutocorrection(true)
            .focused($isKeyboardFocused)
            .opacity(0.01) // Invisible tapi bisa diklik/fokus
            .frame(width: 1, height: 1)
    }
    
    // Binding manual untuk menghubungkan TextField ke Cell yang dipilih
    private var selectedCellBinding: Binding<String> {
        Binding(
            get: {
                guard let id = viewModel.selectedCellID else { return "" }
                // Cari cell berdasarkan ID
                for r in 0..<viewModel.numRows {
                    for c in 0..<viewModel.numCols {
                        if viewModel.grid[r][c].id == id {
                            return viewModel.grid[r][c].input
                        }
                    }
                }
                return ""
            },
            set: { newVal in
                guard let id = viewModel.selectedCellID else { return }
                
                // Ambil huruf terakhir saja (agar input 1 karakter)
                let upper = newVal.uppercased()
                let letters = upper.filter { $0.isLetter }
                let finalChar = letters.last.map { String($0) } ?? ""
                
                // Update grid
                for r in 0..<viewModel.numRows {
                    for c in 0..<viewModel.numCols {
                        if viewModel.grid[r][c].id == id {
                            viewModel.grid[r][c].input = finalChar
                            return
                        }
                    }
                }
            }
        )
    }
    
    
    // MARK: - CLUES LIST
    private var cluesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Clues")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#776e65"))
            
            HStack(alignment: .top, spacing: 12) {
                
                // Clues Mendatar
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(Color(hex: "#f2b179"))
                        Text("Across")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#776e65"))
                    }
                    ForEach(viewModel.cluesAcross, id: \.self) { clue in
                        HStack(spacing: 6) {
                            Text("•").foregroundColor(Color(hex: "#f2b179"))
                            Text(clue)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#776e65"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#fff9e6"))
                .cornerRadius(12)
                
                // Clues Menurun
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(Color(hex: "#edcf72"))
                        Text("Down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#776e65"))
                    }
                    ForEach(viewModel.cluesDown, id: \.self) { clue in
                        HStack(spacing: 6) {
                            Text("•").foregroundColor(Color(hex: "#edcf72"))
                            Text(clue)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#776e65"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#fff9e6"))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .padding(.horizontal, 24)
    }
    
    
    // MARK: - ACTION BUTTONS
    private var actionButtons: some View {
        HStack(spacing: 12) {
            
            Button {
                viewModel.checkAnswers()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Check")
                }
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "#edcf72"))
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            
            Button {
                viewModel.createPuzzle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Reset")
                }
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "#f67c5f"))
                .foregroundColor(.white)
                .cornerRadius(16)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - CROSSWORD CELL VIEW

struct CrosswordCellView: View {
    let cell: CrosswordCell
    let isSelected: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            if !cell.isBlocked {
                // Background Box
                Rectangle()
                    .fill(isSelected ? Color(hex: "#ffe9a3") : .white)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                
                // Border
                Rectangle()
                    .stroke(Color(hex: "#bbada0"), lineWidth: 1)
                
                // Nomor Clue (kecil di pojok)
                if let n = cell.clueNumber {
                    Text("\(n)")
                        .font(.system(size: max(8, size * 0.25), weight: .semibold))
                        .foregroundColor(Color(hex: "#776e65"))
                        .frame(width: size, height: size, alignment: .topLeading)
                        .padding(2)
                }
                
                // Input Text
                Text(cell.input)
                    .font(.system(size: max(14, size * 0.55), weight: .bold))
                    // Warna teks: Hijau jika benar, Merah jika salah (setelah dicek), Default abu
                    .foregroundColor(getCellTextColor())
            } else {
                // Blocked Cell
                Color(hex: "#bbada0")
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    // Logic warna text agar user tau mana yang benar/salah secara visual
    private func getCellTextColor() -> Color {
        if cell.isCorrect {
            return .green // Benar
        } else if !cell.input.isEmpty && cell.input != cell.answer && isCheckedAttempted() {
           // Opsional: Anda bisa membuatnya merah jika ingin feedback langsung salah
           // return .red
        }
        return Color(hex: "#776e65") // Default
    }
    
    // Helper sederhana untuk mendeteksi apakah cell pernah dicek (diasumsikan dari status isCorrect yang defaultnya false)
    private func isCheckedAttempted() -> Bool {
        // Logika sederhana: jika user sudah isi tapi isCorrect masih false,
        // kita biarkan warna default sampai user menekan tombol Check yang memperbarui state.
        return false
    }
}


#Preview {
    ReceiverCrosswordGameView()
}
