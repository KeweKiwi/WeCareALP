import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class GiverSettingsVM: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var gender: String = "Male"
    @Published var password: String = "********"   // hanya untuk UI, tidak disimpan plain text
    @Published var phone: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        loadUser()
    }
    
    func loadUser() {
        isLoading = true
        errorMessage = nil
        
        db.collection("Users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                
                if let error = error {
                    print("❌ Load giver user error:", error)
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("⚠️ User not found for id:", self.userId)
                    return
                }
                
                self.name = data["full_name"] as? String ?? ""
                self.email = data["email"] as? String ?? ""
                self.gender = data["gender"] as? String ?? "Male"
                self.phone = data["phone_number"] as? String ?? ""
                
                // Password sengaja tidak diisi dari database
                self.password = "********"
            }
        }
    }
    
    func saveChanges(completion: (() -> Void)? = nil) {
        errorMessage = nil
        
        let updateData: [String: Any] = [
            "full_name": name,
            "email": email,
            "gender": gender,
            "phone_number": phone
            // password tidak disimpan di sini
        ]
        
        db.collection("Users").document(userId).setData(updateData, merge: true) { [weak self] error in
            guard let self else { return }
            Task { @MainActor in
                if let error = error {
                    print("❌ Save giver user error:", error)
                    self.errorMessage = error.localizedDescription
                } else {
                    print("✅ Giver user \(self.userId) updated")
                    completion?()
                }
            }
        }
    }
    
    func reloadData() {
        loadUser()
    }

}


