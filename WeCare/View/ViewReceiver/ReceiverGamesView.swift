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
                            
                            // Logic: If the game is Sudoku, show a button that triggers a sheet
                            if game.title == "Relaxing Sudoku" {
                                Button(action: {
                                    isShowingSudoku = true // Main action: show SudokuView
                                }) {
                                    GameCard(game: game) // Card view
                                }
                                .buttonStyle(PlainButtonStyle()) // Ensures the card looks like a normal tile
                                
                            } else if game.title == "Matching Pictures (Memory)" {
                                Button(action: {
                                    isShowingMemory = true // Show Memory Game View
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
                    
                    Text("✨ Note: Tap the Sudoku card to start playing.")
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
        // MODIFICATION: Adding sheet presentation for SudokuView
        .sheet(isPresented: $isShowingSudoku) {
            ReceiverSudokuGameView()
        }
        // Sheet for Memory Game
        .sheet(isPresented: $isShowingMemory) {
            ReceiverMemoryGameView()
        }
    }
}
// MARK: - Game Components (Add this if not stored in a separate file)
// Ensure the GameRecommendation model exists in your Models.swift
/*
struct GameRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}
*/
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

