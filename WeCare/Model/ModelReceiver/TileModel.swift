//
//  TileModel.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import Foundation
struct TileModel: Identifiable, Equatable {
    let id: UUID
    var value: Int
    var row: Int
    var col: Int
    var merged: Bool = false
    
    init(value: Int, row: Int, col: Int) {
        self.id = UUID()
        self.value = value
        self.row = row
        self.col = col
    }
    
    static func ==(lhs: TileModel, rhs: TileModel) -> Bool {
        lhs.id == rhs.id
    }
}
