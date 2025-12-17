//
//  VolunteerPendingApprovalView.swift
//  WeCare
//
//  Created by student on 09/12/25.
//
import SwiftUI

struct VolunteerPendingApprovalView: View {
    @ObservedObject var viewModel: VolunteerModeVM
    
    @State private var hasAppeared = false
    @State private var rotationAngle: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Animated hourglass icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color(hex: "#fdcb46").opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(hasAppeared ? 1.2 : 0.8)
                    .opacity(hasAppeared ? 0 : 1)
                    .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: hasAppeared)
                
                Image(systemName: "hourglass.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color(hex: "#fdcb46"))
                    .rotationEffect(.degrees(rotationAngle))
                    .scaleEffect(hasAppeared ? 1 : 0.5)
                    .opacity(hasAppeared ? 1 : 0)
            }
            .padding(.bottom, 10)
            
            Text("Your volunteer profile is being reviewed")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
            
            if let profile = viewModel.profile {
                VStack(spacing: 12) {
                    Text("Thank you, \(profile.name). For safety reasons, our team will review your information before you can receive requests.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                    
                    // Shimmer progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            // Shimmer effect
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color(hex: "#fdcb46").opacity(0.3),
                                            Color(hex: "#fdcb46").opacity(0.6),
                                            Color(hex: "#fdcb46").opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 100, height: 8)
                                .offset(x: shimmerOffset)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 40)
                    .opacity(hasAppeared ? 1 : 0)
                }
            } else {
                Text("For safety reasons, our team will review your information before you can receive requests.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
            }
            
            // Info tambahan
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(Color(hex: "#a6d17d"))
                    .scaleEffect(hasAppeared ? 1 : 0)
                
                Text("This helps us keep caregivers and care receivers safe by making sure each volunteer is verified.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            .opacity(hasAppeared ? 1 : 0)
            
            Spacer()
            
            // Simulation link with subtle pulse
            VStack(spacing: 8) {
                Text("Simulate: admin approved my volunteer profile")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .underline()
                    .scaleEffect(hasAppeared ? 1 : 0.9)
                    .onTapGesture {
                        // Haptic feedback
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.approveRegistration()
                        }
                    }
                
                Text("Prototype only – in a real app, approval would be done by the WeCare admin team.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 24)
            .opacity(hasAppeared ? 1 : 0)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Pending Approval")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Main entrance animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                hasAppeared = true
            }
            
            // Hourglass rotation animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                shimmerOffset = UIScreen.main.bounds.width + 100
            }
        }
    }
}

