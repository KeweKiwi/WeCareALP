//
//  GiverFamilyViewModel.swift
//  WeCare
//


import Foundation
import FirebaseFirestore
import Combine


@MainActor
final class GiverFamilyViewModel: ObservableObject {
    
    // MARK: - Member structure for UI
    struct MemberDisplay: Identifiable, Hashable {
        let id: String          // documentID dari FamilyMembers
        let userId: Int         // join ke Users.user_id
        let name: String
        let isAdmin: Bool
    }
    
    // Raw Firestore record (FamilyMembers)
    private struct RawMembership {
        let id: String
        let userId: Int
        let joinedAt: Date?
    }
    
    // MARK: - Published State
    @Published var members: [MemberDisplay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    private let familyCode: String?
    
    init(familyCode: String?) {
        self.familyCode = familyCode
    }
    
    // MARK: - Public load
    func load() {
        guard let code = familyCode, !code.isEmpty else {
            self.members = []
            self.errorMessage = "No family code found."
            return
        }
        
        isLoading = true
        errorMessage = nil
        members = []
        
        // 1️⃣ Fetch Family by Code
        db.collection("Families")
            .whereField("family_code", isEqualTo: code)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                
                if let error = error {
                    Task { @MainActor in
                        self.isLoading = false
                        self.errorMessage = "Failed to load family: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    Task { @MainActor in
                        self.isLoading = false
                        self.errorMessage = "Family not found for code \(code)"
                    }
                    return
                }
                
                let data = doc.data()
                let familyId = data["family_id"] as? Int ?? 0
                
                if familyId == 0 {
                    Task { @MainActor in
                        self.isLoading = false
                        self.errorMessage = "Invalid family_id"
                    }
                    return
                }
                
                // 2️⃣ Load members of this family
                self.fetchMembers(for: familyId)
            }
    }
    
    // MARK: - DELETE Members
    func deleteMembers(withIds ids: [String]) {
        guard !ids.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()
        var firstError: Error?
        
        for id in ids {
            group.enter()
            db.collection("FamilyMembers")    // FIXED NAME
                .document(id)
                .delete { error in
                    if let error, firstError == nil {
                        firstError = error
                    }
                    group.leave()
                }
        }
        
        group.notify(queue: .main) {
            if let error = firstError {
                self.isLoading = false
                self.errorMessage = "Failed to delete members: \(error.localizedDescription)"
            } else {
                self.load()   // reload after delete
            }
        }
    }
    
    
    // MARK: - Fetch members from FamilyMembers
    private func fetchMembers(for familyId: Int) {
        db.collection("FamilyMembers")        // FIXED NAME
            .whereField("family_id", isEqualTo: familyId)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                
                if let error = error {
                    Task { @MainActor in
                        self.isLoading = false
                        self.errorMessage = "Failed to load FamilyMembers: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let docs = snapshot?.documents, !docs.isEmpty else {
                    Task { @MainActor in
                        self.isLoading = false
                        self.members = []
                    }
                    return
                }
                
                let memberships: [RawMembership] = docs.map { doc in
                    let data = doc.data()
                    let userId = data["user_id"] as? Int ?? 0
                    
                    let ts = data["joined_at"] as? Timestamp
                    let joined = ts?.dateValue()
                    
                    return RawMembership(
                        id: doc.documentID,
                        userId: userId,
                        joinedAt: joined
                    )
                }
                
                let userIds = Array(Set(memberships.map { $0.userId }))
                
                // 3️⃣ Join with Users to fetch full names
                self.fetchUserNames(for: userIds, memberships: memberships)
            }
    }
    
    
    // MARK: - Join to Users
    private func fetchUserNames(for userIds: [Int], memberships: [RawMembership]) {
        guard !userIds.isEmpty else {
            Task { @MainActor in
                self.isLoading = false
                self.members = []
            }
            return
        }
        
        db.collection("Users")
            .whereField("user_id", in: userIds)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                
                if let error = error {
                    Task { @MainActor in
                        self.isLoading = false
                        self.errorMessage = "Failed to load Users: \(error.localizedDescription)"
                    }
                    return
                }
                
                var namesByUserId: [Int: String] = [:]
                let docs = snapshot?.documents ?? []
                
                for doc in docs {
                    let data = doc.data()
                    let userId = data["user_id"] as? Int ?? 0
                    let name = data["full_name"] as? String ?? "Unknown"
                    namesByUserId[userId] = name
                }
                
                // Admin = earliest joinedAt
                let sortedMemberships = memberships.sorted {
                    ($0.joinedAt ?? .distantPast) < ($1.joinedAt ?? .distantPast)
                }
                
                var results: [MemberDisplay] = []
                
                for (idx, m) in sortedMemberships.enumerated() {
                    let name = namesByUserId[m.userId] ?? "Unknown"
                    results.append(
                        MemberDisplay(
                            id: m.id,
                            userId: m.userId,
                            name: name,
                            isAdmin: idx == 0
                        )
                    )
                }
                
                Task { @MainActor in
                    self.members = results
                    self.isLoading = false
                }
            }
    }
}


    

