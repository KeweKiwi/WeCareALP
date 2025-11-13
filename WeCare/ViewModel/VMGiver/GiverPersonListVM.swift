//
////  PersonListViewModel.swift
////  wecare kevin
////
////  Created by student on 05/11/25.
////
//import SwiftUI     // untuk View (opsional di file VM, tapi oke)
//import Combine     // WAJIB: ObservableObject & @Published
//import Foundation
//struct PersonCardViewData: Identifiable, Hashable {
//    enum Status { case healthy, warning, critical }
//    let id: UUID
//    let name: String
//    let role: String
//    let avatarURL: URL?
//    let heartRateText: String?
//    let steps: Int?
//    
//    let status: Status
//    let latitude: Double
//    let longitude: Double
//}
//@MainActor
//final class PersonListViewModel: ObservableObject {
//    enum SortOption: String, CaseIterable { case az = "A–Z", za = "Z–A", status, heart }
//    @Published var items: [PersonCardViewData] = []
//    @Published var query: String = ""
//    @Published var sort: SortOption = .az
//    @Published var filterStatus: Set<PersonCardViewData.Status> = []
//    init(seed: [PersonCardViewData]) { self.items = seed }
//    var visible: [PersonCardViewData] {
//        var r = items
//        if !query.isEmpty {
//            r = r.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.role.localizedCaseInsensitiveContains(query) }
//        }
//        if !filterStatus.isEmpty { r = r.filter { filterStatus.contains($0.status) } }
//        switch sort {
//            case .az:     r.sort { $0.name < $1.name }
//            case .za:     r.sort { $0.name > $1.name }
//            case .status: r.sort { $0.statusOrder < $1.statusOrder }
//            case .heart:  r.sort { ($0.heartRateInt ?? 0) > ($1.heartRateInt ?? 0) }
//        }
//        return r
//    }
//}
//private extension PersonCardViewData {
//    var statusOrder: Int {
//        switch status { case .critical: return 0; case .warning: return 1; case .healthy: return 2 }
//    }
//    var heartRateInt: Int? {
//        guard let heartRateText else { return nil }
//        return heartRateText.split(separator: " ").first.flatMap { Int(String($0)) }
//    }
//}
//
