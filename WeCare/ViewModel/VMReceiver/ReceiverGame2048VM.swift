import Combine
import Foundation
import SwiftUI
// MARK: - Game 2048 Models (Tetap)
struct Tile: Equatable {
    var value: Int
    var id: UUID = UUID()
}
struct Cell: Identifiable, Equatable {
    let id: UUID = UUID()
    var tile: Tile?
}
struct GridRow: Identifiable, Equatable {
    let id: UUID = UUID()
    var cells: [Cell]
}
enum Direction {
    case up, down, left, right
}
// MARK: - Game 2048 ViewModel
class ReceiverGame2048VM: ObservableObject {
    @Published var grid: [GridRow] = []
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var gameStatus: String = "Swipe to play!"
    
    private let size = 4
    
    init() {
        startNewGame()
    }
    
    // MARK: - Game Setup
    
    func startNewGame() {
        grid = []
        for _ in 0..<size {
            var newRowCells: [Cell] = []
            for _ in 0..<size {
                newRowCells.append(Cell(tile: nil))
            }
            grid.append(GridRow(cells: newRowCells))
        }
        
        score = 0
        isGameOver = false
        gameStatus = "Swipe to play!"
        
        spawnNewTile()
        spawnNewTile()
    }
    
    // Fungsi ini sudah benar (sesuai permintaan Anda sebelumnya untuk selalu '2')
    func spawnNewTile() {
        var emptyCells: [(r: Int, c: Int)] = []
        for r in 0..<size {
            for c in 0..<size {
                if grid[r].cells[c].tile == nil {
                    emptyCells.append((r, c))
                }
            }
        }
        
        if let randomCell = emptyCells.randomElement() {
            let newValue = 2
            grid[randomCell.r].cells[randomCell.c].tile = Tile(value: newValue)
        }
    }
    
    // MARK: - Game Move Logic
    
    func move(_ direction: Direction) {
        if isGameOver { return }
        
        var didMove = false
        var tempGrid = grid
        
        switch direction {
        case .left:
            tempGrid = process(grid: tempGrid, didMove: &didMove)
        case .right:
            tempGrid = reverseRows(grid: tempGrid)
            tempGrid = process(grid: tempGrid, didMove: &didMove)
            tempGrid = reverseRows(grid: tempGrid)
        case .up:
            tempGrid = transpose(grid: tempGrid)
            tempGrid = process(grid: tempGrid, didMove: &didMove)
            tempGrid = transpose(grid: tempGrid)
        case .down:
            tempGrid = transpose(grid: tempGrid)
            tempGrid = reverseRows(grid: tempGrid)
            tempGrid = process(grid: tempGrid, didMove: &didMove)
            tempGrid = reverseRows(grid: tempGrid)
            tempGrid = transpose(grid: tempGrid)
        }
        
        grid = tempGrid
        
        if didMove {
            spawnNewTile()
            checkForGameOver()
        }
    }
    
    // MARK: - <<< PERBAIKAN LOGIKA ADA DI SINI >>>
    
    private func process(grid: [GridRow], didMove: inout Bool) -> [GridRow] {
        var newGrid = grid
        
        for r in 0..<size {
            // Simpan baris asli untuk perbandingan
            let originalCells = newGrid[r].cells
            
            // 1. Ambil tile yang ada
            let tilesInRow = originalCells.compactMap { $0.tile }
            
            var mergedTiles: [Tile] = []
            var i = 0
            
            // 2. Logika Menggabungkan (Merge)
            while i < tilesInRow.count {
                let currentTile = tilesInRow[i]
                
                if i + 1 < tilesInRow.count && tilesInRow[i+1].value == currentTile.value {
                    let newValue = currentTile.value * 2
                    mergedTiles.append(Tile(value: newValue))
                    score += newValue
                    i += 2
                    // Jangan set didMove di sini dulu
                } else {
                    mergedTiles.append(currentTile)
                    i += 1
                }
            }
            
            // 3. Tulis kembali baris baru
            var newCells: [Cell] = []
            for c in 0..<size {
                if c < mergedTiles.count {
                    newCells.append(Cell(tile: mergedTiles[c]))
                } else {
                    newCells.append(Cell(tile: nil))
                }
            }
            
            // 4. PERBAIKAN: Cek apakah baris baru berbeda dari baris lama
            // Ini akan mendeteksi (merge) DAN (shift/geser)
            var rowChanged = false
            for c in 0..<size {
                // Bandingkan nilainya, bukan ID-nya
                if originalCells[c].tile?.value != newCells[c].tile?.value {
                    rowChanged = true
                    break
                }
            }
            
            if rowChanged {
                didMove = true // Set didMove jika baris ini berubah
            }
            newGrid[r].cells = newCells
        }
        return newGrid
    }
    
    // MARK: - Game Over Check (Tidak Berubah)
    
    func checkForGameOver() {
        // Cek 1: Sel kosong?
        for r in 0..<size {
            for c in 0..<size {
                if grid[r].cells[c].tile == nil {
                    gameStatus = "Keep swiping!"
                    return
                }
            }
        }
        
        // Cek 2: Papan penuh. Masih bisa bergerak?
        for r in 0..<size {
            for c in 0..<size {
                guard let value = grid[r].cells[c].tile?.value else { continue }
                
                if c < size - 1 && grid[r].cells[c+1].tile?.value == value {
                    return
                }
                if r < size - 1 && grid[r+1].cells[c].tile?.value == value {
                    return
                }
            }
        }
        
        isGameOver = true
        gameStatus = "Game Over! Score: \(score)"
    }
    
    // MARK: - Grid Transform Helpers (Tidak Berubah)
    
    private func transpose(grid: [GridRow]) -> [GridRow] {
        var newGrid = grid
        for r in 0..<size {
            for c in 0..<size {
                newGrid[c].cells[r] = grid[r].cells[c]
            }
        }
        return newGrid
    }
    
    private func reverseRows(grid: [GridRow]) -> [GridRow] {
        var newGrid = grid
        for r in 0..<size {
            newGrid[r].cells.reverse()
        }
        return newGrid
    }
}



