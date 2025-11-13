////
////  PersonListView.swift
////  wecare kevin
////
////  Created by student on 05/11/25.
////
//import SwiftUI
//enum Destination: Hashable {
//    case location(GiverPersonCardViewData)
//}
//struct PersonListView: View {
//    @StateObject var vm: GiverPersonListVM
//    @State private var path: [Destination] = []
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 12) {
//                // MARK: - Title + Actions
//                HStack {
//                    Text("Persons").font(.title2).bold()
//                    Spacer()
//                    Button { } label: { Image(systemName: "magnifyingglass") }
//                    Button { } label: { Image(systemName: "slider.horizontal.3") }
//                }
//                .padding(.horizontal)
//                
//                // MARK: - Filters + Sorting (CHIPS)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(GiverPersonListVM.SortOption.allCases, id: \.self) { opt in
//                            Chip(text: opt.rawValue, isSelected: vm.sort == opt) { vm.sort = opt }
//                        }
//                        ChipStatusDot(.healthy,  isOn: vm.filterStatus.contains(.healthy))  { toggle(.healthy) }
//                        ChipStatusDot(.warning,  isOn: vm.filterStatus.contains(.warning))  { toggle(.warning) }
//                        ChipStatusDot(.critical, isOn: vm.filterStatus.contains(.critical)) { toggle(.critical) }
//                    }
//                    .padding(.horizontal)
//                }
//                
//                // MARK: - Person List
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(vm.visible) { card in
//                            GiverPersonCardView(
//                                data: card,
//                                onInfo: { print("INFO \(card.name)") },
//                                onLocation: { path.append(.location(card)) }   // ✅ dorong destinasi
//                            )
//                            .padding(.horizontal)
//                        }
//                    }
//                    .padding(.vertical, 8)
//                }
//            }
//            .background(GiverColorPaletteView.base.ignoresSafeArea())
//            .navigationDestination(for: Destination.self) { dest in   // ✅ handler rute
//                switch dest {
//                case .location(let person):
//                    GiverLocationView(person: person)
//                }
//            }
//        }
//        
//        
//    }
//    
//struct Chip: View {
//        let text: String
//        let isSelected: Bool
//        var action: () -> Void
//        var body: some View {
//            Button(action: action) {
//                Text(text)
//                    .font(.subheadline)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(
//                        Capsule().fill(isSelected ? GiverColorPaletteView.skyBlue.opacity(0.25) : .white)
//                    )
//                    .overlay(
//                        Capsule().stroke(isSelected ? GiverColorPaletteView.skyBlue : Color.black.opacity(0.1))
//                    )
//            }
//            .buttonStyle(.plain)
//        }
//    }
//struct ChipIcon: View {
//        let system: String
//        let isSelected: Bool
//        var action: () -> Void
//        var body: some View {
//            Button(action: action) {
//                Image(systemName: system)
//                    .font(.body)
//                    .padding(8)
//                    .background(
//                        Circle().fill(isSelected ? GiverColorPaletteView.skyBlue.opacity(0.25) : .white)
//                    )
//                    .overlay(
//                        Circle().stroke(isSelected ? GiverColorPaletteView.skyBlue : Color.black.opacity(0.1))
//                    )
//                    .shadow(radius: 1, y: 1)
//            }
//            .buttonStyle(.plain)
//        }
//    }
//struct ChipStatusDot: View {
//    let status: GiverPersonCardViewData.Status
//    let isOn: Bool
//    var action: () -> Void
//    
//    
//    init(_ status: GiverPersonCardViewData.Status, isOn: Bool, action: @escaping () -> Void) {
//        self.status = status
//        self.isOn = isOn
//        self.action = action
//    }
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 6) {
//                Circle()
//                    .fill(color)
//                    .frame(width: 10, height: 10)
//                Text(label)
//                    .font(.subheadline)
//            }
//            .padding(.horizontal, 10)
//            .padding(.vertical, 6)
//            .background(Capsule().fill(isOn ? color.opacity(0.18) : .white))
//            .overlay(Capsule().stroke(isOn ? color : Color.black.opacity(0.1)))
//        }
//        .buttonStyle(.plain)
//    }
//    private var color: Color {
//        switch status {
//        case .healthy:  return GiverColorPaletteView.green
//        case .warning:  return GiverColorPaletteView.yellow
//        case .critical: return GiverColorPaletteView.red
//        }
//    }
//    private var label: String {
//        switch status {
//        case .healthy: return "Healthy"
//        case .warning: return "Warning"
//        case .critical: return "Critical"
//        }
//    }
//}
//    // Toggle status (Healthy / Warning / Critical)
//       private func toggle(_ s: GiverPersonCardViewData.Status) {
//           if vm.filterStatus.contains(s) {
//               vm.filterStatus.remove(s)
//           } else {
//               vm.filterStatus.insert(s)
//           }
//       }
//   }
//#Preview("PersonListView") {
//    NavigationStack {
//        PersonListView(vm: GiverPersonListVM(seed: SampleData.demoList))
//    }
//}
//
