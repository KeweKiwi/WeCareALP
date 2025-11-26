//
//  VolunteerCallView.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import SwiftUI
import Combine

struct VolunteerCallView: View {
    let volunteer: Volunteer
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRinging: Bool = true
    @State private var isConnected: Bool = false
    @State private var callDuration: Int = 0
    @State private var isMuted: Bool = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Full background
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
                    
                    Text(volunteer.name)
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
                
                // Ringing effect
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
                    // Simulate Answer (Prototype)
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
                        // Mute button
                        Button(action: {
                            isMuted.toggle()
                        }) {
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        // End Call
                        Button(action: {
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
    
    // MARK: - Helpers
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}



