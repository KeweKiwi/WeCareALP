////
////  ColorPalette.swift
////  wecare kevin
////
////  Created by student on 05/11/25.
////
//import SwiftUI
//import SwiftUI
//enum GiverColorPaletteView {
//    static let yellow  = Color(hex: "#fdcb46")
//    static let red     = Color(hex: "#fa6255")
//    static let green   = Color(hex: "#a6d17d")
//    static let skyBlue = Color(hex: "#91bef8")
//    static let lilac   = Color(hex: "#e1c7ec")
//    static let base    = Color(hex: "#fff9e6")
//}
////extension Color {
////    init(hex: String) {
////        var h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
////        var int: UInt64 = 0; Scanner(string: h).scanHexInt64(&int)
////        let a, r, g, b: UInt64
////        switch h.count {
////        case 3: (a,r,g,b) = (255, (int>>8)*17, (int>>4 & 0xF)*17, (int & 0xF)*17)
////        case 6: (a,r,g,b) = (255, int>>16, int>>8 & 0xFF, int & 0xFF)
////        case 8: (a,r,g,b) = (int>>24, int>>16 & 0xFF, int>>8 & 0xFF, int & 0xFF)
////        default:(a,r,g,b) = (255, 255, 255, 0)
////        }
////        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
////    }
////}
//
