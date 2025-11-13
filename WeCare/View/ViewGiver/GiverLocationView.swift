////
////  LocationView.swift
////  wecare kevin
////
//import SwiftUI
//import MapKit
//struct GiverLocationView: View {
//    let person: GiverPersonCardViewData
//    @State private var region: MKCoordinateRegion
//    init(person: GiverPersonCardViewData) {
//        self.person = person
//        // ✅ Set map region dari data orang
//        self._region = State(initialValue: MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: person.latitude, longitude: person.longitude),
//            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        ))
//    }
//    var body: some View {
//        VStack {
//            Map(coordinateRegion: $region, annotationItems: [person]) { person in
//                MapMarker(coordinate: CLLocationCoordinate2D(
//                    latitude: person.latitude,
//                    longitude: person.longitude
//                ), tint: .red)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            VStack(spacing: 12) {
//                Text(person.name).font(.title3).bold()
//                Text("Last known location in Surabaya")
//                    .foregroundStyle(.secondary)
//                Button {
//                    openInMaps()
//                } label: {
//                    Label("Navigate with Maps", systemImage: "location.fill")
//                        .foregroundStyle(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(12)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("GuardianPath")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    private func openInMaps() {
//        let mapItem = MKMapItem(placemark: MKPlacemark(
//            coordinate: CLLocationCoordinate2D(latitude: person.latitude, longitude: person.longitude)
//        ))
//        mapItem.name = person.name
//        mapItem.openInMaps()
//    }
//}
//    
//
