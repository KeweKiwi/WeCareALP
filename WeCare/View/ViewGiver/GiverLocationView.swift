import SwiftUI
import MapKit
extension GiverPersonCardViewData {
    // dummy, nanti bisa diganti dari database
    var latitude: Double { -7.2575 }    // Surabaya
    var longitude: Double { 112.7521 }
}
struct GiverLocationView: View {
    let person: GiverPersonCardViewData
    @State private var region: MKCoordinateRegion
    
    init(person: GiverPersonCardViewData) {
        self.person = person
        let center = CLLocationCoordinate2D(
            latitude: person.latitude,
            longitude: person.longitude
        )
        _region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Map(
                coordinateRegion: $region,
                annotationItems: [person]
            ) { item in
                MapMarker(
                    coordinate: CLLocationCoordinate2D(
                        latitude: item.latitude,
                        longitude: item.longitude
                    ),
                    tint: .red
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 12) {
                Text(person.name)
                    .font(.title3)
                    .bold()
                
                Text("Last known location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: openInMaps) {
                    Label("Navigate with Maps", systemImage: "location.fill")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func openInMaps() {
        let coord = CLLocationCoordinate2D(
            latitude: person.latitude,
            longitude: person.longitude
        )
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord))
        mapItem.name = person.name
        mapItem.openInMaps()
    }
}


