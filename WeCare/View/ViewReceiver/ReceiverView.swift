import SwiftUI
struct ReceiverView: View {
    // ViewModel is the single source of truth for all Views
    @StateObject var viewModel = ReceiverVM()
    
    var body: some View {
        TabView {
            // Tab 1: Dashboard (includes tasks/reminders)
            ReceiverDashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Tab 2: Health
            ReceiverHealthView(viewModel: viewModel)
                .tabItem {
                    Label("Vital Health", systemImage: "heart.text.square.fill")
                }
            
            // Tab 3: Games
            ReceiverGamesView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
        }
        .accentColor(Color(hex: "#387b38"))
        .navigationBarBackButtonHidden(true)
    }
}
// MARK: - Preview (for Xcode)
#Preview {
    ReceiverView()
}


