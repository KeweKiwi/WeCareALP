//
//  FamiliesViewModel.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore
import Combine   // Needed for ObservableObject & @Published

class FamiliesViewModel: ObservableObject {
    @Published var families: [Families] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    
    // ✅ FIXED: Changed "families" to "Families" (Case Sensitive!)
    private let collectionName = "Families"

    // MARK: - Fetch all families
    func fetchAllFamilies() {
        isLoading = true
        errorMessage = nil

        db.collection(collectionName)
            .order(by: "created_at", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false
                }

                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch families: \(error.localizedDescription)"
                        self.families = []
                    }
                    return
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.families = []
                    }
                    return
                }

                let fetched = documents.map { doc in
                    Families(id: doc.documentID, data: doc.data())
                }

                DispatchQueue.main.async {
                    self.families = fetched
                }
            }
    }

    // MARK: - Fetch single family by family_id (field)
    func fetchFamily(byFamilyId familyId: Int, completion: @escaping (Families?) -> Void) {
        db.collection(collectionName)
            .whereField("family_id", isEqualTo: familyId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to fetch family: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    completion(nil)
                    return
                }

                let family = Families(id: doc.documentID, data: doc.data())
                completion(family)
            }
    }

    // MARK: - Fetch family by family_code (join via code)
    func fetchFamily(byFamilyCode code: String, completion: @escaping (Families?) -> Void) {
        // Debug print to help you see what is happening
        print("🔍 Searching for code: '\(code)' in collection: '\(collectionName)'")
        
        db.collection(collectionName)
            // Make sure the field name in Firestore is exactly "family_code" (lowercase)
            // If your field is named "FamilyCode", change this line to "FamilyCode"
            .whereField("family_code", isEqualTo: code)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    print("⚠️ No family found with code: \(code)")
                    completion(nil)
                    return
                }

                print("✅ Found family: \(doc.data())")
                let family = Families(id: doc.documentID, data: doc.data())
                completion(family)
            }
    }
}
