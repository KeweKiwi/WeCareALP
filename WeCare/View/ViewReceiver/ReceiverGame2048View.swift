import SwiftUI
struct ReceiverGame2048View: View {
    @StateObject private var vm = ReceiverGame2048VM()
    @Environment(\.dismiss) var dismiss
    
    private let spacing: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 16) {
            header
            scoreAndStatus
            gameBoard
            Spacer()
            newGameButton
        }
        .padding(.top, 10)
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
// MARK: - Header
extension ReceiverGame2048View {
    private var header: some View {
        HStack {
            Text("2048 Game")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "#387b38"))
            Spacer()
            Button("Back") { dismiss() }
                .font(.title3.bold())
                .foregroundColor(.black)
                .padding(8)
                .background(Color(hex: "#fdcb46"))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
// MARK: - Score & Status
extension ReceiverGame2048View {
    private var scoreAndStatus: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("SCORE")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("\(vm.score)")
                    .font(.largeTitle.bold())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            Spacer()
            
            Text(vm.gameStatus)
                .font(.headline)
                .foregroundColor(vm.isGameOver ? Color(hex: "#fa6255") : Color(hex: "#387b38"))
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal)
    }
}
extension ReceiverGame2048View {
    private var gameBoard: some View {
        GeometryReader { proxy in
            let gridWidth = proxy.size.width - 32
            let tileSize = (gridWidth - spacing * 5) / 4
            
            ZStack {
                backgroundGrid(gridWidth: gridWidth, tileSize: tileSize)
                tilesLayer(gridWidth: gridWidth, tileSize: tileSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded(handleSwipe)
            )
        }
        .frame(height: 360)
        .padding(.horizontal)
    }
}
// MARK: Background Grid
extension ReceiverGame2048View {
    private func backgroundGrid(gridWidth: CGFloat, tileSize: CGFloat) -> some View {
        VStack(spacing: spacing) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: spacing) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: tileSize, height: tileSize)
                    }
                }
            }
        }
        .padding(spacing)
        .background(Color(.systemGray3))
        .cornerRadius(12)
    }
}
// MARK: Tiles Layer
extension ReceiverGame2048View {
    private func tilesLayer(gridWidth: CGFloat, tileSize: CGFloat) -> some View {
        let originX: CGFloat = 16
        let originY: CGFloat = 8
        
        return ZStack {
            ForEach(vm.tiles) { tile in
                TileView(tile: tile, size: tileSize)
                    .frame(width: tileSize, height: tileSize)
                    .position(
                        x: originX + spacing + tileSize / 2 + CGFloat(tile.col) * (tileSize + spacing),
                        y: originY + spacing + tileSize / 2 + CGFloat(tile.row) * (tileSize + spacing)
                    )
                    .animation(.easeInOut(duration: 0.16), value: vm.tiles)
            }
        }
    }
}
// MARK: Tile UI
struct TileView: View {
    let tile: TileModel
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tileColor(value: tile.value))
            .overlay(
                Text("\(tile.value)")
                    .font(.system(size: size * 0.42, weight: .heavy))
                    .foregroundColor(tile.value < 8 ? .black : .white)
                    .minimumScaleFactor(0.4)
            )
            .shadow(radius: 1)
    }
    
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
        case 2048: return Color.black
        default: return Color.red
        }
    }
}
// MARK: New Game Button
extension ReceiverGame2048View {
    private var newGameButton: some View {
        Button("Start New Game") { vm.startNewGame() }
            .font(.title2.bold())
            .padding(15)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#fa6255"))
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding(.horizontal)
    }
}
// MARK: Swipe Handler
extension ReceiverGame2048View {
    private func handleSwipe(_ gesture: DragGesture.Value) {
        let h = gesture.translation.width
        let v = gesture.translation.height
        
        if abs(h) > abs(v) {
            vm.move(h > 0 ? .right : .left)
        } else {
            vm.move(v > 0 ? .down : .up)
        }
    }
}
// Preview
#Preview {
    ReceiverGame2048View()
}

