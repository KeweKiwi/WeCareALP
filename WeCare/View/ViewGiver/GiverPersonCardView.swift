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
    
    init(url: String?, size: CGFloat = 54) {
        self.url = url
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray5))
            Image(systemName: "person.fill")
                .foregroundColor(.white)
                .font(.system(size: size * 0.45))
        }
        .frame(width: size, height: size)
    }
}
struct GiverStatusDot: View {
    let status: GiverPersonCardViewData.Status
    
    private var color: Color {
        switch status {
        case .healthy:  return .green
        case .warning:  return .yellow
        case .critical: return .red
        }
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
    }
}
struct GiverIconButtonCircleView: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(.blue)
                .padding(8)
                .background(
                    Circle().fill(Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
    }
}
struct GiverPersonCardView: View {
    let data: GiverPersonCardViewData
    let onInfo: () -> Void
    let onLocation: () -> Void
    let onCardTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(spacing: 12) {
                GiverAvatarView(url: data.avatarURL)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(data.role)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                GiverStatusDot(status: data.status)
            }
            
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text(data.heartRateText)
                }
                .font(.subheadline)
                
                if let steps = data.steps {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.green)
                        Text("\(steps) steps")
                    }
                    .font(.subheadline)
                }
            }
            
            HStack {
                Button(action: onInfo) {
                    Text("Info")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                GiverIconButtonCircleView(systemName: "location.fill", action: onLocation)
                GiverIconButtonCircleView(systemName: "info.circle", action: onInfo)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .onTapGesture {
            onCardTap()
        }
    }
}


