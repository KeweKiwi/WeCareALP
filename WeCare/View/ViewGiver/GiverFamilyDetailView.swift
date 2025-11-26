import SwiftUI

struct GiverFamilyDetailView: View {
    let person: GiverPersonCardViewData
    
    @State private var isCodeHidden: Bool = true
    
    init(person: GiverPersonCardViewData) {
        self.person = person
    }
    
    private var displayFamilyCode: String {
        guard let code = person.familyCode, !code.isEmpty else {
            return "No family code"
        }
        if isCodeHidden {
            return String(repeating: "•", count: 6)
        }
        return code
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        GiverAvatarView(url: person.avatarURL, size: 60)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(person.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(person.role)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Family Code Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Family Code")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        HStack {
                            Text(displayFamilyCode)
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isCodeHidden.toggle()
                                }
                            } label: {
                                Image(systemName: isCodeHidden ? "eye.slash.fill" : "eye.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
                
                // Family Members Section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Family Members")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(person.familyMembers?.count ?? 0)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    
                    if let members = person.familyMembers, !members.isEmpty {
                        VStack(spacing: 10) {
                            ForEach(Array(members.enumerated()), id: \.offset) { index, member in
                                MemberRowView(
                                    name: member,
                                    isAdmin: index == 0 // Contoh: member pertama adalah admin
                                )
                            }
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Text("No family members yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Family Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Member Row View
struct MemberRowView: View {
    let name: String
    let isAdmin: Bool
    
    private var initial: String {
        name.first.map { String($0).uppercased() } ?? "?"
    }
    
    private var avatarColor: Color {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .red]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar dengan warna solid
            ZStack {
                Circle()
                    .fill(avatarColor.opacity(0.15))
                
                Text(initial)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(avatarColor)
            }
            .frame(width: 44, height: 44)
            
            // Name
            Text(name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Admin Badge
            if isAdmin {
                Text("Admin")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray4).opacity(0.5), lineWidth: 0.5)
        )
    }
}
