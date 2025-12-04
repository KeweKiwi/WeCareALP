//
//  VolunteerProfile.swift
//  WeCare
//
//  Created by student on 03/12/25.
// kurang: detail di history button?
import Foundation

struct VolunteerProfile: Identifiable {
    let id = UUID()
    var name: String
    var age: Int
    var gender: String
    var specialty: String
    var restrictions: String
}
