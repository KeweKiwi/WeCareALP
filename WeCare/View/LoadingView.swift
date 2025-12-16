import SwiftUI

struct LoadingView: View {
    @Binding var showMainView: Bool

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var logoY: CGFloat = -60
    @State private var ringTrim: CGFloat = 0.0
    @State private var ringRotation: Double = 0
    @State private var outerRingRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var textOpacity: Double = 0
    @State private var textY: CGFloat = 20
    @State private var progressOpacity: Double = 0
    @State private var fadeOut: Bool = false
    @State private var glowIntensity: Double = 0
    @State private var particleOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -300
    @State private var energyBurst: Bool = false
    @State private var orbScale1: CGFloat = 0
    @State private var orbScale2: CGFloat = 0
    @State private var orbScale3: CGFloat = 0
    @State private var particleAnimation: [Bool] = Array(repeating: false, count: 20)
    @State private var spiralRotation: Double = 0
    @State private var wavePhase: CGFloat = 0
    @State private var breathScale: CGFloat = 1.0
    @State private var liquidMorphing: CGFloat = 0

    var body: some View {
        ZStack {
            // MARK: - LUXURIOUS GRADIENT BACKGROUND
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.97, blue: 0.99),
                        Color(red: 0.96, green: 0.97, blue: 0.99),
                        Color(red: 0.98, green: 0.96, blue: 0.97),
                        Color(red: 0.95, green: 0.96, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Animated mesh gradient effect
                ZStack {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (i % 3 == 0 ? Brand.red : (i % 3 == 1 ? Brand.sky : Color.purple)).opacity(0.12),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 300, height: 300)
                            .blur(radius: 50)
                            .offset(
                                x: sin(spiralRotation * .pi / 180 + Double(i) * 1.2) * 100,
                                y: cos(spiralRotation * .pi / 180 + Double(i) * 1.2) * 100
                            )
                            .scaleEffect(breathScale)
                    }
                }
            }
            .ignoresSafeArea()
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.8), value: fadeOut)
            
            // MARK: - EXTRAORDINARY FLOATING PARTICLES
            GeometryReader { geometry in
                ZStack {
                    // Large glowing orbs
                    ForEach(0..<8) { i in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (i % 2 == 0 ? Brand.red : Brand.sky).opacity(0.6),
                                        (i % 2 == 0 ? Brand.sky : Color.purple).opacity(0.4),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 15
                                )
                            )
                            .frame(width: CGFloat.random(in: 12...20), height: CGFloat.random(in: 12...20))
                            .blur(radius: 3)
                            .offset(
                                x: sin(wavePhase + Double(i) * 0.8) * geometry.size.width * 0.4 + geometry.size.width * 0.5,
                                y: CGFloat(i) * (geometry.size.height / 8) + cos(wavePhase * 1.5 + Double(i)) * 40
                            )
                            .opacity(particleAnimation[i] ? particleOpacity : particleOpacity * 0.3)
                            .scaleEffect(particleAnimation[i] ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: Double.random(in: 1.5...2.5))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                                value: particleAnimation[i]
                            )
                    }
                    
                    // Diamond sparkles
                    ForEach(8..<15) { i in
                        DiamondSparkle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white,
                                        (i % 2 == 0 ? Brand.red : Brand.sky).opacity(0.8),
                                        .white.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: CGFloat.random(in: 8...14), height: CGFloat.random(in: 8...14))
                            .blur(radius: 0.5)
                            .rotationEffect(.degrees(particleAnimation[i] ? 360 : 0))
                            .offset(
                                x: CGFloat.random(in: 40...geometry.size.width - 40),
                                y: CGFloat(i - 8) * (geometry.size.height / 7) + sin(wavePhase + Double(i)) * 30
                            )
                            .opacity(particleAnimation[i] ? particleOpacity * 0.9 : particleOpacity * 0.4)
                            .scaleEffect(particleAnimation[i] ? 1.3 : 0.7)
                            .shadow(color: (i % 2 == 0 ? Brand.red : Brand.sky).opacity(0.6), radius: 8)
                            .animation(
                                .easeInOut(duration: Double.random(in: 2...3))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.15),
                                value: particleAnimation[i]
                            )
                    }
                    
                    // Trailing light streaks
                    ForEach(15..<20) { i in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        (i % 2 == 0 ? Brand.red : Brand.sky).opacity(0.7),
                                        .white.opacity(0.5),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: CGFloat.random(in: 20...40), height: 3)
                            .blur(radius: 1.5)
                            .rotationEffect(.degrees(Double.random(in: -30...30)))
                            .offset(
                                x: cos(wavePhase * 0.8 + Double(i)) * geometry.size.width * 0.35 + geometry.size.width * 0.5,
                                y: CGFloat(i - 15) * (geometry.size.height / 5) + sin(wavePhase + Double(i)) * 50
                            )
                            .opacity(particleAnimation[i] ? particleOpacity * 0.8 : particleOpacity * 0.3)
                            .scaleEffect(x: particleAnimation[i] ? 1.2 : 0.6, y: 1.0)
                            .animation(
                                .easeInOut(duration: Double.random(in: 1.8...2.8))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.18),
                                value: particleAnimation[i]
                            )
                    }
                }
            }

            // MARK: - MAIN CONTENT WITH LIQUID MORPHING
            VStack(spacing: 38) {
                ZStack {
                    // PRISMATIC ENERGY BURST
                    ForEach(0..<6) { i in
                        Circle()
                            .stroke(
                                AngularGradient(
                                    colors: [
                                        Brand.red.opacity(0.3 - Double(i) * 0.04),
                                        Color.purple.opacity(0.25 - Double(i) * 0.035),
                                        Brand.sky.opacity(0.28 - Double(i) * 0.04),
                                        Color(red: 1.0, green: 0.8, blue: 0.9).opacity(0.25 - Double(i) * 0.035)
                                    ],
                                    center: .center
                                ),
                                lineWidth: 2.5
                            )
                            .frame(width: 250 + CGFloat(i) * 40, height: 250 + CGFloat(i) * 40)
                            .scaleEffect(energyBurst ? 1.5 + CGFloat(i) * 0.15 : 0.8)
                            .opacity(energyBurst ? 0 : 0.6)
                            .blur(radius: CGFloat(i + 1) * 1.5)
                            .rotationEffect(.degrees(Double(i) * 15 + spiralRotation * 0.5))
                    }
                    
                    // MORPHING LIQUID RINGS
                    ForEach(0..<3) { layer in
                        LiquidRing(morphAmount: liquidMorphing, offset: Double(layer) * 0.3)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Brand.red.opacity(0.35 - Double(layer) * 0.1),
                                        Brand.sky.opacity(0.4 - Double(layer) * 0.1),
                                        Color.purple.opacity(0.35 - Double(layer) * 0.1),
                                        Brand.sky.opacity(0.4 - Double(layer) * 0.1),
                                        Brand.red.opacity(0.35 - Double(layer) * 0.1)
                                    ]),
                                    center: .center
                                ),
                                lineWidth: 4 - CGFloat(layer)
                            )
                            .frame(width: 245 - CGFloat(layer) * 15, height: 245 - CGFloat(layer) * 15)
                            .rotationEffect(.degrees(-outerRingRotation + Double(layer) * 45))
                            .shadow(color: Brand.sky.opacity(0.3), radius: 20, x: 0, y: 0)
                    }

                    // MAIN PROGRESS RING - Crystalline Effect
                    ZStack {
                        // Inner glow
                        Circle()
                            .trim(from: 0, to: ringTrim)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Brand.red.opacity(0.5),
                                        Color.white.opacity(0.6),
                                        Brand.sky.opacity(0.5),
                                        Color.purple.opacity(0.4),
                                        Brand.red.opacity(0.5)
                                    ]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: 230, height: 230)
                            .rotationEffect(.degrees(ringRotation))
                            .blur(radius: 8)
                        
                        // Sharp outer ring
                        Circle()
                            .trim(from: 0, to: ringTrim)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Brand.red,
                                        Color(red: 1.0, green: 0.9, blue: 0.95),
                                        Brand.sky,
                                        Color(red: 0.85, green: 0.85, blue: 1.0),
                                        Brand.red
                                    ]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 230, height: 230)
                            .rotationEffect(.degrees(ringRotation))
                            .shadow(color: Brand.red.opacity(0.5), radius: 15, x: 0, y: 0)
                            .shadow(color: Brand.sky.opacity(0.4), radius: 18, x: 0, y: 0)
                    }

                    // VOLUMETRIC GLOW LAYERS
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (i % 2 == 0 ? Brand.sky : Brand.red).opacity(0.12 - Double(i) * 0.02),
                                        (i % 2 == 0 ? Brand.red : Color.purple).opacity(0.08 - Double(i) * 0.015),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: CGFloat(i) * 20,
                                    endRadius: 140 + CGFloat(i) * 20
                                )
                            )
                            .frame(width: 290, height: 290)
                            .scaleEffect(pulseScale + CGFloat(i) * 0.03)
                            .blur(radius: CGFloat(i + 3) * 2.5)
                            .rotationEffect(.degrees(spiralRotation * 0.3 + Double(i) * 20))
                    }
                    
                    // PREMIUM GLASS CIRCLE
                    ZStack {
                        // Frosted glass effect
                        Circle()
                            .fill(.white.opacity(0.5))
                            .frame(width: 198, height: 198)
                            .blur(radius: 2)
                        
                        // Main glass surface
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white,
                                        Color(red: 0.98, green: 0.98, blue: 0.99),
                                        Color(red: 0.96, green: 0.97, blue: 0.98)
                                    ],
                                    center: UnitPoint(x: 0.4, y: 0.4),
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 190, height: 190)
                            .shadow(color: .black.opacity(0.1), radius: 30, y: 12)
                            .shadow(color: Brand.sky.opacity(0.2), radius: 20, x: -5, y: -5)
                        
                        // Rainbow shimmer
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [
                                        .clear,
                                        Brand.red.opacity(0.4),
                                        Color.purple.opacity(0.3),
                                        Brand.sky.opacity(0.4),
                                        .clear
                                    ],
                                    center: .center
                                )
                            )
                            .frame(width: 190, height: 190)
                            .rotationEffect(.degrees(shimmerOffset))
                            .blur(radius: 15)
                            .opacity(0.6)
                    }
                    
                    // LOGO with holographic effect
                    ZStack {
                        // Holographic layers
                        ForEach(0..<3) { i in
                            Image("wecare_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 145, height: 145)
                                .opacity(0.15)
                                .blur(radius: CGFloat(i + 1) * 2)
                                .offset(
                                    x: sin(spiralRotation * .pi / 180 + Double(i)) * 3,
                                    y: cos(spiralRotation * .pi / 180 + Double(i)) * 3
                                )
                        }
                        
                        Image("wecare_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 145, height: 145)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .offset(y: logoY)
                    .shadow(color: Brand.sky.opacity(glowIntensity * 0.4), radius: 25, x: 0, y: 0)
                    .shadow(color: Brand.red.opacity(glowIntensity * 0.3), radius: 30, x: 0, y: 0)
                    .shadow(color: Color.purple.opacity(glowIntensity * 0.2), radius: 35, x: 0, y: 0)
                    
                    // ORBITING CARE ICONS - Enhanced
                    ForEach(0..<3) { i in
                        let angle = Double(i) * 120.0 + spiralRotation * 0.5
                        let radius = 110.0 + sin(wavePhase + Double(i)) * 5
                        let x = radius * cos(angle * .pi / 180 - .pi / 2)
                        let y = radius * sin(angle * .pi / 180 - .pi / 2)
                        let iconName = i == 0 ? "heart.fill" : (i == 1 ? "hands.sparkles.fill" : "figure.2.arms.open")
                        let scale = i == 0 ? orbScale1 : (i == 1 ? orbScale2 : orbScale3)
                        
                        ZStack {
                            // Prismatic glow
                            ForEach(0..<3) { layer in
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                (i == 0 ? Brand.red : Brand.sky).opacity(0.4 - Double(layer) * 0.1),
                                                .clear
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 22 + CGFloat(layer) * 4
                                        )
                                    )
                                    .frame(width: 40 + CGFloat(layer) * 8, height: 40 + CGFloat(layer) * 8)
                                    .blur(radius: CGFloat(layer + 2) * 2)
                            }
                            
                            // Glass orb
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            .white.opacity(0.95),
                                            .white.opacity(0.85)
                                        ],
                                        center: UnitPoint(x: 0.3, y: 0.3),
                                        startRadius: 0,
                                        endRadius: 20
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .shadow(color: .black.opacity(0.15), radius: 10, y: 3)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.5), lineWidth: 1)
                                )
                            
                            Image(systemName: iconName)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            i == 0 ? Brand.red : Brand.sky,
                                            (i == 0 ? Brand.red : Brand.sky).opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .white.opacity(0.8), radius: 2)
                        }
                        .scaleEffect(scale * breathScale)
                        .offset(x: x, y: y)
                        .rotationEffect(.degrees(-ringRotation))
                        .opacity(logoOpacity)
                    }
                }

                // TEXT SECTION - Premium Typography
                VStack(spacing: 12) {
                    ZStack {
                        // Text glow
                        Text("Welcome to WeCare")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Brand.red.opacity(0.5), Brand.sky.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .blur(radius: 8)
                        
                        Text("Welcome to WeCare")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Brand.red, Color.purple, Brand.sky],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .white.opacity(0.8), radius: 1)
                    }

                    Text("Connecting families with safe and smart care.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.35, blue: 0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Animated crystalline underline
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                AngularGradient(
                                    colors: [
                                        Brand.red.opacity(0.7),
                                        Color.purple.opacity(0.6),
                                        Brand.sky.opacity(0.7),
                                        Brand.red.opacity(0.7)
                                    ],
                                    center: .center
                                )
                            )
                            .frame(width: 90, height: 4)
                            .shadow(color: Brand.sky.opacity(0.5), radius: 8, x: 0, y: 0)
                            .blur(radius: 1)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white, .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 90, height: 4)
                            .offset(x: shimmerOffset * 0.3)
                    }
                    .rotationEffect(.degrees(spiralRotation * 0.1))
                    .padding(.top, 8)
                }
                .offset(y: textY)
                .opacity(textOpacity)

                // LUXURY PROGRESS INDICATORS
                HStack(spacing: 14) {
                    ForEach(0..<3) { i in
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Brand.red.opacity(0.6),
                                            Brand.sky.opacity(0.6)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 20, height: 20)
                                .opacity(progressOpacity > Double(i) * 0.33 ? 1.0 : 0.3)
                            
                            // Main crystal dot
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            .white,
                                            (i % 2 == 0 ? Brand.red : Brand.sky),
                                            (i % 2 == 0 ? Brand.red : Brand.sky).opacity(0.7)
                                        ],
                                        center: UnitPoint(x: 0.3, y: 0.3),
                                        startRadius: 0,
                                        endRadius: 8
                                    )
                                )
                                .frame(width: 13, height: 13)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.6), lineWidth: 1)
                                )
                                .scaleEffect(progressOpacity > Double(i) * 0.33 ? 1.4 : 0.6)
                                .opacity(progressOpacity > Double(i) * 0.33 ? 1.0 : 0.3)
                                .shadow(
                                    color: (i % 2 == 0 ? Brand.red : Brand.sky).opacity(0.8),
                                    radius: progressOpacity > Double(i) * 0.33 ? 12 : 4
                                )
                        }
                        .animation(
                            .easeInOut(duration: 0.7)
                            .repeatForever()
                            .delay(Double(i) * 0.22),
                            value: progressOpacity
                        )
                    }
                }
                .padding(.top, 10)
                .opacity(progressOpacity)
            }
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.7), value: fadeOut)
        }
        .onAppear {
            startAnimations()
            
            // Transition after loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    fadeOut = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showMainView = false
                }
            }
        }
    }
    
    // MARK: - EXTRAORDINARY ANIMATION CHOREOGRAPHY
    private func startAnimations() {
        // Activate all particles
        for i in 0..<20 {
            particleAnimation[i] = true
        }
        
        // Spiral mesh animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            spiralRotation = 360
        }
        
        // Wave motion
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            wavePhase = .pi * 4
        }
        
        // Breathing scale
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            breathScale = 1.08
        }
        
        // Liquid morphing
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            liquidMorphing = 1.0
        }
        
        // Energy burst
        withAnimation(.easeOut(duration: 1.8).delay(0.1)) {
            energyBurst = true
        }
        
        // Particles fade in dramatically
        withAnimation(.easeIn(duration: 1.2).delay(0.2)) {
            particleOpacity = 1.0
        }
        
        // Logo magnetic entrance
        withAnimation(.interpolatingSpring(stiffness: 60, damping: 7).delay(0.5)) {
            logoY = 0
            logoScale = 1.08
            logoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.7).delay(1.3)) {
            logoScale = 1.0
        }
        
        // Ring progress
        withAnimation(.easeOut(duration: 2.0).delay(0.7)) {
            ringTrim = 1.0
        }
        
        // Ring rotations
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false).delay(0.9)) {
            ringRotation = 360
        }
        
        withAnimation(.linear(duration: 35).repeatForever(autoreverses: false).delay(0.9)) {
            outerRingRotation = 360
        }
        
        // Pulsing glow
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true).delay(1.0)) {
            pulseScale = 1.18
        }
        
        // Logo glow
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1.2)) {
            glowIntensity = 1.0
        }
        
        // Rainbow shimmer
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false).delay(1.4)) {
            shimmerOffset = 360
        }
        
        // Orbs cascade
        withAnimation(.interpolatingSpring(stiffness: 80, damping: 6).delay(1.1)) {
            orbScale1 = 1.0
        }
        
        withAnimation(.interpolatingSpring(stiffness: 80, damping: 6).delay(1.3)) {
            orbScale2 = 1.0
        }
        
        withAnimation(.interpolatingSpring(stiffness: 80, damping: 6).delay(1.5)) {
            orbScale3 = 1.0
        }
        
        // Text reveal
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(1.6)) {
            textY = 0
            textOpacity = 1.0
        }
        
        // Progress indicators
        withAnimation(.easeIn(duration: 0.8).delay(1.9)) {
            progressOpacity = 1.0
        }
    }
}

// MARK: - Custom Shapes

struct DiamondSparkle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: center.x, y: center.y - height/2))
        path.addLine(to: CGPoint(x: center.x + width/2, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + height/2))
        path.addLine(to: CGPoint(x: center.x - width/2, y: center.y))
        path.closeSubpath()
        
        return path
    }
}

struct LiquidRing: Shape {
    var morphAmount: CGFloat
    var offset: Double
    
    var animatableData: CGFloat {
        get { morphAmount }
        set { morphAmount = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let points = 60
        
        path.move(to: CGPoint(
            x: center.x + radius,
            y: center.y
        ))
        
        for i in 0..<points {
            let angle = (Double(i) / Double(points)) * 2 * .pi
            let wave = sin(angle * 4 + morphAmount * .pi * 2 + offset) * 3
            let r = radius + CGFloat(wave)
            let x = center.x + r * cos(angle)
            let y = center.y + r * sin(angle)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    LoadingView(showMainView: .constant(true))
}
