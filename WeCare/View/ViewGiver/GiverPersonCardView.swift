import SwiftUI

struct GiverPersonCardViewData: Identifiable, Hashable {
    enum Status: Hashable {
        case healthy
        case warning
        case critical
    }
    
    let id = UUID()
    let name: String
    let role: String
    let avatarURL: String?
    let status: Status
    let heartRate: Int?
    let steps: Int?
    
    let familyCode: String?
    let familyMembers: [String]?
    
    var heartRateText: String {
        if let heartRate {
            return "\(heartRate) bpm"
        }
        return "- bpm"
    }
}

struct GiverAvatarView: View {
    let url: String?
    let size: CGFloat
    @State private var isAnimating = false
    
    init(url: String?, size: CGFloat = 54) {
        self.url = url
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(Brand.sky.opacity(0.2))
                .frame(width: size + 8, height: size + 8)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .opacity(isAnimating ? 0 : 1)
            
            // Main avatar circle
            Circle()
                .fill(Brand.sky)
            
            Image(systemName: "person.fill")
                .foregroundColor(.white)
                .font(.system(size: size * 0.45, weight: .semibold))
        }
        .frame(width: size, height: size)
        .shadow(color: Brand.sky.opacity(0.3), radius: 10, y: 5)
        .onAppear {
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

struct GiverStatusDot: View {
    let status: GiverPersonCardViewData.Status
    @State private var isPulsing = false
    
    private var color: Color {
        switch status {
        case .healthy:  return Color(hex: "#10b981")
        case .warning:  return Color(hex: "#f59e0b")
        case .critical: return Brand.red
        }
    }
    
    var body: some View {
        ZStack {
            // Pulsing outer ring for critical status
            if status == .critical {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0 : 1)
            }
            
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .shadow(color: color.opacity(0.5), radius: 4, y: 2)
        }
        .onAppear {
            if status == .critical {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    isPulsing = true
                }
            }
        }
    }
}

struct GiverIconButtonCircleView: View {
    let systemName: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Image(systemName: systemName)
                .foregroundColor(Brand.sky)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Brand.sky.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(Brand.sky.opacity(isHovered ? 0.3 : 0), lineWidth: 2)
                                .scaleEffect(isHovered ? 1.2 : 1.0)
                        )
                )
                .shadow(color: Brand.sky.opacity(isPressed ? 0.4 : 0.2), radius: isPressed ? 8 : 4, y: isPressed ? 4 : 2)
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .rotationEffect(.degrees(isPressed ? 5 : 0))
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHovered {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isHovered = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isHovered = false
                    }
                }
        )
    }
}

struct GiverPersonCardView: View {
    let data: GiverPersonCardViewData
    let onInfo: () -> Void
    let onLocation: () -> Void
    let onVolunteer: () -> Void
    let onCardTap: () -> Void
    
    @State private var isPressed = false
    @State private var buttonPressed = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header section with avatar and status
            HStack(spacing: 14) {
                GiverAvatarView(url: data.avatarURL)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(data.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(data.role.roleDisplayName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Brand.sky)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Brand.sky.opacity(0.12))
                        )
                }
                
                Spacer()
                GiverStatusDot(status: data.status)
            }
            
            // Health metrics section with modern card style
            HStack(spacing: 16) {
                // Heart rate card
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Brand.red.opacity(0.12))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "heart.fill")
                            .foregroundColor(Brand.red)
                            .font(.system(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Heart Rate")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Text(data.heartRateText)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Brand.red.opacity(0.15), lineWidth: 1.5)
                )
                
                // Steps card
                if let steps = data.steps {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Brand.sky.opacity(0.12))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "figure.walk")
                                .foregroundColor(Brand.sky)
                                .font(.system(size: 14))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Steps")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            Text("\(steps)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Brand.sky.opacity(0.15), lineWidth: 1.5)
                    )
                }
                
                Spacer()
            }
            
            // Divider with subtle color
            Rectangle()
                .fill(Color(red: 0.3, green: 0.35, blue: 0.45).opacity(0.1))
                .frame(height: 1)
                .padding(.vertical, 4)
            
            // Action buttons section
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        buttonPressed = true
                    }
                    
                    // Trigger shimmer
                    withAnimation(.linear(duration: 0.6)) {
                        shimmerOffset = 200
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                            buttonPressed = false
                        }
                        onVolunteer()
                        
                        // Reset shimmer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            shimmerOffset = -200
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 14))
                        Text("Find Volunteer")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Brand.sky)
                            
                            // Shimmer effect
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .white.opacity(0.3), .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .offset(x: shimmerOffset)
                                .mask(RoundedRectangle(cornerRadius: 12))
                        }
                    )
                    .shadow(color: Brand.sky.opacity(buttonPressed ? 0.5 : 0.3), radius: buttonPressed ? 12 : 8, y: buttonPressed ? 6 : 4)
                    .scaleEffect(buttonPressed ? 0.96 : 1.0)
                    .rotationEffect(.degrees(buttonPressed ? -1 : 0))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                GiverIconButtonCircleView(systemName: "location.fill", action: onLocation)
                GiverIconButtonCircleView(systemName: "info.circle.fill", action: onInfo)
            }
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: Color.black.opacity(isPressed ? 0.12 : 0.06), radius: isPressed ? 8 : 15, y: isPressed ? 4 : 8)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Brand.sky.opacity(0.15), lineWidth: 1.5)
            }
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .rotation3DEffect(
            .degrees(isPressed ? 2 : 0),
            axis: (x: 0.1, y: 0.1, z: 0)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                    isPressed = false
                }
                onCardTap()
            }
        }
    }
}



#Preview {
    VStack(spacing: 20) {
        GiverPersonCardView(
            data: GiverPersonCardViewData(
                name: "John Doe",
                role: "Family Member",
                avatarURL: nil,
                status: .healthy,
                heartRate: 72,
                steps: 8430,
                familyCode: nil,
                familyMembers: nil
            ),
            onInfo: { print("Info tapped") },
            onLocation: { print("Location tapped") },
            onVolunteer: { print("Volunteer tapped") },
            onCardTap: { print("Card tapped") }
        )
        
        GiverPersonCardView(
            data: GiverPersonCardViewData(
                name: "Jane Smith",
                role: "Elder",
                avatarURL: nil,
                status: .critical,
                heartRate: 105,
                steps: 1200,
                familyCode: nil,
                familyMembers: nil
            ),
            onInfo: { print("Info tapped") },
            onLocation: { print("Location tapped") },
            onVolunteer: { print("Volunteer tapped") },
            onCardTap: { print("Card tapped") }
        )
    }
    .padding()
    .background(Color(hex: "#f5f5f5"))
}

extension String {
    var roleDisplayName: String {
        switch self {
        case "careReceiver":
            return "Care Receiver"
        case "careGiver":
            return "Care Giver"
        default:
            return self
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
        }
    }
}
