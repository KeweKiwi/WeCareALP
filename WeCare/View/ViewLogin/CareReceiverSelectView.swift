import SwiftUI
struct CareReceiverSelectView: View {
    let familyCode: String
    
    struct Member: Identifiable {
        let id = UUID()
        let name: String
        let gender: String
        let phone: String
        let birthDateText: String
    }
    @State private var members: [Member] = [
        Member(name: "Aisyah Putri", gender: "Female", phone: "0812 3456 7890", birthDateText: "12 Jan 2015"),
        Member(name: "Muhammad Rizky", gender: "Male",   phone: "0813 1111 2222", birthDateText: "03 Sep 2012")
    ]
    @State private var selectedID: UUID?
    @State private var goDashboard: Bool = false
    var body: some View {
        ZStack {
            Color(hex: "FFF9E6").ignoresSafeArea()
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Family code
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Family code")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.secondary)
                            Text(familyCode)
                                .font(.title2.monospaced())
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(radius: 4, y: 2)
                                )
                        }
                        Text("Select your profile")
                            .font(.title2.weight(.semibold))
                        // Cards besar
                        VStack(spacing: 20) {
                            ForEach(members) { member in
                                Button {
                                    selectedID = member.id
                                } label: {
                                    HStack(spacing: 18) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: "91BEF8").opacity(0.25))
                                                .frame(width: 70, height: 70)
                                            Text(String(member.name.prefix(1)))
                                                .font(.largeTitle.weight(.bold))
                                                .foregroundColor(.black)
                                        }
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(member.name)
                                                .font(.title3.weight(.semibold))
                                                .foregroundColor(.black)
                                            Text(member.gender)
                                                .font(.body)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule().fill(Color(hex: "E1C7EC").opacity(0.7))
                                                )
                                                .foregroundColor(.black)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(member.phone)
                                                    .font(.body)
                                                    .foregroundColor(.secondary)
                                                Text(member.birthDateText)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        if selectedID == member.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(Color(hex: "A6D17D"))
                                        }
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .shadow(radius: 5, y: 3)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                // NavigationLink “tersembunyi”
                NavigationLink(
                    destination: ReceiverView(viewModel: ReceiverVM()),
                    isActive: $goDashboard
                ) {
                    EmptyView()
                }
                // Button Continue
                VStack(spacing: 12) {
                    Button {
                        if selectedID != nil {
                            goDashboard = true
                        }
                    } label: {
                        Text("Continue")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(selectedID == nil
                                          ? Color.gray.opacity(0.3)
                                          : Color(hex: "FA6255"))
                            )
                            .foregroundColor(selectedID == nil ? .secondary : .white)
                    }
                    .disabled(selectedID == nil)
                    if selectedID == nil {
                        Text("Please select a profile first")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Who are you?")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}


