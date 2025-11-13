import SwiftUI
// MARK: - 2048 Game View
struct ReceiverGame2048View: View {
    @StateObject var game = ReceiverGame2048VM()
    @Environment(\.dismiss) var dismiss
    
    let gridSize: CGFloat = 320 // Grid size
    let tileSpacing: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header & Back Button
            HStack {
                Text("2048 Game")
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
            
            // MARK: - Score and Status
            HStack {
                VStack(alignment: .leading) {
                    Text("SCORE")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(game.score)")
                        .font(.largeTitle.bold())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(Color(.systemGray5))
                .cornerRadius(10)
                
                Spacer()
                
                Text(game.gameStatus) // This will pull from the English Game2048.swift
                    .font(.headline)
                    .foregroundColor(game.isGameOver ? Color(hex: "#fa6255") : Color(hex: "#387b38"))
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal)
            
            // MARK: - Game Grid
            ZStack {
                // Background grid (empty cells)
                VStack(spacing: tileSpacing) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: tileSpacing) {
                            ForEach(0..<4, id: \.self) { _ in
                                EmptyCellView()
                            }
                        }
                    }
                }
                
                // Active tiles
                VStack(spacing: tileSpacing) {
                    ForEach(game.grid) { row in
                        HStack(spacing: tileSpacing) {
                            ForEach(row.cells) { cell in
                                TileView(tile: cell.tile)
                            }
                        }
                    }
                }
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: game.grid)
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            handleSwipe(gesture)
                        }
                )
            }
            .frame(width: gridSize, height: gridSize)
            .padding(tileSpacing)
            .background(Color(.systemGray3))
            .cornerRadius(10)
            Spacer()
            
            // MARK: - Start New Game Button
            Button("Start New Game") {
                game.startNewGame()
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
    
    // MARK: - Swipe Handler
    func handleSwipe(_ gesture: DragGesture.Value) {
        let horizontal = gesture.translation.width
        let vertical = gesture.translation.height
        
        // Determine swipe direction
        if abs(horizontal) > abs(vertical) {
            // Horizontal Swipe
            game.move(horizontal > 0 ? .right : .left)
        } else {
            // Vertical Swipe
            game.move(vertical > 0 ? .down : .up)
        }
    }
}
// MARK: - 2048 UI Components
struct EmptyCellView: View {
    let size: CGFloat = (320 - 8*5) / 4 // 320 = gridSize, 8 = spacing
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: size, height: size)
    }
}
struct TileView: View {
    let tile: Tile?
    let size: CGFloat = (320 - 8*5) / 4
    
    var body: some View {
        Group {
            if let tile = tile {
                RoundedRectangle(cornerRadius: 8)
                    .fill(tileColor(value: tile.value))
                    .overlay(
                        Text("\(tile.value)")
                            .font(tile.value < 1000 ? .largeTitle : .title)
                            .fontWeight(.heavy)
                            .foregroundColor(tile.value < 8 ? .black : .white)
                            .minimumScaleFactor(0.5)
                    )
            } else {
                EmptyCellView()
            }
        }
        .frame(width: size, height: size)
    }
    
    // Color scheme (consistent theme)
    func tileColor(value: Int) -> Color {
        switch value {
        case 2: return Color(hex: "#fdcb46").opacity(0.6)
        case 4: return Color(hex: "#fdcb46")
        case 8: return Color.orange.opacity(0.7)
        case 16: return Color.orange
        case 32: return Color(hex: "#fa6255").opacity(0.7)
        case 64: return Color(hex: "#fa6255")
        case 128: return Color(hex: "#387b38").opacity(0.7)
        case 256: return Color(hex: "#387b38")
        case 512: return Color(hex: "#387b38").opacity(0.9)
        case 1024: return Color(hex: "#387b38")
        case 2048: return Color.black // Win!
        default: return Color.red // Higher numbers
        }
    }
}
// Preview
#Preview {
    ReceiverGame2048View()
}



