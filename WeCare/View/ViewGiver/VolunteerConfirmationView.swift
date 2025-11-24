//
//  VolunteerConfirmationView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import SwiftUI

struct VolunteerConfirmationView: View {
    @StateObject var viewModel: VolunteerConfirmationVM
    
    var body: some View {
        VStack(spacing: 20) {
            if !viewModel.isAccepted {
                // STATE: WAITING FOR ACCEPTANCE
                waitingView
            } else {
                // STATE: ACCEPTED → APPROVED + CHAT + CALL / VIDEO
                approvedView
            }
        }
        .padding(.top)
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Volunteer Status")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Waiting View
    private var waitingView: some View {
        VStack(spacing: 20) {
            Text("Request Sent")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "#387b38"))
                .padding(.top)
            
            Text("Waiting for \(viewModel.volunteer.name) to accept...")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.simulateAcceptance()
                }
            }) {
                Text("Simulate Acceptance")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#fdcb46"))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .shadow(radius: 3)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Approved View (Chat + Call)
    private var approvedView: some View {
        VStack(spacing: 16) {
            // Centang Approved
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#a6d17d").opacity(0.2))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(Color(hex: "#a6d17d"))
                        .frame(width: 90, height: 90)
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Request Approved")
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: "#387b38"))
                
                Text("\(viewModel.volunteer.name) is ready to help.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top)
            
            // Tombol Call & Video Call
            HStack(spacing: 16) {
                Button(action: {
                    // TODO: integrate phone call
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#91bef8"))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                }
                
                Button(action: {
                    // TODO: integrate video call
                }) {
                    HStack {
                        Image(systemName: "video.fill")
                        Text("Video Call")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#fa6255"))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            
            // Chat title
            VStack(alignment: .leading, spacing: 8) {
                Text("Chat with \(viewModel.volunteer.name)")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Messages list
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
            }
            
            // Message input
            HStack(spacing: 10) {
                TextField("Type a message...", text: $viewModel.newMessage)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color(hex: "#387b38"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Chat Bubble View

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromVolunteer {
                // Volunteer di kiri
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
                // Caregiver di kanan
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

// MARK: - Preview (opsional)

//#Preview {
//    let dummyVolunteer = Volunteer(
//        name: "Alice Johnson",
//        rating: 4.8,
//        distance: "1.2 km",
//        age: 28,
//        gender: "Female",
//        specialty: "Elderly Care, Medicine Reminder",
//        restrictions: "No heavy lifting",
//        coordinate: .init(latitude: -6.2, longitude: 106.8)
//    )
//    VolunteerConfirmationView(viewModel: VolunteerConfirmationVM(volunteer: dummyVolunteer))
//}
