import Foundation


enum AgendaType: String, Codable {
    case activity = "Activity"
    case medicine = "Medicine"
}


struct AgendaItem: Identifiable, Hashable, Codable {


    // MARK: - Identity
    var id: String                 // Firestore document ID


    // MARK: - Core Info
    var title: String
    var description: String
    var time: String               // "08:00 AM"
    var date: String               // "2025-11-12"
    var status: UrgencyStatus
    var type: AgendaType


    // MARK: - Caregiver (who CREATED the task)
    var ownerId: String            // caregiver userId (string / doc id)
    var ownerName: String          // caregiver name (UI/debug)


    // MARK: - Receiver (who the task is FOR) ✅ FIXED
    var receiverId: Int            // ✅ REQUIRED (careReceiver_id)
    var receiverName: String       // receiver fullName (UI display)


    // MARK: - Medicine (optional)
    var medicineId: Int?
    var medicineName: String?
    var medicineImage: String?


    // MARK: - Completion
    var isCompleted: Bool = false


    // MARK: - Initializer
    init(
        id: String,
        title: String,
        description: String,
        time: String,
        date: String,
        status: UrgencyStatus,
        type: AgendaType,
        ownerId: String,
        ownerName: String,
        receiverId: Int,            // ✅ ADD THIS
        receiverName: String,       // ✅ KEEP THIS
        medicineId: Int? = nil,
        medicineName: String? = nil,
        medicineImage: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.time = time
        self.date = date
        self.status = status
        self.type = type
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.receiverId = receiverId        // ✅
        self.receiverName = receiverName    // ✅
        self.medicineId = medicineId
        self.medicineName = medicineName
        self.medicineImage = medicineImage
        self.isCompleted = isCompleted
    }
}





