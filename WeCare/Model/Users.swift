import Foundation
import FirebaseFirestore


struct Users: Identifiable, Hashable {
    /// id = Firestore document ID (bukan user_id angka)
    let id: String


    let userId: Int
    let familyId: Int
    let fullName: String
    let email: String
    let phoneNumber: String
    let password: String
    let role: String
    let gender: String
    let isAdmin: Bool
    let profileImageURL: String
    let createdAt: Date?


    /// Init dari Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id


        self.userId        = data["user_id"] as? Int ?? 0
        self.familyId      = data["family_id"] as? Int ?? 0
        self.fullName      = data["full_name"] as? String ?? ""
        self.email         = data["email"] as? String ?? ""
        self.phoneNumber   = data["phone_number"] as? String ?? ""
        self.password      = data["password"] as? String ?? ""
        self.role          = data["role"] as? String ?? ""
        self.gender        = data["gender"] as? String ?? ""
        self.isAdmin       = data["is_admin"] as? Bool ?? false
        self.profileImageURL = data["profile_image_url"] as? String ?? ""


        let ts = data["created_at"] as? Timestamp
        self.createdAt = ts?.dateValue()
    }
}





