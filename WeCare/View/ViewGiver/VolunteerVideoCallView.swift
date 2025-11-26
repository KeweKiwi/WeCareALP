//
//  VolunteerVideoCallView.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import SwiftUI
import CoreLocation
import Combine

struct VolunteerVideoCallView: View {
    let volunteer: Volunteer
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRinging: Bool = true
    @State private var isConnected: Bool = false
    @State private var isMuted: Bool = false
    @State private var isCameraOff: Bool = false
    @State private var callDuration: Int = 0
    
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
                    
                    Text(volunteer.name)
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
                    // Remote video (VOLUNTEER) – besar dengan nama di tengah
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                        
                        VStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            Text(volunteer.name)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Local preview (CAREGIVER) – kecil (PiP) di kanan bawah
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            ZStack(alignment: .bottomTrailing) {
                                // Kotak kamera kecil
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isCameraOff ? Color.gray.opacity(0.85)
                                                      : Color.black.opacity(0.85))
                                    .frame(width: 120, height: 160)
                                
                                // Isi utama (ikon + text) di TENGAH
                                VStack(spacing: 6) {
                                    if isCameraOff {
                                        Image(systemName: "video.slash.fill")
                                            .font(.system(size: 36))
                                            .foregroundColor(.white)
                                        Text("Camera Off")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.9))
                                    } else {
                                        Image(systemName: "person.crop.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        Text("You")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                .frame(width: 120, height: 160) // supaya benar-benar center
                                
                                // Status MIC (off-mic) di pojok kanan bawah DALAM kotak
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
                
                // SIMULATE ANSWER (Prototype)
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
                    Button(action: {
                        isMuted.toggle()
                    }) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.9))
                            .clipShape(Circle())
                    }
                    
                    // Camera toggle (POV caregiver / kotak kecil)
                    Button(action: {
                        isCameraOff.toggle()
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
    }
    
    // MARK: - Helpers
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}


