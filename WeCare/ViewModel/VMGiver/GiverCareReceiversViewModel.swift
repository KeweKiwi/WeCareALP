import Foundation
import Combine
import FirebaseFirestore


@MainActor
final class GiverCareReceiversViewModel: ObservableObject {
    @Published var persons: [GiverPersonCardViewData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    /// Panggil ini dari View dengan userId si caregiver yang login
    func load(for caregiverUserId: Int) {
        isLoading = true
        errorMessage = nil
        persons = []
        
        var users: [Users] = []
        var families: [Families] = []
        var memberships: [FamilyMembers] = []
        var vitals: [HealthVitals] = []
        
        let group = DispatchGroup()
        var firstError: Error?
        
        func captureError(_ error: Error) {
            if firstError == nil {
                firstError = error
            }
        }
        
        // 🔹 1. Users
        group.enter()
        db.collection("Users")
            .getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    captureError(error)
                    return
                }
                guard let docs = snapshot?.documents else { return }
                users = docs.map { Users(id: $0.documentID, data: $0.data()) }
            }
        
        // 🔹 2. Families
        group.enter()
        db.collection("Families")
            .getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    captureError(error)
                    return
                }
                guard let docs = snapshot?.documents else { return }
                families = docs.map { Families(id: $0.documentID, data: $0.data()) }
            }
        
        // 🔹 3. Family Members
        group.enter()
        db.collection("FamilyMembers")
            .getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    captureError(error)
                    return
                }
                guard let docs = snapshot?.documents else { return }
                memberships = docs.map { FamilyMembers(id: $0.documentID, data: $0.data()) }
            }
        
        // 🔹 4. Health Vitals
        group.enter()
        db.collection("HealthVitals")
            .getDocuments { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    captureError(error)
                    return
                }
                guard let docs = snapshot?.documents else { return }
                vitals = docs.map { HealthVitals(id: $0.documentID, data: $0.data()) }
            }
        
        // 🔹 5. Setelah semua selesai
        group.notify(queue: .main) {
            self.isLoading = false
            
            if let error = firstError {
                self.errorMessage = "Failed to load data: \(error.localizedDescription)"
                self.persons = []
                return
            }
            
            self.persons = Self.buildPersons(
                caregiverUserId: caregiverUserId,
                users: users,
                families: families,
                memberships: memberships,
                vitals: vitals
            )
        }
    }
    
    // MARK: - Join logic (caregiver → keluarga → careReceiver → vitals)
    private static func buildPersons(
        caregiverUserId: Int,
        users: [Users],
        families: [Families],
        memberships: [FamilyMembers],
        vitals: [HealthVitals]
    ) -> [GiverPersonCardViewData] {
        
        // Index untuk join cepat
        let usersByUserId: [Int: Users] = Dictionary(
            uniqueKeysWithValues: users.map { ($0.userId, $0) }
        )
        
        let familiesByFamilyId: [Int: Families] = Dictionary(
            uniqueKeysWithValues: families.map { ($0.familyId, $0) }
        )
        
        let latestVitalsByUserId: [Int: HealthVitals] = Dictionary(
            grouping: vitals,
            by: { $0.userId }
        ).compactMapValues { vitalsForUser in
            vitalsForUser
                .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
                .first
        }
        
        // 1️⃣ Keluarga yang dimiliki caregiver yang login
        let caregiverFamilyIds: Set<Int> = Set(
            memberships
                .filter { $0.userId == caregiverUserId }
                .map { $0.familyId }
        )
        
        if caregiverFamilyIds.isEmpty {
            print("⚠️ Caregiver \(caregiverUserId) tidak punya family_id di family_members")
        }
        
        // 2️⃣ Ambil semua membership di keluarga-keluarga itu
        let membershipsInMyFamilies = memberships.filter { membership in
            caregiverFamilyIds.contains(membership.familyId)
        }
        
        // 3️⃣ Dari membership ini, HANYA ambil user yang role-nya careReceiver
        let persons: [GiverPersonCardViewData] = membershipsInMyFamilies.compactMap { membership in
            guard let user = usersByUserId[membership.userId] else {
                return nil
            }
            
            // role careReceiver disimpan di Users.role → "careReceiver"
            let normalizedRole = user.role
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()          // "careReceiver" → "carereceiver"
            
            guard normalizedRole == "carereceiver" else {
                // skip kalau dia bukan careReceiver (misal caregiver / anak / dsb)
                return nil
            }
            
            guard let family = familiesByFamilyId[membership.familyId] else {
                return nil
            }
            
            let vital = latestVitalsByUserId[user.userId]
            let heartRate = vital?.heartRate ?? 0
            let steps = vital?.steps ?? 0
            
            let status: GiverPersonCardViewData.Status
            if heartRate == 0 && steps == 0 {
                status = .warning
            } else if heartRate > 100 || steps < 500 {
                status = .critical
            } else {
                status = .healthy
            }
            
            return GiverPersonCardViewData(
                name: user.fullName,
                role: user.role,   // "careReceiver"
                avatarURL: user.profileImageURL.isEmpty ? nil : user.profileImageURL,
                status: status,
                heartRate: heartRate,
                steps: steps,
                familyCode: family.familyCode,
                familyMembers: []     // bisa diisi nama anggota lain nanti kalau mau
            )
        }
        
        return persons
    }
}





