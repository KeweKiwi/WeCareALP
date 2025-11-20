import SwiftUI
import Combine
final class VolunteerFinderVM: ObservableObject {
    @Published var isSearching = true
    @Published var volunteers: [Volunteer] = []
    @Published var selectedVolunteer: Volunteer?
    @Published var showTipSheet = false
    @Published var tipAmount: String = ""
    // Sample Prototype Data
    let sampleVolunteers: [Volunteer] = [
        Volunteer(name: "Alice Johnson", age: 28, gender: "Female", rating: 4.8, distance: "1.2 km", specialty: "Elderly Care, Medicine Reminder", restrictions: "No heavy lifting"),
        Volunteer(name: "Bob Smith", age: 35, gender: "Male", rating: 4.5, distance: "2.0 km", specialty: "Physical Therapy, Walking Support", restrictions: "Allergic to pets"),
        Volunteer(name: "Clara Lee", age: 22, gender: "Female", rating: 4.9, distance: "0.8 km", specialty: "Meal Prep, Companionship", restrictions: "None")
    ]
    func startSearching() {
        isSearching = true
        volunteers = []
        // Simulate searching delay
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
