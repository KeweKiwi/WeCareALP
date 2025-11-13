////
////  StatusDot.swift
////  wecare kevin
////
////  Created by student on 05/11/25.
////
//import SwiftUI
//struct StatusDot: View {
//    let status: PersonCardViewData.Status
//    var body: some View {
//        Circle()
//            .fill(color)
//            .frame(width: 14, height: 14)
//            .overlay(Circle().stroke(.white, lineWidth: 1))
//            .accessibilityLabel(Text(label))
//    }
//    private var color: Color {
//        switch status {
//        case .healthy:  return ColorPalette.green
//        case .warning:  return ColorPalette.yellow
//        case .critical: return ColorPalette.red
//        }
//    }
//    private var label: String {
//        switch status {
//        case .healthy:  return "Healthy"
//        case .warning:  return "Warning"
//        case .critical: return "Critical"
//        }
//    }
//}
//
