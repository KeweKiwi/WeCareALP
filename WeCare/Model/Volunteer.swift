//
//  Volunteer.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import Foundation
struct Volunteer: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let gender: String
    let rating: Double
    let distance: String
    let specialty: String
    let restrictions: String
}
