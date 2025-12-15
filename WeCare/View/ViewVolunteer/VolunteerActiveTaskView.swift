//
//  VolunteerActiveTaskView.swift
//  WeCare
//
//  Created by student on 03/12/25.
//
import SwiftUI
import Combine
import AVFoundation

struct VolunteerActiveTaskView: View {
    let task: VolunteerRequest
    @ObservedObject var viewModel: VolunteerModeVM
    @Environment(\.dismiss) private var dismiss
    
    @State private var messages: [VolunteerChatMessage] = [
        VolunteerChatMessage(
            text: "Hi, could you please buy the medicine at the nearest pharmacy?",
            isFromCaregiver: true,
            time: "14:05"
        ),
        VolunteerChatMessage(
            text: "Sure, I’m on my way now.",
            isFromCaregiver: false,
            time: "14:06"
        )
    ]
    @State private var newMessage: String = ""
    
    // 🔹 Alert state
    @State private var showCompletionAlert: Bool = false
    @State private var lastTipAmount: Int? = nil
    @State private var lastRating: Int? = nil
    
    var body: some View {
        VStack(spacing: 8) {
            // Header: Call & Video Call
            VStack(spacing: 8) {
                Text("Caregiver: \(task.caregiverName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    NavigationLink(
                        destination: VolunteerTaskCallView(contactName: task.caregiverName)
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
                        destination: VolunteerTaskVideoCallView(contactName: task.caregiverName)
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
            
            // Scroll area
            ScrollView {
                VStack(spacing: 16) {
                    // Info task
                    VStack(spacing: 8) {
                        Text("Active Task")
                            .font(.title3.bold())
                            .foregroundColor(Color(hex: "#387b38"))
                        
                        Text("Helping \(task.careReceiverName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            Label("\(task.distanceKm, specifier: "%.1f") km away",
                                  systemImage: "location.fill")
                            Spacer()
                            Text(task.offeredReward.asRupiah())
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // ⬅️ NEW: link ke detail task (tanpa tombol Accept/Decline)
                    HStack {
                        NavigationLink {
                            VolunteerRequestDetailView(
                                request: task,
                                viewModel: viewModel,
                                showActionButtons: false
                            )
                        } label: {
                            HStack(spacing: 4) {
                                Text("View full task details")
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .font(.caption)
                            .foregroundColor(Color(hex: "#387b38"))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Chat title + messages
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chat with \(task.caregiverName)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(messages) { msg in
                                VolunteerChatBubble(message: msg)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Input + simulate link
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    TextField("Type a message...", text: $newMessage)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(hex: "#387b38"))
                            .clipShape(Circle())
                    }
                }
                
                // 🔹 Simulate caregiver mark as done + tip + rating
                Text("Simulate: caregiver marked this task as completed")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .underline()
                    .onTapGesture {
                        let simulatedTip = 20000
                        let simulatedRating = 5
                        
                        lastTipAmount = simulatedTip
                        lastRating = simulatedRating
                        
                        viewModel.markTaskCompleted(
                            task,
                            tip: simulatedTip,
                            rating: simulatedRating
                        )
                        
                        showCompletionAlert = true
                    }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Active Task")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showCompletionAlert) {
            let tipText: String
            if let tip = lastTipAmount {
                tipText = "You received a tip of \(tip.asRupiah())."
            } else {
                tipText = "No tip was given."
            }
            
            let ratingText: String
            if let rating = lastRating {
                ratingText = "You received a \(rating)-star rating."
            } else {
                ratingText = "No rating was given."
            }
            
            return Alert(
                title: Text("Task Completed"),
                message: Text("\(tipText)\n\(ratingText)"),
                dismissButton: .default(Text("OK")) {
                    dismiss()
                }
            )
        }
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

// MARK: - Simple Call View (POV Volunteer → Caregiver)
struct VolunteerTaskCallView: View {
    let contactName: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var isRinging: Bool = true
    @State private var isConnected: Bool = false
    @State private var callDuration: Int = 0
    @State private var isMuted: Bool = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Avatar & Name
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 110, height: 110)
                        .foregroundColor(Color(hex: "#91bef8"))
                    
                    Text(contactName)
                        .font(.title.bold())
                    
                    if isRinging && !isConnected {
                        Text("Ringing...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    } else if isConnected {
                        Text(formatDuration(callDuration))
                            .font(.headline.monospacedDigit())
                            .foregroundColor(.gray)
                    }
                }
                
                // Ringing effect / status
                if isRinging && !isConnected {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "#fdcb46"), lineWidth: 4)
                            .frame(width: 160, height: 160)
                            .opacity(0.4)
                        Circle()
                            .stroke(Color(hex: "#a6d17d"), lineWidth: 4)
                            .frame(width: 130, height: 130)
                            .opacity(0.7)
                        Image(systemName: "phone.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#387b38"))
                    }
                } else if isConnected {
                    Text("On Call")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#387b38"))
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    // Simulate Answer
                    if isRinging && !isConnected {
                        Button(action: {
                            withAnimation(.spring()) {
                                isRinging = false
                                isConnected = true
                            }
                        }) {
                            Text("Simulate Answer (Prototype)")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#387b38"))
                        }
                    }
                    
                    HStack(spacing: 40) {
                        // Mute
                        Button(action: { isMuted.toggle() }) {
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        // End call
                        Button(action: { dismiss() }) {
                            Image(systemName: "phone.down.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "#fa6255"))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .navigationBarTitle("Call", displayMode: .inline)
        .onReceive(timer) { _ in
            if isConnected {
                callDuration += 1
            }
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Simple Video Call View (POV Volunteer → Caregiver)
struct VolunteerTaskVideoCallView: View {
    let contactName: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRinging: Bool = true
    @State private var isConnected: Bool = false
    @State private var isMuted: Bool = false
    @State private var isCameraOff: Bool = false
    @State private var callDuration: Int = 0
    
    @StateObject private var camera = CameraService()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // TOP INFO
                VStack(spacing: 4) {
                    Text("Video Call with")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(contactName)
                        .font(.title2.bold())
                    
                    if isRinging && !isConnected {
                        Text("Ringing...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    } else if isConnected {
                        Text(formatDuration(callDuration))
                            .font(.headline.monospacedDigit())
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 10)
                
                // VIDEO AREA
                ZStack(alignment: .bottomTrailing) {
                    // Remote video – contact (caregiver)
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                        
                        VStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            Text(contactName)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Local preview – volunteer (you) => KAMERA BENERAN
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            ZStack(alignment: .bottomTrailing) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isCameraOff ? Color.gray.opacity(0.85)
                                                      : Color.black.opacity(0.85))
                                    .frame(width: 120, height: 160)
                                
                                ZStack {
                                    if isCameraOff {
                                        VStack(spacing: 6) {
                                            Image(systemName: "video.slash.fill")
                                                .font(.system(size: 36))
                                                .foregroundColor(.white)
                                            Text("Camera Off")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    } else {
                                        CameraPreviewView(session: camera.session)
                                            .overlay(
                                                Group {
                                                    if let err = camera.lastError {
                                                        Text(err)
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.white)
                                                            .padding(6)
                                                            .background(Color.red.opacity(0.75))
                                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                                            .padding(6)
                                                    }
                                                },
                                                alignment: .topLeading
                                            )
                                            .overlay(
                                                Text("You")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .padding(6),
                                                alignment: .bottomLeading
                                            )
                                    }
                                }
                                .frame(width: 120, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                if isMuted {
                                    Image(systemName: "mic.slash.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.red.opacity(0.85))
                                        .clipShape(Circle())
                                        .padding(.trailing, 6)
                                        .padding(.bottom, 6)
                                }
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 28)
                        }
                    }
                }
                .frame(height: 380)
                
                Spacer()
                
                // SIMULATE ANSWER
                if isRinging && !isConnected {
                    Button(action: {
                        withAnimation(.spring()) {
                            isRinging = false
                            isConnected = true
                        }
                    }) {
                        Text("Simulate Answer (Prototype)")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#387b38"))
                    }
                }
                
                // BOTTOM CONTROLS
                HStack(spacing: 40) {
                    // Mute
                    Button(action: { isMuted.toggle() }) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.9))
                            .clipShape(Circle())
                    }
                    
                    // Camera toggle
                    Button(action: {
                        isCameraOff.toggle()
                        if isCameraOff {
                            camera.stop()
                        } else {
                            camera.startFrontCamera()
                        }
                    }) {
                        Image(systemName: isCameraOff ? "video.slash.fill" : "video.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#91bef8"))
                            .clipShape(Circle())
                    }
                    
                    // End call
                    Button(action: {
                        camera.stop()
                        dismiss()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#fa6255"))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitle("Video Call", displayMode: .inline)
        .onReceive(timer) { _ in
            if isConnected {
                callDuration += 1
            }
        }
        .onAppear {
            if !isCameraOff {
                camera.startFrontCamera()
            }
        }
        .onDisappear {
            camera.stop()
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

