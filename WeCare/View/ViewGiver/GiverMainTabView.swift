import SwiftUI


struct GiverMainTabView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        TabView {
            
            // TAB 1: Persons
            NavigationStack {
                GiverPersonListView()
            }
            .tabItem {
                Label("Persons", systemImage: "person.3.fill")
            }
            
            // TAB 2: Calendar
            NavigationStack {
                GiverCalendarView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            
            // TAB 3: Volunteer
            NavigationStack {
                VolunteerModeRootView()
            }
            .tabItem {
                Label("Volunteer", systemImage: "hands.sparkles.fill")
            }
            
            // TAB 4: Settings
            NavigationStack {
                if let user = authVM.currentUser {
                    GiverSettingsView(userId: user.id)
                } else {
                    Text("Settings")
                }
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}







#Preview {
    // Untuk preview, kamu bisa bikin AuthViewModel dummy
    let authVM = AuthViewModel()
    // authVM.currentUser = Users(id: "dummy-id", data: [:])  // sesuaikan dengan init kamu
    
    return GiverMainTabView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(authVM)
}



