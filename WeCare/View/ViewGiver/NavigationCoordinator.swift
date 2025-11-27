//
//  NavigationCoordinator.swift
//  WeCare
//
//  Created by student on 27/11/25.
// INI BUAT SUPAYA GIVERPERSONLISTVIEWNYA JADI ROOT BAGI FIND VOLUNTEER

import Foundation
import SwiftUI
import Combine

/// Kelas global untuk koordinasi navigasi antar view
final class NavigationCoordinator: ObservableObject {
    
    /// Trigger untuk pop ke root di NavigationStack
    @Published var shouldPopToRoot: Bool = false
    
    /// Helper function biar pemanggilan lebih rapi
    func popToRoot() {
        shouldPopToRoot = true
    }
}



