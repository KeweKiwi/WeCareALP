import SwiftUI


enum PersonDestination: Hashable {
    case info(GiverPersonCardViewData)
    case location(GiverPersonCardViewData)
    case family(GiverPersonCardViewData)
    case volunteer
}


struct GiverPersonListView: View {
    
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject private var vm = GiverCareReceiversViewModel()
    
    @State private var filter: GiverPersonCardViewData.Status? = nil
    @State private var path: [PersonDestination] = []
    
    @State private var showSearch: Bool = false
    @State private var query: String = ""
    
    // Filter + search di atas data yang sudah diproses oleh ViewModel
    private var filtered: [GiverPersonCardViewData] {
        var list = vm.persons
        
        if let filter {
            list = list.filter { $0.status == filter }
        }
        if !query.isEmpty {
            list = list.filter { $0.name.lowercased().contains(query.lowercased()) }
        }
        return list
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 12) {
                
                // Header
                HStack {
                    Text("Persons")
                        .font(.title2).bold()
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            showSearch.toggle()
                            if !showSearch { query = "" }
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                
                // Search bar
                if showSearch {
                    HStack {
                        TextField("Search by name...", text: $query)
                            .textFieldStyle(.roundedBorder)
                        
                        if !query.isEmpty {
                            Button("Cancel") {
                                query = ""
                                withAnimation { showSearch = false }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(text: "All",      isSelected: filter == nil)        { filter = nil }
                        FilterChip(text: "Healthy",  isSelected: filter == .healthy)   { filter = .healthy }
                        FilterChip(text: "Warning",  isSelected: filter == .warning)   { filter = .warning }
                        FilterChip(text: "Critical", isSelected: filter == .critical)  { filter = .critical }
                    }
                    .padding(.horizontal)
                }
                
                // List
                ScrollView {
                    if vm.isLoading {
                        ProgressView("Loading persons...")
                            .padding(.top, 40)
                    } else if let error = vm.errorMessage {
                        VStack(spacing: 8) {
                            Text("Error")
                                .font(.headline)
                            Text(error)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                reload()
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                    } else if filtered.isEmpty {
                        Text("No care receivers found.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filtered) { person in
                                GiverPersonCardView(
                                    data: person,
                                    onInfo: { path.append(.info(person)) },
                                    onLocation: { path.append(.location(person)) },
                                    onVolunteer: { path.append(.volunteer) },
                                    onCardTap: { path.append(.family(person)) }
                                )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationDestination(for: PersonDestination.self) { dest in
                switch dest {
                case .info(let p):
                    GiverPersonInfoView(
                        person: p,
                        vitalSign: makeVitalSign(from: p)
                    )
                case .location(let p):
                    GiverLocationView(person: p)
                case .family(let p):
                    GiverFamilyDetailView(person: p)
                case .volunteer:
                    VolunteerFinderView()
                }
            }
        }
        .onChange(of: coordinator.shouldPopToRoot) { newValue in
            if newValue {
                path.removeAll()
                coordinator.shouldPopToRoot = false
            }
        }
        .onAppear {
            reload()
        }
    }
    
    private func reload() {
        if let user = authVM.currentUser {
            vm.load(for: user.userId)      // caregiver yang login
        } else {
            print("⚠️ No logged-in user in GiverPersonListView")
        }
    }
    
    private func makeVitalSign(from p: GiverPersonCardViewData) -> VitalSign {
        VitalSign(
            vitalId: 0,
            userId: 0,
            timestamp: Date(),
            heartRate: p.heartRate,
            oxygenSaturation: nil,
            steps: p.steps,
            sleepDurationHours: nil,
            temperature: nil
        )
    }
}


// FilterChip tetap sama
struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(isSelected ? Color(.systemGray5) : Color(.systemGray6))
                )
                .overlay(
                    Capsule().stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    GiverPersonListView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(AuthViewModel())
}





