import SwiftUI

struct StartView: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var taglineOffset: CGFloat = 30
    @State private var taglineOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 40
    @State private var buttonsOpacity: Double = 0
    @State private var pulseAnimation = false
    @State private var floatingOffset1: CGFloat = 0
    @State private var floatingOffset2: CGFloat = 0
    @State private var floatingOffset3: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textScale: CGFloat = 0.5
    
    // MARK: - Helper Methods to reduce compiler complexity
    
    private func heartYOffset(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let baseY = geometry.size.height * 0.2
        let indexOffset = CGFloat(index * 100)
        let floatingOffset = (index % 2 == 0) ? floatingOffset1 : floatingOffset2
        return baseY + indexOffset + floatingOffset
    }
    
    private func logoIconPosition(for index: Int) -> CGPoint {
        let angle = Double(index) * 2.0 * .pi / 3.0 - .pi / 2.0
        let radius = 75.0
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle gradient background
                backgroundGradientView
                
                // Gentle floating circles in background
                GeometryReader { geometry in
                    backgroundFloatingElements(in: geometry)
                }
                
                VStack(spacing: 32) {
                    Spacer(minLength: 0)
                    
                    logoView
                    
                    taglineView
                    
                    buttonsView
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear(perform: startAnimations)
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradientView: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.97, blue: 0.99),
                Color(red: 0.95, green: 0.96, blue: 0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private func backgroundFloatingElements(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Animated floating hearts
            ForEach(0..<5) { i in
                Image(systemName: "heart.fill")
                    .font(.system(size: CGFloat(20 + i * 8)))
                    .foregroundStyle(heartGradient)
                    .offset(
                        x: CGFloat(30 + i * 80),
                        y: heartYOffset(for: i, in: geometry)
                    )
                    .blur(radius: 2)
                    .rotationEffect(.degrees(Double(i * 30)))
            }
            
            // Gentle care symbols
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 40))
                .foregroundStyle(Brand.sky.opacity(0.08))
                .offset(x: geometry.size.width - 80, y: geometry.size.height * 0.3 + floatingOffset3)
                .blur(radius: 3)
            
            Image(systemName: "figure.2.arms.open")
                .font(.system(size: 35))
                .foregroundStyle(Brand.red.opacity(0.08))
                .offset(x: 40, y: geometry.size.height * 0.6 + floatingOffset1)
                .blur(radius: 3)
            
            Circle()
                .fill(Brand.sky.opacity(0.05))
                .frame(width: 200, height: 200)
                .offset(x: -50, y: geometry.size.height * 0.15)
                .blur(radius: 40)
            
            Circle()
                .fill(Brand.red.opacity(0.05))
                .frame(width: 180, height: 180)
                .offset(x: geometry.size.width - 100, y: geometry.size.height * 0.7)
                .blur(radius: 40)
        }
    }
    
    private var heartGradient: LinearGradient {
        LinearGradient(
            colors: [Brand.red.opacity(0.12), Brand.sky.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var logoView: some View {
        ZStack {
            // Outer rotating gradient ring
            Circle()
                .stroke(logoRingGradient, lineWidth: 3)
                .frame(width: 190, height: 190)
                .rotationEffect(.degrees(rotationAngle))
            
            // Soft glow effect
            Circle()
                .fill(logoGlowGradient)
                .frame(width: 200, height: 200)
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                .opacity(pulseAnimation ? 0.5 : 0.8)
                .animation(
                    .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true),
                    value: pulseAnimation
                )
            
            // White circular background for logo
            Circle()
                .fill(.white)
                .frame(width: 175, height: 175)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            
            // Logo image
            Image("WeCareLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            // Decorative care icons around logo
            ForEach(0..<3) { i in
                let position = logoIconPosition(for: i)
                let iconName = i == 0 ? "heart.fill" : (i == 1 ? "hands.sparkles.fill" : "figure.2.arms.open")
                
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconGradient)
                    .offset(x: position.x, y: position.y)
                    .rotationEffect(.degrees(-rotationAngle * 0.5))
            }
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }
    
    private var logoRingGradient: LinearGradient {
        LinearGradient(
            colors: [Brand.red.opacity(0.3), Brand.sky.opacity(0.3), Brand.red.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var logoGlowGradient: RadialGradient {
        RadialGradient(
            colors: [Brand.sky.opacity(0.15), .clear],
            center: .center,
            startRadius: 0,
            endRadius: 100
        )
    }
    
    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [Brand.red, Brand.sky],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var taglineView: some View {
        VStack(spacing: 10) {
            Text("Care made simple")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(taglineGradient)
                .scaleEffect(textScale)
                .opacity(textOpacity)
            
            Text("for your loved ones")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.3, green: 0.35, blue: 0.45))
                .tracking(0.5)
            
            // Decorative underline
            RoundedRectangle(cornerRadius: 2)
                .fill(underlineGradient)
                .frame(width: 80, height: 3)
                .padding(.top, 4)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .offset(y: taglineOffset)
        .opacity(taglineOpacity)
    }
    
    private var taglineGradient: LinearGradient {
        LinearGradient(
            colors: [Brand.red, Brand.sky],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var underlineGradient: LinearGradient {
        LinearGradient(
            colors: [Brand.red.opacity(0.6), Brand.sky.opacity(0.6)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var buttonsView: some View {
        VStack(spacing: 16) {
            loginButton
            registerButton
            helperText
        }
        .padding(.horizontal, 48)
        .offset(y: buttonsOffset)
        .opacity(buttonsOpacity)
    }
    
    private var loginButton: some View {
        NavigationLink {
            LoginView()
        } label: {
            buttonLabel(icon: "person.fill", text: "Log In", color: Brand.red)
        }
        .buttonStyle(BounceButtonStyle())
    }
    
    private var registerButton: some View {
        NavigationLink {
            RegisterView()
        } label: {
            buttonLabel(icon: "person.badge.plus.fill", text: "Register", color: Brand.sky)
        }
        .buttonStyle(BounceButtonStyle())
    }
    
    private func buttonLabel(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
            Text(text)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color)
                
                // Shine effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(shineGradient)
            }
            .shadow(color: color.opacity(0.4), radius: 12, y: 6)
        )
        .foregroundColor(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        )
    }
    
    private var shineGradient: LinearGradient {
        LinearGradient(
            colors: [.white.opacity(0.3), .clear],
            startPoint: .topLeading,
            endPoint: .center
        )
    }
    
    private var helperText: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.system(size: 12))
            Text("Easy access, anytime")
                .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .foregroundStyle(helperTextGradient)
        .padding(.top, 8)
    }
    
    private var helperTextGradient: LinearGradient {
        LinearGradient(
            colors: [Brand.red.opacity(0.7), Brand.sky.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // Smooth, sequential animations
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            taglineOffset = 0
            taglineOpacity = 1.0
        }
        
        // Text appears together with bounce
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
            textOpacity = 1.0
            textScale = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            buttonsOffset = 0
            buttonsOpacity = 1.0
        }
        
        // Start pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pulseAnimation = true
        }
        
        // Gentle rotation animation
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Floating animations for background elements
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            floatingOffset1 = -20
        }
        
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            floatingOffset2 = 25
        }
        
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            floatingOffset3 = -15
        }
    }
}

// Gentle bounce effect for buttons
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    StartView()
        .environmentObject(AuthViewModel())
}
