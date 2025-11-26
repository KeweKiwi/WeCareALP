import SwiftUI

// MARK: - Model
struct VitalSign {
    let vitalId: Int64
    let userId: Int
    let timestamp: Date
    let heartRate: Int?
    let oxygenSaturation: Double?
    let steps: Int?
    let sleepDurationHours: Double?
    let temperature: Double?
}

struct GiverPersonInfoView: View {
    let person: GiverPersonCardViewData
    let vitalSign: VitalSign
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Header dengan info person
                PersonHeaderCard(person: person, timestamp: vitalSign.timestamp)
                
                // Vital Signs Grid
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        VitalCard(
                            icon: "heart.fill",
                            iconColor: .red,
                            title: "Heart Rate",
                            value: vitalSign.heartRate.map { "\($0)" } ?? "--",
                            unit: "BPM",
                            status: getHeartRateStatus(vitalSign.heartRate)
                        )
                        
                        VitalCard(
                            icon: "drop.fill",
                            iconColor: .blue,
                            title: "Oxygen",
                            value: vitalSign.oxygenSaturation.map { String(format: "%.1f", $0) } ?? "--",
                            unit: "%",
                            status: getOxygenStatus(vitalSign.oxygenSaturation)
                        )
                    }
                    
                    HStack(spacing: 12) {
                        VitalCard(
                            icon: "figure.walk",
                            iconColor: .green,
                            title: "Steps",
                            value: vitalSign.steps.map { formatNumber($0) } ?? "--",
                            unit: "steps",
                            status: getStepsStatus(vitalSign.steps)
                        )
                        
                        VitalCard(
                            icon: "bed.double.fill",
                            iconColor: .purple,
                            title: "Sleep",
                            value: vitalSign.sleepDurationHours.map { String(format: "%.1f", $0) } ?? "--",
                            unit: "hours",
                            status: getSleepStatus(vitalSign.sleepDurationHours)
                        )
                    }
                    
                    // Temperature - Full Width
                    VitalCard(
                        icon: "thermometer.medium",
                        iconColor: .orange,
                        title: "Temperature",
                        value: vitalSign.temperature.map { String(format: "%.1f", $0) } ?? "--",
                        unit: "°C",
                        status: getTemperatureStatus(vitalSign.temperature),
                        isFullWidth: true
                    )
                }
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Health Info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Functions
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func getHeartRateStatus(_ rate: Int?) -> VitalStatus {
        guard let rate = rate else { return .normal }
        if rate < 60 { return .low }
        if rate > 100 { return .high }
        return .normal
    }
    
    private func getOxygenStatus(_ oxygen: Double?) -> VitalStatus {
        guard let oxygen = oxygen else { return .normal }
        if oxygen < 95 { return .low }
        return .normal
    }
    
    private func getStepsStatus(_ steps: Int?) -> VitalStatus {
        guard let steps = steps else { return .normal }
        if steps < 5000 { return .low }
        if steps >= 10000 { return .high }
        return .normal
    }
    
    private func getSleepStatus(_ sleep: Double?) -> VitalStatus {
        guard let sleep = sleep else { return .normal }
        if sleep < 6 { return .low }
        if sleep >= 8 { return .high }
        return .normal
    }
    
    private func getTemperatureStatus(_ temp: Double?) -> VitalStatus {
        guard let temp = temp else { return .normal }
        if temp < 36.1 { return .low }
        if temp > 37.2 { return .high }
        return .normal
    }
}

// MARK: - Person Header Card
struct PersonHeaderCard: View {
    let person: GiverPersonCardViewData
    let timestamp: Date
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 14) {
            GiverAvatarView(url: person.avatarURL, size: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(person.role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("Updated \(timeAgo)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Vital Card
enum VitalStatus {
    case low, normal, high
    
    var color: Color {
        switch self {
        case .low: return .orange
        case .normal: return .green
        case .high: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .normal: return "checkmark.circle.fill"
        case .high: return "arrow.up.circle.fill"
        }
    }
}

struct VitalCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    let status: VitalStatus
    var isFullWidth: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                Spacer()
                
                Image(systemName: status.icon)
                    .font(.system(size: 16))
                    .foregroundColor(status.color)
            }
            
            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Value
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}
