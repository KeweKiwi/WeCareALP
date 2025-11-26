//
//  FamilyMembersViewModel.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore
import Combine   // Needed for ObservableObject & @Published


class FamilyMembersViewModel: ObservableObject {
    @Published var members: [FamilyMembers] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil


    private let db = Firestore.firestore()
    private let collectionName = "family_members" // ganti kalau nama koleksi beda


    // MARK: - Fetch all family members (all families)
    func fetchAllMembers() {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .order(by: "joined_at", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch family members: \(error.localizedDescription)"
                        self.members = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.members = []
                    }
                    return
                }


                let fetched = documents.map { doc in
                    FamilyMembers(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.members = fetched
                }
            }
    }


    // MARK: - Fetch members for a specific family
    func fetchMembersForFamily(_ familyId: Int) {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .whereField("family_id", isEqualTo: familyId)
            .order(by: "joined_at", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch family members: \(error.localizedDescription)"
                        self.members = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.members = []
                    }
                    return
                }


                let fetched = documents.map { doc in
                    FamilyMembers(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.members = fetched
                }
            }
    }


    // MARK: - Fetch memberships for a specific user (which families they belong to)
    func fetchMembershipsForUser(_ userId: Int) {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .whereField("user_id", isEqualTo: userId)
            .order(by: "joined_at", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch memberships: \(error.localizedDescription)"
                        self.members = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.members = []
                    }
                    return
                }


                let fetched = documents.map { doc in
                    FamilyMembers(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.members = fetched
                }
            }
    }
}






