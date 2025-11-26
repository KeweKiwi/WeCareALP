//
//  HealthVitalsViewModel.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore
import Combine   // Needed for ObservableObject & @Published


class HealthVitalsViewModel: ObservableObject {
    @Published var vitals: [HealthVitals] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil


    private let db = Firestore.firestore()
    private let collectionName = "health_vitals" // ganti sesuai nama koleksi di Firestore


    // MARK: - Fetch all vitals (for all users)
    func fetchAllVitals() {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch health vitals: \(error.localizedDescription)"
                        self.vitals = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.vitals = []
                    }
                    return
                }


                let fetched = documents.map { doc in
                    HealthVitals(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.vitals = fetched
                }
            }
    }


    // MARK: - Fetch vitals for specific user
    func fetchVitalsForUser(_ userId: Int) {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .whereField("user_id", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch health vitals: \(error.localizedDescription)"
                        self.vitals = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.vitals = []
                    }
                    return
                }


                let fetched = documents.map { doc in
                    HealthVitals(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.vitals = fetched
                }
            }
    }
}






