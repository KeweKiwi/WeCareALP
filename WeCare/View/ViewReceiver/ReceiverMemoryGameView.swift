import SwiftUI
struct ReceiverMemoryGameView: View {
    @StateObject var game = ReceiverMemoryGameVM()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDifficulty: Difficulty = .easy
    
    // Grid layout
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 15), count: 4)
    
    var body: some View {
        ZStack {
            // 1. BACKGROUND: Off-White Gradient (Supaya tidak flat membosankan)
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#F5F7FA"), Color(hex: "#C3CFE2")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // MARK: - HEADER AREA
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Text("Memory Check")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "#2C3E50"))
                    
                    Spacer()
                    
                    // Moves Badge
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                            .font(.caption)
                        Text("\(game.moves)")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .foregroundColor(Color(hex: "#2C3E50"))
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - DIFFICULTY SELECTOR (Glassmorphism Style)
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
                .padding(5)
                .background(Color.white.opacity(0.6)) // Semi transparan
                .cornerRadius(12)
                .padding(.horizontal)
                .onChange(of: selectedDifficulty) { newDifficulty in
                    withAnimation {
                        game.startNewGame(difficulty: newDifficulty)
                    }
                }
                
                // MARK: - GAME BOARD (Area Putih Utama)
                VStack {
                    // Status Text
                    Text(game.gameStatus)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(game.isGameOver ? .green : .secondary)
                        .padding(.top, 10)
                        .animation(.easeInOut, value: game.gameStatus)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(game.cards) { card in
                                ZStack {
                                    CardView(card: card)
                                        .aspectRatio(2/3, contentMode: .fit)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                                game.choose(card)
                                            }
                                        }
                                    
                                    if card.isMatched {
                                        GoldSparklesView()
                                    }
                                }
                            }
                        }
                        .padding(20)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        // Shadow lembut di sekeliling board agar terlihat "melayang"
                        .shadow(color: Color(hex: "#2C3E50").opacity(0.1), radius: 15, x: 0, y: 10)
                )
                .padding(.horizontal)
                
                // MARK: - RESTART BUTTON
                Button(action: {
                    withAnimation {
                        game.startNewGame(difficulty: selectedDifficulty)
                    }
                }) {
                    Text("Restart Game")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#FF8008"), Color(hex: "#FFC837")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
    }
}
// MARK: - CARD VIEW (Modern Look)
struct CardView: View {
    let card: MemoryCard
    
    var rotation: Double {
        (card.isFaceUp || card.isMatched) ? 0 : 180
    }
    
    var body: some View {
        ZStack {
            // SISI DEPAN (EMOJI)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                // Inner Shadow effect untuk kedalaman
                .shadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .overlay(
                    Text(card.content)
                        .font(.system(size: 38))
                        .opacity(card.isMatched ? 0.5 : 1)
                        .scaleEffect(card.isMatched ? 1.2 : 1)
                )
                .opacity((card.isFaceUp || card.isMatched) ? 1 : 0)
            
            // SISI BELAKANG (GRADIENT MODERN HIJAU)
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#43e97b"), Color(hex: "#38f9d7")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "#43e97b").opacity(0.4), radius: 4, x: 0, y: 4)
                
                Image(systemName: "leaf.fill") // Ikon daun agar lebih natural/fresh
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
            .opacity((card.isFaceUp || card.isMatched) ? 0 : 1)
        }
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .allowsHitTesting(!card.isMatched)
    }
}
// MARK: - SPARKLES (Sama seperti sebelumnya)
struct GoldSparklesView: View {
    @State private var isAnimating = false
    private let particleCount = 12
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "#FFD700"))
                    .offset(x: isAnimating ? .random(in: -35...35) : 0,
                            y: isAnimating ? .random(in: -35...35) : 0)
                    .scaleEffect(isAnimating ? .random(in: 0.5...1.0) : 0.1)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 1.0)
                            .repeatForever(autoreverses: false)
                            .delay(.random(in: 0.0...0.3)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
// Preview
#Preview {
    ReceiverMemoryGameView()
}
