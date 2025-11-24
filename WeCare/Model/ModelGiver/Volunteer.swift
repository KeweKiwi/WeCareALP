//
//  Volunteer.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import Foundation
import CoreLocation

struct Volunteer: Identifiable {
    let id = UUID()
    let name: String
    let rating: Double
    let distance: String
    let age: Int
    let gender: String
    let specialty: String
    let restrictions: String
    let coordinate: CLLocationCoordinate2D
}

