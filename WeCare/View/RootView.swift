import SwiftUI

struct RootView: View {
    @State private var showLoading = true

    var body: some View {
        if showLoading {
            LoadingView(showMainView: $showLoading)
        } else {
            UsersTableView()   // ← your real dashboard
        }
    }
}



