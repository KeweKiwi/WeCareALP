import SwiftUI
struct GiverFamilyDetailView: View {
    let person: GiverPersonCardViewData
    
    @State private var isCodeHidden: Bool = true
    @State private var isEditing: Bool = false
    @State private var members: [String]
    
    init(person: GiverPersonCardViewData) {
        self.person = person
        _members = State(initialValue: person.familyMembers ?? [])
    }
    
    private var displayFamilyCode: String {
        // pastikan di data: familyCode = "123456" (6 digit angka, tanpa FAM-)
        guard let code = person.familyCode, !code.isEmpty else {
            return "No family code"
        }
        if isCodeHidden {
            // selalu 6 bullet, biar kaya saldo
            return String(repeating: "•", count: 6)
        }
        return code
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Header
                HStack(spacing: 12) {
                    GiverAvatarView(url: person.avatarURL, size: 50)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.name)
                            .font(.title3)
                            .bold()
                        Text(person.role)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Kartu Family Code
                VStack(alignment: .leading, spacing: 8) {
                    Text("Family Code")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(displayFamilyCode)
                            .font(.title3)
                            .monospacedDigit()
                        Spacer()
                        Button {
                            isCodeHidden.toggle()
                        } label: {
                            Image(systemName: isCodeHidden ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(14)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                
                // Kartu Family Members
                VStack(alignment: .leading, spacing: 10) {
                    Text("Family Members")
                        .font(.headline)
                    
                    if members.isEmpty {
                        Text("No family member data.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(Array(members.enumerated()), id: \.offset) { index, member in
                                HStack(spacing: 12) {
                                    // inisial bulat kecil kaya avatar mini
                                    let initial = member.first.map { String($0).uppercased() } ?? "?"
                                    ZStack {
                                        Circle()
                                            .fill(Color(.systemGray5))
                                        Text(initial)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                    .frame(width: 32, height: 32)
                                    
                                    Text(member)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    if isEditing {
                                        Button {
                                            members.remove(at: index)
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 0.8)
                                )
                            }
                        }
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)
                
                Spacer(minLength: 0)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Family")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        // dummy tambah member baru, nanti bisa diganti jadi form
                        members.append("New member")
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        isEditing.toggle()
                    } label: {
                        Text(isEditing ? "Done" : "Edit")
                    }
                }
            }
        }
    }
}


