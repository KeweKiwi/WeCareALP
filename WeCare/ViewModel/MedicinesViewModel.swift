//
//  MedicinesViewModel.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore
import Combine   // needed for ObservableObject & @Published


class MedicinesViewModel: ObservableObject {
    @Published var medicines: [Medicines] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil


    private let db = Firestore.firestore()
    private let collectionName = "Medicines" // ganti kalau nama koleksi beda


    // MARK: - Fetch all medicines
    func fetchAllMedicines() {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .order(by: "medicine_name", descending: false) // optional sort
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }


                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch medicines: \(error.localizedDescription)"
                        self.medicines = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.medicines = []
                    }
                    return
                }


                let fetched = documents.map { doc -> Medicines in
                    Medicines(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.medicines = fetched
                }
            }
    }


    // MARK: - Fetch medicines by ID (medicine_id field, not document ID)
    func fetchMedicine(byMedicineId medicineId: Int, completion: @escaping (Medicines?) -> Void) {
        db.collection(collectionName)
            .whereField("medicine_id", isEqualTo: medicineId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch medicine: \(error.localizedDescription)")
                    completion(nil)
                    return
                }


                guard let document = snapshot?.documents.first else {
                    completion(nil)
                    return
                }


                let medicine = Medicines(id: document.documentID, data: document.data())
                completion(medicine)
            }
    }
}





