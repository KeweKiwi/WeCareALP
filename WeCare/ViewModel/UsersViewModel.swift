import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class UsersTableViewModel: ObservableObject {

    @Published var users: [Users] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    init() {
        fetchUsers()
    }

    private func fetchUsers() {
        db.collection("Users")
            .addSnapshotListener { [weak self] snapshot, error in
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

                print("✅ Loaded \(self.users.count) users (no family filter)")
            }
    }
}



