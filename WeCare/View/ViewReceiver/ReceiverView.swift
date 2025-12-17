import SwiftUI
struct ReceiverView: View {
    let receiverId: Int
    // ViewModel is the single source of truth for all Views
    @StateObject private var viewModel = ReceiverVM()
    
    var body: some View {
        NavigationStack {
                    TabView {
                        
                        ReceiverDashboardView(viewModel: viewModel, receiverId: receiverId)
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }
                        
                        ReceiverHealthView(viewModel: viewModel)
                            .tabItem {
                                Label("Vital Health", systemImage: "heart.text.square.fill")
                            }
                        
                        ReceiverGamesView()
                            .tabItem {
                                Label("Games", systemImage: "gamecontroller.fill")
                            }
                    }
                    .accentColor(Color(hex: "#387b38"))
                    .navigationBarBackButtonHidden(true)
        }
    }
}
//// MARK: - Preview (for Xcode)
//#Preview {
//    ReceiverView()
//}


