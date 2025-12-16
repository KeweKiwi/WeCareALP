import SwiftUI

struct LoadingView: View {
    @Binding var showMainView: Bool

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var logoY: CGFloat = -50
    @State private var ringTrim: CGFloat = 0.0
    @State private var ringRotation: Double = 0
    @State private var pulseAnimation = false
    @State private var textOpacity: Double = 0
    @State private var textScale: CGFloat = 0.8
    @State private var progressOpacity: Double = 0
    @State private var fadeOut: Bool = false
    @State private var floatingOffset1: CGFloat = 0
    @State private var floatingOffset2: CGFloat = 0
    @State private var floatingOffset3: CGFloat = 0
    @State private var particleOffset1: CGFloat = 0
    @State private var particleOffset2: CGFloat = 0
    @State private var morphScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0
    @State private var energyWaveScale: CGFloat = 0.8
    @State private var energyWaveOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var orbScale1: CGFloat = 0
    @State private var orbScale2: CGFloat = 0
    @State private var orbScale3: CGFloat = 0
    @State private var orbitRotation: Double = 0

    var body: some View {
        ZStack {
            // MARK: - Elegant Background
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.95, green: 0.96, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        // Gentle floating hearts
                        ForEach(0..<4) { i in
                            Image(systemName: "heart.fill")
                                .font(.system(size: CGFloat(18 + i * 6)))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Brand.red.opacity(0.08), Brand.sky.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .offset(
                                    x: CGFloat(40 + i * 85),
                                    y: geometry.size.height * CGFloat(0.2 + Double(i) * 0.15) + floatingOffset1
                                )
                                .blur(radius: 2)
                                .rotationEffect(.degrees(Double(i * 25)))
                        }
                        
                        // Care symbols
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 35))
                            .foregroundStyle(Brand.sky.opacity(0.06))
                            .offset(x: geometry.size.width - 70, y: geometry.size.height * 0.25 + floatingOffset2)
                            .blur(radius: 3)
                        
                        Image(systemName: "figure.2.arms.open")
                            .font(.system(size: 32))
                            .foregroundStyle(Brand.red.opacity(0.06))
                            .offset(x: 50, y: geometry.size.height * 0.65 + floatingOffset3)
                            .blur(radius: 3)
                        
                        // Soft circular glows
                        Circle()
                            .fill(Brand.sky.opacity(0.04))
                            .frame(width: 220, height: 220)
                            .offset(x: -60, y: geometry.size.height * 0.2)
                            .blur(radius: 45)
                        
                        Circle()
                            .fill(Brand.red.opacity(0.04))
                            .frame(width: 200, height: 200)
                            .offset(x: geometry.size.width - 80, y: geometry.size.height * 0.7)
                            .blur(radius: 45)
                        
                        // Animated particles
                        Circle()
                            .fill(Brand.red.opacity(0.15))
                            .frame(width: 8, height: 8)
                            .offset(x: geometry.size.width * 0.3, y: geometry.size.height * 0.4 + particleOffset1)
                            .blur(radius: 1)
                        
