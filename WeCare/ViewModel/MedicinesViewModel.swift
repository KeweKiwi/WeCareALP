//
//  MedicinesViewModel.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore
import Combine

class MedicinesViewModel: ObservableObject {
    @Published var medicines: [Medicines] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private let collectionName = "Medicines"

    // MARK: - Fetch all medicines
    func fetchAllMedicines() {
        print("🔍 MedicinesViewModel: fetchAllMedicines() called")
        isLoading = true
        errorMessage = nil

        db.collection(collectionName)
            .order(by: "medicine_name", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false
                }

                if let error = error {
                    print("❌ MedicinesViewModel: Error fetching medicines - \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch medicines: \(error.localizedDescription)"
                        self.medicines = []
                    }
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ MedicinesViewModel: No documents found")
                    DispatchQueue.main.async {
                        self.medicines = []
                    }
                    return
                }

                print("📥 MedicinesViewModel: Found \(documents.count) medicine documents")

                let fetched = documents.map { doc -> Medicines in
                    let medicine = Medicines(id: doc.documentID, data: doc.data())
                    print("  → Medicine: id=\(medicine.medicineId), name=\(medicine.medicineName), image=\(medicine.medicineImage)")
                    return medicine
                }

                DispatchQueue.main.async {
                    self.medicines = fetched
                    print("✅ MedicinesViewModel: Published \(fetched.count) medicines")
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
