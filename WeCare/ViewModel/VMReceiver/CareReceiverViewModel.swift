//
//  CareReceiverViewModel.swift
//  WeCare
//
//  Created by student on 27/11/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CareReceiverViewModel: ObservableObject {
    @Published var members: [Users] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    func fetchMembers(familyCode: String) {
        self.isLoading = true
        self.errorMessage = nil
        self.members = []
        
        print("step 1: Looking for family with code: \(familyCode)")
        
        // STEP 1: Find the Family ID from "Families" collection
        db.collection("Families")
            .whereField("family_code", isEqualTo: familyCode)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.setError("Error fetching family: \(error.localizedDescription)")
                    return
                }
                
                guard let familyDoc = snapshot?.documents.first else {
                    self.setError("Family code not found.")
                    return
                }
                
                // Get the numeric family_id (e.g., 1)
                guard let familyId = familyDoc.data()["family_id"] as? Int else {
                    self.setError("Family ID data format is wrong.")
                    return
                }
                
                print("step 1 success: Found family_id: \(familyId)")
                self.fetchUserIds(familyId: familyId)
            }
    }
    
    // STEP 2: Find User IDs from "FamilyMembers" collection
    private func fetchUserIds(familyId: Int) {
        db.collection("FamilyMembers")
            .whereField("family_id", isEqualTo: familyId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.setError("Error fetching members: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents, !docs.isEmpty else {
                    self.setError("This family has no members yet.")
                    return
                }
                
                // Extract all user_ids (e.g., [1, 2, 5])
                let userIds: [Int] = docs.compactMap { $0.data()["user_id"] as? Int }
                
                print("step 2 success: Found user_ids: \(userIds)")
                self.fetchUsersDetails(userIds: userIds)
            }
    }
    
    // STEP 3: Get actual User profiles from "Users" collection
    private func fetchUsersDetails(userIds: [Int]) {
        // Firestore 'in' query supports max 10 items.
        // If you have >10 members, you need to split this, but for now this works.
        guard !userIds.isEmpty else {
            self.isLoading = false
            return
        }
        
        db.collection("Users")
            .whereField("user_id", in: userIds)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error loading profiles: \(error.localizedDescription)"
                    return
                }
                
                guard let docs = snapshot?.documents else { return }
                
                self.members = docs.map { doc in
                    Users(id: doc.documentID, data: doc.data())
                }
                
                print("step 3 success: Loaded \(self.members.count) profiles.")
            }
    }
    
    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = message
            print("❌ \(message)")
        }
    }
}
