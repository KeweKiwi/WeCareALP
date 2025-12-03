import SwiftUI


struct GiverFamilyDetailView: View {
    let person: GiverPersonCardViewData
    
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm: GiverFamilyViewModel
    
    @State private var isCodeHidden: Bool = true
    @State private var isEditing: Bool = false
    @State private var selectedMemberIds: Set<String> = []
    
    init(person: GiverPersonCardViewData) {
        self.person = person
        _vm = StateObject(wrappedValue: GiverFamilyViewModel(familyCode: person.familyCode))
    }
    
    // Hide or reveal family code
    private var displayFamilyCode: String {
        guard let code = person.familyCode, !code.isEmpty else { return "No family code" }
        return isCodeHidden ? String(repeating: "•", count: code.count) : code
    }
    
    // Check if current user is FIRST member (admin)
    private var isCurrentUserAdmin: Bool {
        guard let userId = authVM.currentUser?.userId else { return false }
        return vm.members.first?.userId == userId
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Header Card
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
                    
                    // MARK: Family Code
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
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isCodeHidden.toggle()
                                }
                            } label: {
                                Image(systemName: isCodeHidden ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.blue)
                                    .padding(8)
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
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                
                // MARK: Family Members Section
                VStack(alignment: .leading, spacing: 14) {
                    
                    // Header row
                    HStack {
                        Text("Family Members")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(vm.members.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    
                    // Loading
                    if vm.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading members…")
                                .padding(.vertical, 24)
                            Spacer()
                        }
                    }
                    
                    // Error
                    else if let err = vm.errorMessage {
                        VStack(spacing: 6) {
                            Text("Failed to load family members")
                                .font(.body).bold()
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 30)
                    }
                    
                    // Empty
                    else if vm.members.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Text("No family members yet")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                    
                    // Members List
                    else {
                        VStack(spacing: 10) {
                            ForEach(vm.members) { member in
                                MemberRowView(
                                    name: member.name,
                                    isAdmin: member.isAdmin,
                                    isSelectable: isEditing && !member.isAdmin,
                                    isSelected: selectedMemberIds.contains(member.id),
                                    onTap: {
                                        guard isEditing, !member.isAdmin else { return }
                                        if selectedMemberIds.contains(member.id) {
                                            selectedMemberIds.remove(member.id)
                                        } else {
                                            selectedMemberIds.insert(member.id)
                                        }
                                    }
                                )
                            }
                        }
                        
                        // Delete button (only when editing & items selected)
                        if isEditing && !selectedMemberIds.isEmpty {
                            Button(role: .destructive) {
                                let idsToDelete = vm.members
                                    .filter { selectedMemberIds.contains($0.id) && !$0.isAdmin }
                                    .map { $0.id }
                                
                                vm.deleteMembers(withIds: idsToDelete)
                                selectedMemberIds.removeAll()
                                isEditing = false
                            } label: {
                                Label("Remove Selected Members", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .padding(.top, 8)
                        }
                    }
                    
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Family Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Only admin can edit
            if isCurrentUserAdmin && !vm.isLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            if isEditing { selectedMemberIds.removeAll() }
                            isEditing.toggle()
                        }
                    } label: {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
            }
        }
        .onAppear { vm.load() }
    }
}




// MARK: - Member Row View


struct MemberRowView: View {
    let name: String
    let isAdmin: Bool
    let isSelectable: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    private var initial: String { String(name.first ?? "?").uppercased() }
    
    private var avatarColor: Color {
        let base: [Color] = [.blue, .purple, .pink, .orange, .green, .red]
        return base[abs(name.hashValue) % base.count]
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                
                // Avatar
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
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection mode
                if isSelectable {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .secondary)
                }
                // Admin badge
                else if isAdmin {
                    Text("Admin")
                        .font(.caption).bold()
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .foregroundColor(.white)
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
        .buttonStyle(.plain)
    }
}





