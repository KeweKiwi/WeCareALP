import SwiftUI


struct ReceiverGame2048View: View {
    @StateObject private var vm = ReceiverGame2048VM()
    @Environment(\.dismiss) var dismiss
    
    private let spacing: CGFloat = 10
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            header
            scoreAndStatus
            gameBoard
            Spacer()
            newGameButton
        }
        .padding(.top, 10)
        .background(Color.white.ignoresSafeArea())
        .focusable()
        .focused($isFocused)
        .onAppear {
            isFocused = true
        }
        .onKeyPress { press in
            switch press.key {
            case .leftArrow:
                vm.move(.left)
                return .handled
            case .rightArrow:
                vm.move(.right)
                return .handled
            case .upArrow:
                vm.move(.up)
                return .handled
            case .downArrow:
                vm.move(.down)
                return .handled
            default:
                return .ignored
            }
        }
    }
}


// MARK: - Header
extension ReceiverGame2048View {
    private var header: some View {
        HStack {
            Text("2048")
                .font(.system(size: 42, weight: .black))
                .foregroundColor(Color(hex: "#fa6255"))
            
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
                .background(Color(hex: "#fa6255"))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
}


// MARK: - Score & Status
extension ReceiverGame2048View {
    private var scoreAndStatus: some View {
        HStack(spacing: 12) {
            // Score Card
            VStack(alignment: .leading, spacing: 4) {
                Text("SCORE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#fa6255"))
                    .tracking(1)
                
                Text("\(vm.score)")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(Color(hex: "#fa6255"))
            }
            .frame(minWidth: 100, alignment: .leading)
            .padding(16)
            .background(Color(hex: "#fff9e6"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
            
            Spacer()
            
            // Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(vm.gameStatus)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(vm.isGameOver ? Color(hex: "#fa6255") : Color(hex: "#a6d17d"))
                    .multilineTextAlignment(.trailing)
                
                if !vm.isGameOver {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Image(systemName: "arrow.right")
                        Image(systemName: "arrow.up")
                        Image(systemName: "arrow.down")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}


// MARK: - Game Board
extension ReceiverGame2048View {
    private var gameBoard: some View {
        GeometryReader { proxy in
            let gridWidth = proxy.size.width - 48
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
        .frame(height: 380)
        .padding(.horizontal, 24)
    }
}


// MARK: - Background Grid
extension ReceiverGame2048View {
    private func backgroundGrid(gridWidth: CGFloat, tileSize: CGFloat) -> some View {
        VStack(spacing: spacing) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: spacing) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: "#cdc1b4"))
                            .frame(width: tileSize, height: tileSize)
                    }
                }
            }
        }
        .padding(spacing)
        .background(Color(hex: "#fff9e6"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 12, y: 4)
    }
}


// MARK: - Tiles Layer
extension ReceiverGame2048View {
    private func tilesLayer(gridWidth: CGFloat, tileSize: CGFloat) -> some View {
        return ZStack {
            ForEach(vm.tiles) { tile in
                TileView(tile: tile, size: tileSize)
                    .frame(width: tileSize, height: tileSize)
                    .position(
                        x: spacing + tileSize / 2 + CGFloat(tile.col) * (tileSize + spacing),
                        y: spacing + tileSize / 2 + CGFloat(tile.row) * (tileSize + spacing)
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.tiles)
            }
        }
        .frame(width: gridWidth, height: gridWidth)
    }
}


// MARK: - Tile View
struct TileView: View {
    let tile: TileModel
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(tileColor(value: tile.value))
            .overlay(
                Text("\(tile.value)")
                    .font(.system(size: fontSize(value: tile.value), weight: .black))
                    .foregroundColor(textColor(value: tile.value))
                    .minimumScaleFactor(0.5)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
    }
    
    private func fontSize(value: Int) -> CGFloat {
        if value < 100 { return size * 0.5 }
        if value < 1000 { return size * 0.42 }
        return size * 0.35
    }
    
    private func textColor(value: Int) -> Color {
        // 2 dan 4 pakai text gelap, sisanya putih
        return value <= 4 ? Color(hex: "#776e65") : .white
    }
    
    private func tileColor(value: Int) -> Color {
        switch value {
        case 2:
            return Color(hex: "#eee4da") // Beige sangat terang
        case 4:
            return Color(hex: "#ede0c8") // Beige terang
        case 8:
            return Color(hex: "#f2b179") // Orange soft
        case 16:
            return Color(hex: "#f59563") // Orange medium
        case 32:
            return Color(hex: "#f67c5f") // Coral
        case 64:
            return Color(hex: "#f65e3b") // Red-orange
        case 128:
            return Color(hex: "#edcf72") // Gold terang
        case 256:
            return Color(hex: "#edcc61") // Gold medium
        case 512:
            return Color(hex: "#edc850") // Gold
        case 1024:
            return Color(hex: "#edc53f") // Gold gelap
        case 2048:
            return Color(hex: "#edc22e") // Gold sangat gelap
        default:
            return Color(hex: "#3c3a32") // Hitam kecoklatan
        }
    }
}


// MARK: - New Game Button
extension ReceiverGame2048View {
    private var newGameButton: some View {
        Button {
            vm.startNewGame()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .bold))
                Text("New Game")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "#fa6255"))
            .cornerRadius(16)
            .shadow(color: Color(hex: "#fa6255").opacity(0.4), radius: 8, y: 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}


// MARK: - Swipe Handler
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

// MARK: - Preview
#Preview {
    ReceiverGame2048View()
}


