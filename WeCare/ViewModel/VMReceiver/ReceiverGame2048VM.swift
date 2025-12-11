import Foundation
import SwiftUI
import Combine
enum Direction {
    case up, down, left, right
}
final class ReceiverGame2048VM: ObservableObject {
    @Published private(set) var tiles: [TileModel] = []
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var gameStatus: String = "Swipe to play!"
    
    let size = 4
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        tiles.removeAll()
        score = 0
        isGameOver = false
        gameStatus = "Swipe to play!"
        // spawn synchronously initial tiles so board state is immediate
        spawnNewTileImmediate()
        spawnNewTileImmediate()
    }
    
    // Synchronous spawn (no DispatchQueue) — useful when we need immediate board update
    private func spawnNewTileImmediate() {
        var empty: [(Int, Int)] = []
        for r in 0..<size {
            for c in 0..<size {
                if tile(atRow: r, col: c) == nil {
                    empty.append((r, c))
                }
            }
        }
        if let chosen = empty.randomElement() {
            let newTile = TileModel(value: 2, row: chosen.0, col: chosen.1)
            tiles.append(newTile)
        }
    }
    
    // Public spawn which preserves previous behavior (animated append) — still available if needed
    func spawnNewTile() {
        var empty: [(Int, Int)] = []
        for r in 0..<size {
            for c in 0..<size {
                if tile(atRow: r, col: c) == nil {
                    empty.append((r, c))
                }
            }
        }
        if let chosen = empty.randomElement() {
            let newTile = TileModel(value: 2, row: chosen.0, col: chosen.1)
            // Use animated append on main queue for nicer UX — but don't rely on this for logic checks
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.12)) {
                    self.tiles.append(newTile)
                }
            }
        }
    }
    
    // MARK: - Helpers (read-only)
    private func tileIndex(atRow r: Int, col c: Int) -> Int? {
        tiles.firstIndex { $0.row == r && $0.col == c }
    }
    private func tile(atRow r: Int, col c: Int) -> TileModel? {
        if let idx = tileIndex(atRow: r, col: c) { return tiles[idx] }
        return nil
    }
    
    // MARK: - Move (safe, compute final board first)
    func move(_ direction: Direction) {
        guard !isGameOver else { return }
        
        // Snapshot current tiles to work on (pure data)
        let currentTiles = tiles
        
        // Build board matrix from snapshot
        var board: [[TileModel?]] = Array(repeating: Array(repeating: nil, count: size), count: size)
        for t in currentTiles {
            if t.row >= 0 && t.row < size && t.col >= 0 && t.col < size {
                board[t.row][t.col] = t
            }
        }
        
        // transform helpers
        func transpose(_ b: [[TileModel?]]) -> [[TileModel?]] {
            var nb = Array(repeating: Array(repeating: nil as TileModel?, count: size), count: size)
            for r in 0..<size {
                for c in 0..<size {
                    nb[c][r] = b[r][c]
                }
            }
            return nb
        }
        func reverseRows(_ b: [[TileModel?]]) -> [[TileModel?]] {
            var nb = b
            for r in 0..<size { nb[r].reverse() }
            return nb
        }
        
        // Orient board so we always process left
        var working = board
        var needsReverseAfter = false
        var needsTransposeAfter = false
        
        switch direction {
        case .left:
            break
        case .right:
            working = reverseRows(working)
            needsReverseAfter = true
        case .up:
            working = transpose(working)
            needsTransposeAfter = true
        case .down:
            working = transpose(working)
            working = reverseRows(working)
            needsReverseAfter = true
            needsTransposeAfter = true
        }
        
        var moved = false
        var newScoreGained = 0
        
        // process one row -> returns [TileModel?] sized 'size'
        func processRow(_ row: [TileModel?]) -> [TileModel?] {
            var line: [TileModel] = []
            for cell in row {
                if let t = cell { line.append(t) }
            }
            if line.isEmpty {
                return Array(repeating: nil as TileModel?, count: size)
            }
            
            var mergedLine: [TileModel] = []
            var i = 0
            while i < line.count {
                if i + 1 < line.count && line[i].value == line[i + 1].value {
                    // reuse left tile to preserve id (smooth animation)
                    var kept = line[i]
                    let combined = kept.value * 2
                    kept.value = combined
                    kept.merged = true
                    mergedLine.append(kept)
                    newScoreGained += combined
                    i += 2
                } else {
                    mergedLine.append(line[i])
                    i += 1
                }
            }
            
            // convert to optional row and pad with nils
            var resultRow: [TileModel?] = mergedLine.map { $0 }
            while resultRow.count < size { resultRow.append(nil) }
            
            // detect movement/changes by comparing id/value
            for idx in 0..<size {
                let orig = row[idx]
                let res = resultRow[idx]
                if orig?.id != res?.id || orig?.value != res?.value {
                    moved = true
                    break
                }
            }
            return resultRow
        }
        
        // process all rows
        var processed = working
        for r in 0..<size {
            processed[r] = processRow(working[r])
        }
        
        // revert orientation
        var finalBoard = processed
        if needsReverseAfter { finalBoard = reverseRows(finalBoard) }
        if needsTransposeAfter { finalBoard = transpose(finalBoard) }
        
        // build finalTiles preserving ids & set positions
        var finalTiles: [TileModel] = []
        for r in 0..<size {
            for c in 0..<size {
                if var t = finalBoard[r][c] {
                    t.row = r
                    t.col = c
                    finalTiles.append(t)
                }
            }
        }
        
        // quick compare to see if anything changed at all
        func different(_ a: [TileModel], _ b: [TileModel]) -> Bool {
            if a.count != b.count { return true }
            var mapA: [UUID:(Int,Int,Int)] = [:]
            for t in a { mapA[t.id] = (t.row, t.col, t.value) }
            for t in b {
                if let v = mapA[t.id] {
                    if v.0 != t.row || v.1 != t.col || v.2 != t.value { return true }
                } else { return true }
            }
            return false
        }
        
        let hasChanged = different(finalTiles, currentTiles)
        if !hasChanged {
            // nothing moved — keep status
            DispatchQueue.main.async {
                self.gameStatus = "Keep swiping!"
            }
            return
        }
        
        // APPLY final state atomically (animated)
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.16)) {
                self.tiles = finalTiles
                self.score += newScoreGained
            }
            
            // Decide what to do next depending on whether final board has empty cells
            // Calculate empties from finalTiles (deterministic)
            var hasEmpty = false
            var boardVals = Array(repeating: Array(repeating: 0, count: self.size), count: self.size)
            for t in finalTiles { boardVals[t.row][t.col] = t.value }
            for rr in 0..<self.size {
                for cc in 0..<self.size {
                    if boardVals[rr][cc] == 0 { hasEmpty = true; break }
                }
                if hasEmpty { break }
            }
            
            if !hasEmpty {
                // No empty cell — check merges on final board snapshot.
                if !self.checkForGameOverUsing(board: boardVals) {
                    // There is at least one possible merge → not game over
                    self.gameStatus = "Keep swiping!"
                } else {
                    // No merges & no empty -> game over
                    self.isGameOver = true
                    self.gameStatus = "Game Over! Score: \(self.score)"
                }
            } else {
                // There are empty cells -> spawn one immediately (synchronous) so next logic sees final board
                self.spawnNewTileImmediate()
                // after we appended the tile, check for game over reliably (run on next runloop to allow UI update)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                    self.checkForGameOver()
                }
            }
        }
    }
    
    // MARK: - Game over helpers
    // Check using a value-board snapshot. Returns true if game IS OVER (no empty & no merges).
    private func checkForGameOverUsing(board: [[Int]]) -> Bool {
        // 1) if any zero -> not game over
        for r in 0..<size {
            for c in 0..<size {
                if board[r][c] == 0 { return false }
            }
        }
        // 2) check for possible merges
        for r in 0..<size {
            for c in 0..<size {
                let val = board[r][c]
                if c < size - 1 && board[r][c+1] == val { return false }
                if r < size - 1 && board[r+1][c] == val { return false }
            }
        }
        // no empty, no merges -> game over
        return true
    }
    
    // Public checkForGameOver that reads current tiles
    func checkForGameOver() {
        // build snapshot of values
        var board = Array(repeating: Array(repeating: 0, count: size), count: size)
        for t in tiles {
            board[t.row][t.col] = t.value
        }
        if checkForGameOverUsing(board: board) {
            DispatchQueue.main.async {
                self.isGameOver = true
                self.gameStatus = "Game Over! Score: \(self.score)"
            }
        } else {
            DispatchQueue.main.async {
                self.gameStatus = "Keep swiping!"
            }
        }
    }
}

