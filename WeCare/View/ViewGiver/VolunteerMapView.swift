//
//  VolunteerMapView.swift
//  WeCare
//
//  Created by student on 24/11/25.
//

import Foundation

import SwiftUI
import MapKit

struct VolunteerMapView: View {
    let volunteerCoordinate: CLLocationCoordinate2D
    let careReceiverCoordinate: CLLocationCoordinate2D

    @State private var region: MKCoordinateRegion

    init(volunteerCoordinate: CLLocationCoordinate2D,
         careReceiverCoordinate: CLLocationCoordinate2D) {
        self.volunteerCoordinate = volunteerCoordinate
        self.careReceiverCoordinate = careReceiverCoordinate

        // Set the center between the two points
        let midLat = (volunteerCoordinate.latitude + careReceiverCoordinate.latitude) / 2
        let midLon = (volunteerCoordinate.longitude + careReceiverCoordinate.longitude) / 2

        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: mapPins) { pin in
            MapMarker(coordinate: pin.coordinate, tint: pin.color)
        }
    }

    private var mapPins: [MapPin] {
        [
            MapPin(coordinate: volunteerCoordinate, color: .blue),
            MapPin(coordinate: careReceiverCoordinate, color: .red)
        ]
    }
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let color: Color
}
