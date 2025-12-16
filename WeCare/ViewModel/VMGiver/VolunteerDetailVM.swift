//
//  VolunteerDetailVM.swift
//  WeCare
//
//  Created by student on 24/11/25.
//

import Foundation
import CoreLocation
import Combine      

final class VolunteerDetailVM: ObservableObject {
    @Published var volunteer: Volunteer

    // Lokasi care receiver bisa berasal dari user
    @Published var careReceiverLocation = CLLocationCoordinate2D(
        latitude: -7.2620,
        longitude: 112.7390
    )

    init(volunteer: Volunteer) {
        self.volunteer = volunteer
    }

    func calculateDistanceKm() -> String {
        let v = CLLocation(latitude: volunteer.coordinate.latitude,
                           longitude: volunteer.coordinate.longitude)
        let c = CLLocation(latitude: careReceiverLocation.latitude,
                           longitude: careReceiverLocation.longitude)

        let meters = v.distance(from: c)
        return String(format: "%.2f km", meters / 1000)
    }
}
