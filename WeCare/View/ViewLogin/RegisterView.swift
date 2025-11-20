import SwiftUI
// =====================================================
// MARK: - REGISTER VIEW (Role Selection)
// =====================================================
struct RegisterView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Brand.ivory.ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("I am a")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.black)
                        Text("Select one that applies to you")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)
                    // Care Receiver (green) -> Family Code
                    NavigationLink {
                        FamilyCodeView()
                    } label: {
                        BigTile(
                            title: "Care Receiver",
                            imageName: "carereceiver",
                            bg: Brand.green
                        )
                    }
                    // Care Giver (sky) -> Biodata Care Taker
                    NavigationLink {
                            GiverFormView()
                    } label: {
                        BigTile(
                            title: "Care Giver",
                            imageName: "caregiver",
                            bg: Brand.sky
                        )
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
// =====================================================
// MARK: - BIG TILE (foto besar, pas 1 halaman)
// =====================================================
struct BigTile: View {
    let title: String
    let imageName: String
    let bg: Color
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .clipped()
                .overlay(bg.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.black.opacity(0.06), lineWidth: 1)
                )
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.9), in: Capsule())
                .padding(16)
        }
        .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
    }
}
// =====================================================
// MARK: - FAMILY CODE VIEW (6-digit; ke pilih biodata)
// =====================================================
struct FamilyCodeView: View {
    @State private var familyCode: String = ""
    @FocusState private var isFocused: Bool
    @State private var errorMessage: String? = nil
    @State private var goToSelect: Bool = false
    var body: some View {
        ZStack {
            Brand.vlight.opacity(0.25).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Nav ke pilih biodata (hidden)
                    NavigationLink(
                        destination: CareReceiverSelectView(familyCode: familyCode),
                        isActive: $goToSelect
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    Text("Please enter Family Code")
                        .font(.title2.bold())
                    Text("Use the 6 digit family code given by your caretaker.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                    OTPBoxes(code: familyCode, slots: 6)
                        .onTapGesture { isFocused = true }
                    HStack(spacing: 12) {
                        Button {
                            #if canImport(UIKit)
                            let paste = UIPasteboard.general.string ?? ""
                            let digits = paste.filter { $0.isNumber }
                            familyCode = String(digits.prefix(6))
                            #endif
                            errorMessage = nil
                        } label: {
                            Label("Paste", systemImage: "doc.on.clipboard")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(.white, in: Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(.black.opacity(0.08), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            errorMessage = "Ask your caretaker. The family code is generated after they log in and set up your family."
                        } label: {
                            Text("Where to get the code?")
                                .font(.footnote)
                                .underline()
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    TextField("", text: Binding(
                        get: { familyCode },
                        set: { newValue in
                            let digits = newValue.filter { $0.isNumber }
                            familyCode = String(digits.prefix(6))
                            errorMessage = nil
                        })
                    )
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0.01)
                    .accessibilityHidden(true)
                    .onAppear { isFocused = true }
                    if let msg = errorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Button {
                        if familyCode.count < 6 {
                            errorMessage = "Code must be 6 digits"
                        } else {
                            // Nanti di sini: call API cek code
                            // kalau OK:
                            goToSelect = true
                        }
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(familyCode.count == 6 ? Color.black : Color.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(familyCode.count != 6)
                    VStack(spacing: 14) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Brand.sky)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Don’t see the code?")
                                    .font(.subheadline.bold())
                                Text("Ask your caretaker to open WeCare and share the 6-digit family code with you.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(.black.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 4)
                    }
                    .padding(.top, 8)
                    Spacer().frame(height: 16)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
// =====================================================
// MARK: - OTP BOXES (blank saat kosong + kedip slot aktif)
// =====================================================
struct OTPBoxes: View {
    let code: String
    let slots: Int
    @State private var blink = false
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<slots, id: \.self) { i in
                ZStack {
                    let isActive = (i == code.count) && code.count < slots
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(
                                    isActive
                                    ? Color.black.opacity(blink ? 0.45 : 0.12)
                                    : Color.black.opacity(0.12),
                                    lineWidth: 1.8
                                )
                        )
                        .frame(width: 46, height: 56)
                        .animation(.easeInOut(duration: 0.6), value: blink)
                    Text(digit(at: i))
                        .font(.title3.weight(.semibold))
                        .monospaced()
                        .foregroundStyle(.black)
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                blink.toggle()
            }
        }
    }
    private func digit(at index: Int) -> String {
        guard index < code.count else { return "" }
        return String(Array(code)[index])
    }
}


