import SwiftUI


struct ReceiverMemoryGameView: View {
    @StateObject var game = ReceiverMemoryGameVM()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDifficulty: Difficulty = .easy
    @FocusState private var isFocused: Bool
    
    private var columns: [GridItem] {
        let count = selectedDifficulty == .hard ? 5 : 4
        return Array(repeating: .init(.flexible(), spacing: cardSpacing), count: count)
    }
    
    private var cardSpacing: CGFloat {
        selectedDifficulty == .hard ? 8 : 12
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: selectedDifficulty == .hard ? 8 : 12) {
                header
                statsRow
                difficultyPicker
                gameBoard
                Spacer(minLength: 4)
                restartButton
            }
            .padding(.top, 8)
        }
        .focusable()
        .focused($isFocused)
        .onAppear { isFocused = true }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}


extension ReceiverMemoryGameView {
    private var header: some View {
        HStack {
            Color.clear.frame(width: 90)
            
            Spacer()
            
            Text("Memory Game")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(Color(hex: "#f67c5f"))
            
            Spacer()
            
            Button { dismiss() } label: {
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


extension ReceiverMemoryGameView {
    private var statsRow: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: selectedDifficulty == .hard ? 2 : 4) {
                Text("MOVES")
                    .font(.system(size: selectedDifficulty == .hard ? 10 : 12, weight: .bold))
                    .foregroundColor(Color(hex: "#f67c5f"))
                    .tracking(1)
                
                Text("\(game.moves)")
                    .font(.system(size: selectedDifficulty == .hard ? 20 : 32, weight: .black))
                    .foregroundColor(Color(hex: "#f67c5f"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: selectedDifficulty == .hard ? 50 : 80)
            .padding(selectedDifficulty == .hard ? 10 : 16)
            .background(Color(hex: "#fff9e6"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
            
            VStack(alignment: .trailing, spacing: selectedDifficulty == .hard ? 2 : 4) {
                Text("STATUS")
                    .font(.system(size: selectedDifficulty == .hard ? 10 : 12, weight: .bold))
                    .foregroundColor(Color(hex: "#f67c5f"))
                    .tracking(1)
                
                Text(game.gameStatus)
                    .font(.system(size: selectedDifficulty == .hard ? 12 : 16, weight: .bold))
                    .foregroundColor(game.isGameOver ? Color(hex: "#edcf72") : Color(hex: "#776e65"))
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(minHeight: selectedDifficulty == .hard ? 50 : 80)
            .padding(selectedDifficulty == .hard ? 10 : 16)
            .background(Color(hex: "#fff9e6"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        }
        .padding(.horizontal, 24)
    }
}


extension ReceiverMemoryGameView {
    private var difficultyPicker: some View {
        Picker("Difficulty", selection: $selectedDifficulty) {
            ForEach(Difficulty.allCases) { difficulty in
                Text(difficulty.rawValue).tag(difficulty)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 24)
        .onChange(of: selectedDifficulty) { newDifficulty in
            withAnimation { game.startNewGame(difficulty: newDifficulty) }
        }
    }
}


extension ReceiverMemoryGameView {
    private var gameBoard: some View {
        let columnCount = selectedDifficulty == .hard ? 5 : 4
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: cardSpacing), count: columnCount)
        
        return LazyVGrid(columns: gridColumns, spacing: cardSpacing) {
            ForEach(game.cards) { card in
                ZStack {
                    CardView(card: card, isHardMode: selectedDifficulty == .hard)
                        .aspectRatio(2/3, contentMode: .fit)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                game.choose(card)
                            }
                        }
                    
                    if card.isMatched {
                        GoldSparklesView()
                    }
                }
            }
        }
        .padding(selectedDifficulty == .hard ? 12 : (selectedDifficulty == .medium ? 18 : 20))
        .background(Color(hex: "#fff9e6"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 12, y: 4)
        .padding(.horizontal, 24)
    }
}


extension ReceiverMemoryGameView {
    private var restartButton: some View {
        Button {
            withAnimation { game.startNewGame(difficulty: selectedDifficulty) }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: selectedDifficulty == .hard ? 16 : 18, weight: .bold))
                Text("Restart Game")
                    .font(.system(size: selectedDifficulty == .hard ? 16 : 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, selectedDifficulty == .hard ? 12 : 16)
            .background(Color(hex: "#f67c5f"))
            .cornerRadius(16)
            .shadow(color: Color(hex: "#f67c5f").opacity(0.4), radius: 8, y: 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}


struct CardView: View {
    let card: MemoryCard
    let isHardMode: Bool
    
    var rotation: Double { (card.isFaceUp || card.isMatched) ? 180 : 0 }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isHardMode ? 10 : 14)
                .fill(Color.white)
                .overlay(
                    Text(card.content)
                        .font(.system(size: isHardMode ? 32 : 42))
                        .opacity(card.isMatched ? 0.6 : 1)
                        .scaleEffect(card.isMatched ? 1.15 : 1)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                )
                .opacity((card.isFaceUp || card.isMatched) ? 1 : 0)
            
            RoundedRectangle(cornerRadius: isHardMode ? 10 : 14)
                .fill(Color(hex: "#edc53f"))
                .overlay(
                    Image(systemName: "questionmark")
                        .font(.system(size: isHardMode ? 22 : 28, weight: .bold))
                        .foregroundColor(.white)
                )
                .opacity((card.isFaceUp || card.isMatched) ? 0 : 1)
        }
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .allowsHitTesting(!card.isMatched)
    }
}


struct GoldSparklesView: View {
    @State private var isAnimating = false
    private let particleCount = 12
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "#edcf72"))
                    .offset(
                        x: isAnimating ? .random(in: -35...35) : 0,
                        y: isAnimating ? .random(in: -35...35) : 0
                    )
                    .scaleEffect(isAnimating ? .random(in: 0.5...1.0) : 0.1)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 1)
                            .repeatForever(autoreverses: false)
                            .delay(.random(in: 0...0.3)),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}


#Preview {
    ReceiverMemoryGameView()
}
