//
//  VolunteerActiveTaskView.swift
//  WeCare
//
//  Created by student on 03/12/25.
//
import SwiftUI

struct VolunteerActiveTaskView: View {
    let task: VolunteerRequest
    
    @State private var messages: [VolunteerChatMessage] = [
        VolunteerChatMessage(
            text: "Hi, I’m currently on my way to the pharmacy.",
            isFromCaregiver: false,
            time: "14:05"
        ),
        VolunteerChatMessage(
            text: "Alright, thank you. Please be careful 🙏",
            isFromCaregiver: true,
            time: "14:06"
        )
    ]
    @State private var newMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Helping \(task.careReceiverName)")
                    .font(.headline)
                Text("Caregiver: \(task.caregiverName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Label("\(task.distanceKm, specifier: "%.1f") km", systemImage: "location")
                    Spacer()
                    Text(task.offeredReward.asRupiah())
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            
            Divider()
            
            // Chat area
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages) { msg in
                        VolunteerChatBubble(message: msg)
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            
            Divider()
            
            // Bottom chat input (no mark-as-done button for volunteer)
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    TextField("Type a message…", text: $newMessage)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(hex: "#387b38"))
                            .clipShape(Circle())
                    }
                }
                
                Text("Only the caregiver can mark this task as completed.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)
            .background(Color.white)
        }
        .navigationTitle("Active Task")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(
            VolunteerChatMessage(
                text: trimmed,
                isFromCaregiver: false,
                time: "Now"
            )
        )
        newMessage = ""
    }
}

// MARK: - Chat Bubble
struct VolunteerChatBubble: View {
    let message: VolunteerChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCaregiver {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(12)
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 30)
            } else {
                Spacer(minLength: 30)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding(10)
                        .background(Color(hex: "#e1c7ec"))
                        .cornerRadius(12)
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}


