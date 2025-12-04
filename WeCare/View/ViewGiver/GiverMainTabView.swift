import SwiftUI


/// Tab utama untuk caregiver:
/// - Persons (list care receiver)
/// - Calendar (jadwal / kalender)
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
        }
    }
}


#Preview {
    GiverMainTabView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(AuthViewModel())
}





