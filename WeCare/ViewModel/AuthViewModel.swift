//
//  AuthViewModel.swift
//  WeCare
//
//  Created by student on 03/12/25.
//

import Foundation
import Combine
import FirebaseFirestore

final class AuthViewModel: ObservableObject {
    @Published var currentUser: Users? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    var isLoggedIn: Bool { currentUser != nil }
    
    // MARK: - Email + Password (from Firestore collection "users")
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil
        isLoading = true
        
        db.collection("Users")    // 👈 HERE
            .whereField("email", isEqualTo: email)
            .whereField("password", isEqualTo: password)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    self.errorMessage = "Email or password is incorrect."
                    completion(false)
                    return
                }
                
                let user = Users(id: doc.documentID, data: doc.data())
                self.currentUser = user
                completion(true)
            }
    }



    
    func signOut() {
        currentUser = nil
        errorMessage = nil
    }
}