                        Circle()
                            .fill(Brand.sky.opacity(0.15))
                            .frame(width: 6, height: 6)
                            .offset(x: geometry.size.width * 0.7, y: geometry.size.height * 0.35 + particleOffset2)
                            .blur(radius: 1)
                    }
                }
            )
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.7), value: fadeOut)

            // MARK: - Main Content
            VStack(spacing: 36) {
                ZStack {
                    // ENERGY WAVE LAYERS - expanding rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Brand.red.opacity(0.4 - Double(i) * 0.1),
                                        Brand.sky.opacity(0.3 - Double(i) * 0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 240 + CGFloat(i) * 40, height: 240 + CGFloat(i) * 40)
                            .scaleEffect(energyWaveScale + CGFloat(i) * 0.1)
                            .opacity(energyWaveOpacity * (1.0 - Double(i) * 0.25))
                            .blur(radius: CGFloat(i) * 2)
                    }
                    
                    // Outer morphing ring with dual rotation
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Brand.red.opacity(0.3),
                                    Brand.sky.opacity(0.5),
                                    Brand.red.opacity(0.4),
                                    Brand.sky.opacity(0.3)
                                ]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 210, height: 210)
                        .rotationEffect(.degrees(ringRotation))
                        .scaleEffect(morphScale)
                    
                    // Animated progress ring with liquid gradient
                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Brand.red,
                                    Brand.sky,
                                    Brand.red.opacity(0.7),
                                    Brand.sky.opacity(0.8),
                                    Brand.red
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Brand.red.opacity(0.4), radius: 15, x: 0, y: 0)
                        .shadow(color: Brand.sky.opacity(0.4), radius: 15, x: 0, y: 0)

                    // Multi-layer pulsing glow - creates depth
                    ForEach(0..<2) { i in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Brand.sky.opacity(0.2 - Double(i) * 0.08),
                                        Brand.red.opacity(0.15 - Double(i) * 0.06),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: CGFloat(i) * 20,
                                    endRadius: 120 + CGFloat(i) * 20
                                )
                            )
                            .frame(width: 260, height: 260)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0.3 : 0.6)
                            .blur(radius: CGFloat(i + 1) * 3)
                            .animation(
                                .easeInOut(duration: 2.0 + Double(i) * 0.3)
                                .repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )
                    }
                    
                    // White background circle with shimmer effect
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 180, height: 180)
                            .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
                        
                        // Shimmer overlay
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.6),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 180, height: 180)
                            .offset(x: shimmerOffset)
                            .mask(
                                Circle()
                                    .frame(width: 180, height: 180)
                            )
                    }
                    
                    // Logo with magnetic entrance and breathing effect
                    Image("wecare_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 135, height: 135)
                        .scaleEffect(logoScale * morphScale)
                        .opacity(logoOpacity)
                        .offset(y: logoY)
                        .shadow(color: Brand.sky.opacity(glowIntensity * 0.5), radius: 20, x: 0, y: 0)
                        .shadow(color: Brand.red.opacity(glowIntensity * 0.3), radius: 25, x: 0, y: 0)
                    
                    // Orbiting care icons with independent scales
                    ForEach(0..<3) { i in
                        let angle = Double(i) * 120.0 + orbitRotation
                        let radius = 95.0
                        let x = radius * cos(angle * .pi / 180)
                        let y = radius * sin(angle * .pi / 180)
                        let iconName = i == 0 ? "heart.fill" : (i == 1 ? "hands.sparkles.fill" : "figure.2.arms.open")
                        let scale = i == 0 ? orbScale1 : (i == 1 ? orbScale2 : orbScale3)
                        
                        ZStack {
                            // Glow behind icon
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            (i == 0 ? Brand.red : Brand.sky).opacity(0.4),
                                            .clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 15
                                    )
                                )
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: iconName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Brand.red, Brand.sky],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .scaleEffect(scale)
                        .offset(x: x, y: y)
                        .opacity(logoOpacity)
                    }
                }

                VStack(spacing: 12) {
                    Text("Welcome to WeCare")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Brand.red, Brand.sky],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(textScale)
                        .opacity(textOpacity)

                    Text("Connecting families with safe and smart care.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.35, blue: 0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(textOpacity)
                    
                    // Decorative underline with shimmer
                    ZStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Brand.red.opacity(0.5), Brand.sky.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 70, height: 3)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.8), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 70, height: 3)
                            .offset(x: shimmerOffset * 0.3)
                    }
                    .padding(.top, 4)
                    .opacity(textOpacity)
                }

                // Liquid morphing progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Brand.red, Brand.sky],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 10, height: 10)
                            .scaleEffect(progressOpacity > Double(i) * 0.3 ? 1.3 : 0.7)
                            .opacity(progressOpacity > Double(i) * 0.3 ? 1.0 : 0.3)
                            .shadow(
                                color: (i % 2 == 0 ? Brand.red : Brand.sky).opacity(0.5),
                                radius: progressOpacity > Double(i) * 0.3 ? 8 : 2
                            )
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                                value: progressOpacity
                            )
                    }
                }
                .padding(.top, 8)
                .opacity(progressOpacity)
            }
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.6), value: fadeOut)
        }
        .onAppear {
            startAnimations()
            
            // Simulate loading then transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    fadeOut = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showMainView = false
                }
            }
        }
    }
    
    // MARK: - Animation Sequence
    private func startAnimations() {
        // Magnetic logo entrance from above with bounce
        withAnimation(.interpolatingSpring(stiffness: 80, damping: 8).delay(0.3)) {
            logoY = 0
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Energy waves expand
        withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
            energyWaveScale = 1.3
            energyWaveOpacity = 0.6
        }
        
        withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
            energyWaveScale = 1.6
            energyWaveOpacity = 0
        }
        
        // Logo breathing effect
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.8)) {
            morphScale = 1.03
        }
        
        // Glow intensity pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.0)) {
            glowIntensity = 1.0
        }
        
        // Shimmer sweep
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false).delay(1.2)) {
            shimmerOffset = 200
        }
        
        // Ring animations
        withAnimation(.easeOut(duration: 1.6).delay(0.5)) {
            ringTrim = 1.0
        }
        
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        // Orbit rotation
        withAnimation(.linear(duration: 18).repeatForever(autoreverses: false).delay(0.6)) {
            orbitRotation = 360
        }
        
        // Orbs pop in sequentially with bounce
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 6).delay(0.8)) {
            orbScale1 = 1.0
        }
        
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 6).delay(1.0)) {
            orbScale2 = 1.0
        }
        
        withAnimation(.interpolatingSpring(stiffness: 100, damping: 6).delay(1.2)) {
            orbScale3 = 1.0
        }
        
        // Orbs breathing independently
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(1.5)) {
            orbScale1 = 1.2
        }
        
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(1.6)) {
            orbScale2 = 1.15
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.7)) {
            orbScale3 = 1.18
        }
        
        // Text entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(1.2)) {
            textOpacity = 1.0
            textScale = 1.0
        }
        
        // Progress indicator
        withAnimation(.easeIn(duration: 0.6).delay(1.5)) {
            progressOpacity = 1.0
        }
        
        // Pulse effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pulseAnimation = true
        }
        
        // Background floating animations
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            floatingOffset1 = -25
        }
        
        withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true)) {
            floatingOffset2 = 20
        }
        
        withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
            floatingOffset3 = -18
        }
        
        // Particle animations
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            particleOffset1 = -30
        }
        
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            particleOffset2 = 35
        }
    }
}

#Preview {
    LoadingView(showMainView: .constant(true))
}
