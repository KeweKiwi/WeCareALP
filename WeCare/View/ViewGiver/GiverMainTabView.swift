import SwiftUI

/// Tab utama untuk caregiver:
/// - Persons (list care receiver)
/// - Calendar (jadwal / kalender)
/// - Volunteer (menu volunteer)
struct GiverMainTabView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {
            
            // TAB 1: Persons
            GiverPersonListView()
                .tabItem {
                    Label("Persons", systemImage: "person.3.fill")
                }
            
            // TAB 2: Calendar
            GiverCalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            // ⭐ TAB 3: Volunteer
            VolunteerModeRootView()
                .tabItem {
                    Label("Volunteer", systemImage: "hands.sparkles.fill")
                }
        }
    }
}

#Preview {
    GiverMainTabView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(AuthViewModel())
}


