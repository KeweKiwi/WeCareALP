//
//  VolunteerProfile.swift
//  WeCare
//
//  Created by student on 03/12/25.
// kurang: vidcall call dichat, pov selesai task, bisa reject request, kalau accept beberapa request bisa tampilan banyak, deadline task ditampilkan

import Foundation

struct VolunteerProfile: Identifiable {
    let id = UUID()
    var name: String
    var age: Int
    var gender: String
    var specialty: String
    var restrictions: String
}
