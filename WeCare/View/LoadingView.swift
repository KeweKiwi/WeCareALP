//
//  LoadingView.swift
//  WeCare
//
//  Created by student on 24/11/25.
//

import SwiftUI

struct LoadingView: View {
    @Binding var showMainView: Bool

    @State private var logoScale: CGFloat = 0.9
    @State private var logoGlow: Bool = false
    @State private var ringTrim: CGFloat = 0.0
    @State private var bgPulse: Bool = false
    @State private var fadeOut: Bool = false

    var body: some View {
        ZStack {
            // MARK: - LUX BACKGROUND
            LinearGradient(
                colors: [
                    Color(red: 10/255, green: 18/255, blue: 40/255),   // deep navy
                    Color(red: 24/255, green: 41/255, blue: 89/255),  // royal blue
                    Color(red: 250/255, green: 198/255, blue: 70/255) // warm gold glow
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                // soft blurred circles for luxury feel
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 260, height: 260)
                        .blur(radius: 40)
                        .offset(x: -120, y: -180)

                    Circle()
                        .fill(Color.yellow.opacity(0.20))
                        .frame(width: 220, height: 220)
                        .blur(radius: 50)
                        .offset(x: 130, y: 160)

                    Circle()
                        .fill(Color.blue.opacity(0.18))
                        .frame(width: 260, height: 260)
                        .blur(radius: 45)
                        .offset(x: 40, y: 40)
                }
            )
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.6), value: fadeOut)

            // MARK: - CONTENT
            VStack(spacing: 32) {
                ZStack {
                    // animated golden ring
                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(0.2),
                                    Color.white.opacity(0.9),
                                    Color.yellow.opacity(0.6),
                                    Color.white.opacity(0.9),
                                    Color.yellow.opacity(0.2)
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 210, height: 210)
                        .rotationEffect(.degrees(bgPulse ? 360 : 0))
                        .blur(radius: 0.3)
                        .shadow(color: .yellow.opacity(0.3), radius: 16, x: 0, y: 0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: bgPulse)
                        .animation(.easeOut(duration: 1.2), value: ringTrim)

                    // logo with subtle glow + scale
                    Image("wecare_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .scaleEffect(logoScale)
                        .shadow(color: Color.white.opacity(logoGlow ? 0.7 : 0.2),
                                radius: logoGlow ? 30 : 8,
                                x: 0, y: 0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: logoGlow)
                }

                VStack(spacing: 8) {
                    Text("Welcome to WeCare")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Connecting families with safe and smart care.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }

                // elegant progress indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.yellow.opacity(0.9)))
                    .scaleEffect(1.3)
                    .padding(.top, 4)
            }
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.5), value: fadeOut)
        }
        .onAppear {
            // start all animations
            logoScale = 1.02
            logoGlow = true
            ringTrim = 1.0
            bgPulse = true

            // simulate loading then transition to main view
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation {
                    fadeOut = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showMainView = false
                }
            }
        }
    }
}



