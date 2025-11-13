import SwiftUI
// MARK: - Memory Game View (Accessed from GamesView)
struct ReceiverMemoryGameView: View {
    @StateObject var game = ReceiverMemoryGameVM()
    @Environment(\.dismiss) var dismiss
    
    // BARU: State untuk melacak kesulitan yang dipilih
    @State private var selectedDifficulty: Difficulty = .easy
    
    // 4-column grid layout (tetap 4 kolom, jumlah baris akan bertambah)
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header & Back Button
            HStack {
                Text("Memory Check")
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
            
            // MARK: - Status Info
            HStack {
                Text("Moves: **\(game.moves)**")
                    .font(.title2)
                Spacer()
                Text(game.gameStatus)
                    .font(.title3)
            }
            .padding(.horizontal)
            
            // MARK: - BARU: Difficulty Selector
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(Difficulty.allCases) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: selectedDifficulty) { newDifficulty in
                // Jika user ganti level, mulai game baru
                withAnimation {
                    game.startNewGame(difficulty: newDifficulty)
                }
            }
            
            // MARK: - Game Grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(game.cards) { card in
                    
                    ZStack {
                        // 1. Kartu itu sendiri (akan dissolve/fade-out)
                        CardView(card: card)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    game.choose(card)
                                }
                            }
                            .opacity(card.isMatched ? 0 : 1)
                            .animation(.easeOut(duration: 0.5), value: card.isMatched)
                        
                        // 2. Efek "Bertabur Emas"
                        if card.isMatched {
                            GoldSparklesView()
                                .transition(.opacity.animation(.easeOut(duration: 1.0)))
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - New Game Button
            Button("Start New Game") {
                // DIMODIFIKASI: Mulai game baru dengan kesulitan yang dipilih
                withAnimation {
                    game.startNewGame(difficulty: selectedDifficulty)
                }
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
// MARK: - Component: CardView (Tidak berubah)
struct CardView: View {
    let card: MemoryCard
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 15)
            
            if card.isFaceUp || card.isMatched {
                // View when the card is face-up
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(Color(hex: "#387b38"), lineWidth: 4)
                Text(card.content)
                    .font(.system(size: 45)) // Large emoji
            } else {
                // Back side of the card
                shape.fill(Color(hex: "#387b38")) // Dark green color
            }
        }
    }
}
// MARK: - EFEK BARU: Gold Sparkles (Tidak berubah)
struct GoldSparklesView: View {
    @State private var isAnimating = false
    private let particleCount = 12 // Jumlah partikel
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { _ in
                Image(systemName: "sparkle.fill")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#fdcb46"))
                    .offset(x: isAnimating ? .random(in: -50...50) : 0,
                            y: isAnimating ? .random(in: -50...50) : 0)
                    .scaleEffect(isAnimating ? .random(in: 1.0...1.5) : 0.5)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 0.8)
                            .delay(.random(in: 0.1...0.3)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
#Preview {
    ReceiverMemoryGameView()
}

