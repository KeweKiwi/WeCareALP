import Foundation
import FirebaseFirestore


struct Users: Identifiable, Hashable {


    /// Firestore document ID
    let id: String


    /// Fields from Firestore
    let userId: Int
    let fullName: String
    let email: String
    let phoneNumber: String
    let password: String
    let role: String
    let gender: String
    let profileImageURL: String
    let createdAt: Date?


    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId          = data["user_id"] as? Int ?? 0
        self.fullName        = data["full_name"] as? String ?? ""
        self.email           = data["email"] as? String ?? ""
        self.phoneNumber     = data["phone_number"] as? String ?? ""
        self.password        = data["password"] as? String ?? ""
        self.role            = data["role"] as? String ?? ""
        self.gender          = data["gender"] as? String ?? ""
        self.profileImageURL = data["profile_image_url"] as? String ?? ""


        // convert Firestore Timestamp → Date
        if let ts = data["created_at"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }
    }
}





