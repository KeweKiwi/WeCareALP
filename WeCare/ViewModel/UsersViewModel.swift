import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class UsersTableViewModel: ObservableObject {

    @Published var users: [Users] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let familyIdFilter: Int?

    /// familyId: kalau mau filter family_id tertentu, misalnya 1; kalau tidak, biarkan nil
    init(familyId: Int? = nil) {
        self.familyIdFilter = familyId
        fetchUsers()
    }

    private func fetchUsers() {
        var query: Query = db.collection("Users")

        if let familyId = familyIdFilter {
            query = query.whereField("family_id", isEqualTo: familyId)
        }

        query.addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }

            if let error = error {
                print("❌ Users listen error:", error)
                self.errorMessage = error.localizedDescription
                return
            }

            guard let docs = snapshot?.documents else {
                self.users = []
                return
            }

            self.users = docs.map { doc in
                Users(id: doc.documentID, data: doc.data())
            }

            print("✅ Loaded \(self.users.count) users")
        }
    }
}



