import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: Users? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    var isLoggedIn: Bool {
        currentUser != nil
    }
    
    // MARK: - Email + Password login dari Firestore collection "Users"
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        errorMessage = nil
        isLoading = true
        
        db.collection("Users")
            .whereField("email", isEqualTo: email)
            .whereField("password", isEqualTo: password)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                
                Task { @MainActor in
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
    }
    
    // Dipakai untuk logout dari mana saja (Settings, dsb)
    func signOut() {
        currentUser = nil
        errorMessage = nil
    }
    
    // Alias biar di View kamu bisa pakai authVM.logout()
    func logout() {
        signOut()
    }
}



