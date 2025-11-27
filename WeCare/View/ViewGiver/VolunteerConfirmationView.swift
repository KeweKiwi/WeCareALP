//
//  VolunteerConfirmationView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//

import SwiftUI

struct VolunteerConfirmationView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator      // ⬅️ ambil dari Environment
    @StateObject var viewModel: VolunteerConfirmationVM
    @State private var showCompletionSheet: Bool = false
    
    var body: some View {
        VStack {
            if !viewModel.isAccepted {
                waitingView
            } else {
                approvedView
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Volunteer Status")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCompletionSheet) {
            VolunteerCompletionTipView(
                volunteer: viewModel.volunteer,
                isPresented: $showCompletionSheet,
                onSubmit: { tip in
                    viewModel.completeTask(withTip: tip)
                }
            )
        }
        // ⛔️ TIDAK pakai NavigationLink hidden lagi
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
    
    // MARK: - Approved View
    private var approvedView: some View {
        VStack(spacing: 8) {
            // 🔝 HEADER: Call & Video Call
            VStack(spacing: 8) {
                Text("Volunteer: \(viewModel.volunteer.name)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    NavigationLink(
                        destination: VolunteerCallView(volunteer: viewModel.volunteer)
                    ) {
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
                    
                    NavigationLink(
                        destination: VolunteerVideoCallView(volunteer: viewModel.volunteer)
                    ) {
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
            }
            .padding(.top, 8)
            
            Divider()
            
            // 🧾 SCROLL AREA
            ScrollView {
                VStack(spacing: 16) {
                    // Centang Approved
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#a6d17d").opacity(0.2))
                                .frame(width: 100, height: 100)
                            Circle()
                                .fill(Color(hex: "#a6d17d"))
                                .frame(width: 75, height: 75)
                            Image(systemName: "checkmark")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text("Request Approved")
                            .font(.title3.bold())
                            .foregroundColor(Color(hex: "#387b38"))
                        
                        Text("\(viewModel.volunteer.name) is ready to help.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                    
                    // Chat title + messages
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chat with \(viewModel.volunteer.name)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    
                    // Task completion & tip
                    if !viewModel.isTaskCompleted {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Status")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("Has the volunteer finished the task? You can mark it as done and send an optional tip.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            
                            Button(action: {
                                showCompletionSheet = true
                            }) {
                                Text("Mark as Done & Give Tip")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "#fdcb46"))
                                    .foregroundColor(.black)
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                        .padding(.top, 8)
                    } else {
                        // ✅ Task Completed + tombol ke root (GiverPersonListView)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Task Completed 🎉")
                                        .font(.headline)
                                        .foregroundColor(Color(hex: "#387b38"))
                                    
                                    if let tip = viewModel.givenTipAmount, !tip.isEmpty {
                                        Text("Tip sent: Rp \(tip)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("No tip was given.")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // ⬅️ trigger popToRoot lewat coordinator
                                    coordinator.popToRoot()          // atau: coordinator.shouldPopToRoot = true
                                }) {
                                    Image(systemName: "person.2.crop.square.stack.fill")
                                        .font(.title3)
                                        .foregroundColor(Color(hex: "#387b38"))
                                        .padding(6)
                                        .background(Color(hex: "#e1c7ec").opacity(0.4))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                .padding(.bottom, 8)
            }
            
            // 💬 Message input bar
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


