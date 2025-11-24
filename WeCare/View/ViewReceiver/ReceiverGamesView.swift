import SwiftUI
// MARK: - TAB 4: Games View
struct ReceiverGamesView: View {
    
    // Relaxing game recommendations (static data stored within the View)
    let recommendedGames = [
        GameRecommendation(
            title: "Classic Solitaire",
            description: "A card game of strategy and patience, great for focus.",
            icon: "suit.club.fill",
            color: Color(hex: "#a6d17d")
        ),
        GameRecommendation(
            title: "Daily Crossword",
            description: "Trains vocabulary and long-term memory.",
            icon: "square.grid.3x3.fill",
            color: Color(hex: "#fdcb46")
        ),
        GameRecommendation(
            title: "Matching Pictures (Memory)",
            description: "Improves memory and visual concentration.",
            icon: "rectangle.stack.fill",
            color: Color(hex: "#91bef8")
        ),
        GameRecommendation(
            title: "Relaxing Sudoku",
            description: "Simple and fun logic game to fill your free time.",
            icon: "number.square.fill",
            color: Color(hex: "#fa6255")
        )
    ]
    
    // State for presenting Sudoku
    @State private var isShowingSudoku = false
    
    // State for presenting Memory Game
    @State private var isShowingMemory = false
    
    // State for presenting Crossword Game (BARU DITAMBAHKAN)
    @State private var isShowingCrossword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("🎮 Games")
                        .font(.largeTitle.bold())
                        .padding([.horizontal, .top])
                    
                    Text("Choose a game to relax and keep your mind sharp.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // Game Recommendations List
                    VStack(spacing: 15) {
                        ForEach(recommendedGames) { game in
                            
                            // Logic: Check game title to open correct view
                            
                            if game.title == "Relaxing Sudoku" {
                                Button(action: {
                                    isShowingSudoku = true
                                }) {
                                    GameCard(game: game)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                            } else if game.title == "Matching Pictures (Memory)" {
                                Button(action: {
                                    isShowingMemory = true
                                }) {
                                    GameCard(game: game)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                            } else if game.title == "Daily Crossword" {
                                // --- LOGIKA BARU UNTUK CROSSWORD ---
                                Button(action: {
                                    isShowingCrossword = true
                                }) {
                                    GameCard(game: game)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                            } else {
                                // Other games (simulated, just showing the card without action)
                                GameCard(game: game)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("✨ Note: Tap the game cards to start playing.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                }
                .padding(.vertical, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
        // Sheet for Sudoku
        .fullScreenCover(isPresented: $isShowingSudoku) {
            ReceiverSudokuGameView()
        }
        // Sheet for Memory Game
        .fullScreenCover(isPresented: $isShowingMemory) {
            ReceiverMemoryGameView()
        }
        // Sheet for Crossword Game (BARU DITAMBAHKAN)
        .fullScreenCover(isPresented: $isShowingCrossword) {
            ReceiverCrosswordGameView()
        }
    }
}
// MARK: - Game Components
struct GameCard: View {
    let game: GameRecommendation
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: game.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.white)
                .padding(15)
                .background(game.color)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(game.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(game.color)
                .font(.title)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
#Preview {
    ReceiverGamesView()
}
