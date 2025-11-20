import SwiftUI
enum PersonDestination: Hashable {
    case location(GiverPersonCardViewData)
    case family(GiverPersonCardViewData)
}
struct GiverPersonListView: View {
    
    private let persons: [GiverPersonCardViewData] = [
        GiverPersonCardViewData(
            name: "Grandma Anna",
            role: "Care Receiver",
            avatarURL: nil,
            status: .healthy,
            heartRate: 78,
            steps: 3450,
            familyCode: "123456",
            familyMembers: ["Daughter: Lisa", "Son: Michael", "Grandson: Kevin"]
        ),
        GiverPersonCardViewData(
            name: "Grandpa John",
            role: "Care Receiver",
            avatarURL: nil,
            status: .warning,
            heartRate: 95,
            steps: 1200,
            familyCode: "998877",
            familyMembers: ["Wife: Maria", "Son: David"]
        ),
        GiverPersonCardViewData(
            name: "Auntie Maria",
            role: "Care Receiver",
            avatarURL: nil,
            status: .critical,
            heartRate: 110,
            steps: 300,
            familyCode: "445566",
            familyMembers: ["Niece: Anna"]
        )
    ]
    
    @State private var filter: GiverPersonCardViewData.Status? = nil
    @State private var path: [PersonDestination] = []
    
    private var filtered: [GiverPersonCardViewData] {
        if let filter {
            return persons.filter { $0.status == filter }
        }
        return persons
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 12) {
                
                HStack {
                    Text("Persons")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Image(systemName: "magnifyingglass")
                    Image(systemName: "slider.horizontal.3")
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(text: "All", isSelected: filter == nil) {
                            filter = nil
                        }
                        FilterChip(text: "Healthy", isSelected: filter == .healthy) {
                            filter = .healthy
                        }
                        FilterChip(text: "Warning", isSelected: filter == .warning) {
                            filter = .warning
                        }
                        FilterChip(text: "Critical", isSelected: filter == .critical) {
                            filter = .critical
                        }
                    }
                    .padding(.horizontal)
                }
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filtered) { person in
                            GiverPersonCardView(
                                data: person,
                                onInfo: {
                                    // nanti bisa isi detail lain
                                },
                                onLocation: {
                                    path.append(.location(person))
                                },
                                onCardTap: {
                                    path.append(.family(person))
                                }
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationDestination(for: PersonDestination.self) { dest in
                switch dest {
                case .location(let person):
                    GiverLocationView(person: person)
                case .family(let person):
                    GiverFamilyDetailView(person: person)
                }
            }
        }
    }
}
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
                    Capsule()
                        .fill(isSelected ? Color(.systemGray5) : Color(.systemGray6))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.blue : Color(.systemGray4),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
#Preview {
    GiverPersonListView()
}


