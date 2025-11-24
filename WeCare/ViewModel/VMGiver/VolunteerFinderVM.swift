import SwiftUI
import Combine
import CoreLocation

final class VolunteerFinderVM: ObservableObject {
    @Published var isSearching = true
    @Published var volunteers: [Volunteer] = []
    @Published var selectedVolunteer: Volunteer?
    @Published var showTipSheet = false
    @Published var tipAmount: String = ""

    // Sample Prototype Data (sudah diperbaiki)
    let sampleVolunteers: [Volunteer] = [
        Volunteer(
            name: "Alice Johnson",
            rating: 4.8,
            distance: "1.2 km",
            age: 28,
            gender: "Female",
            specialty: "Elderly Care, Medicine Reminder",
            restrictions: "No heavy lifting",
            coordinate: CLLocationCoordinate2D(latitude: -6.2015, longitude: 106.8169)
        ),
        Volunteer(
            name: "Bob Smith",
            rating: 4.5,
            distance: "2.0 km",
            age: 35,
            gender: "Male",
            specialty: "Physical Therapy, Walking Support",
            restrictions: "Allergic to pets",
            coordinate: CLLocationCoordinate2D(latitude: -6.2051, longitude: 106.8202)
        ),
        Volunteer(
            name: "Clara Lee",
            rating: 4.9,
            distance: "0.8 km",
            age: 22,
            gender: "Female",
            specialty: "Meal Prep, Companionship",
            restrictions: "None",
            coordinate: CLLocationCoordinate2D(latitude: -6.1980, longitude: 106.8150)
        )
    ]

    func startSearching() {
        isSearching = true
        volunteers = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.volunteers = self.sampleVolunteers
                self.isSearching = false
            }
        }
    }

    func selectVolunteer(_ volunteer: Volunteer) {
        selectedVolunteer = volunteer
        showTipSheet = true
    }
}
