import SwiftUI


struct RootView: View {
    @State private var showLoading = true
    
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var coordinator = NavigationCoordinator()
    
    var body: some View {
        if showLoading {
            // ⏳ Splash / loading screen
            LoadingView(showMainView: $showLoading)
        } else {
            // 🔑 After loading, decide: login or main app
            Group {
                if authVM.isLoggedIn {
                    // ✅ Logged in → go to your real app
                    GiverMainTabView()          // or UsersTableView() if that’s your main
                        .environmentObject(coordinator)
                        .environmentObject(authVM)
                } else {
                    // 🔐 Not logged in → show login
                    NavigationStack {
                        StartView()
                    }
                    .environmentObject(authVM)
                }
            }
        }
    }
}



