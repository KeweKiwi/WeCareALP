//
//  VolunteerConfirmationVM.swift
//  WeCare
//
//  Created by student on 24/11/25.
//

import Foundation
import Combine

final class VolunteerConfirmationVM: ObservableObject {
    @Published var volunteer: Volunteer
    @Published var isAccepted: Bool = false
    
    @Published var messages: [ChatMessage]
    @Published var newMessage: String = ""
    
    // NEW: Task completion & tip
    @Published var isTaskCompleted: Bool = false
    @Published var givenTipAmount: String? = nil   // nil = tidak ada tip
    
    init(volunteer: Volunteer) {
        self.volunteer = volunteer
        
        // Dummy chat awal (seperti Gojek)
        self.messages = [
            ChatMessage(
                id: UUID(),
                text: "Hello, I received your request. I will arrive in about 20 minutes.",
                isFromVolunteer: true,
                time: "09:10"
            ),
            ChatMessage(
                id: UUID(),
                text: "Thank you! Please help my mother with her medication and walking exercise.",
                isFromVolunteer: false,
                time: "09:11"
            )
        ]
    }
    
    func simulateAcceptance() {
        isAccepted = true
    }
    
    func sendMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let message = ChatMessage(
            id: UUID(),
            text: trimmed,
            isFromVolunteer: false,
            time: Self.currentTimeString()
        )
        
        messages.append(message)
        newMessage = ""
    }
    
    /// Dipanggil setelah caregiver menandai tugas selesai dan (opsional) memberi tip
    func completeTask(withTip tip: String?) {
        isTaskCompleted = true
        givenTipAmount = tip
    }
    
    // MARK: - Helpers
    
    private static func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}


