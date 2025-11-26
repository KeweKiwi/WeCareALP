//
//  JoinRequestsViewModel.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore
import Combine   // Needed for ObservableObject & @Published


class JoinRequestsViewModel: ObservableObject {
    @Published var joinRequests: [JoinRequests] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil


    private let db = Firestore.firestore()
    private let collectionName = "join_requests"  // Change if your Firestore collection name is different


    // MARK: - Fetch all join requests
    func fetchAllJoinRequests() {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .order(by: "requested_at", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch join requests: \(error.localizedDescription)"
                        self.joinRequests = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.joinRequests = []
                    }
                    return
                }


                let requests = documents.map { doc in
                    JoinRequests(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.joinRequests = requests
                }
            }
    }


    // MARK: - Fetch requests for a specific family
    func fetchJoinRequestsForFamily(_ familyId: Int) {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .whereField("family_id", isEqualTo: familyId)
            .order(by: "requested_at", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch join requests: \(error.localizedDescription)"
                        self.joinRequests = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.joinRequests = []
                    }
                    return
                }


                let requests = documents.map { doc in
                    JoinRequests(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.joinRequests = requests
                }
            }
    }
}






