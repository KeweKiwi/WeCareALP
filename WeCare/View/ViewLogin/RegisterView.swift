import SwiftUI
// =====================================================
// MARK: - REGISTER VIEW (Role Selection)
// =====================================================
struct RegisterView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("I am a")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Brand.red, Brand.vlight.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
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
    
    @StateObject private var vm = FamiliesViewModel()
    @State private var isVerifying: Bool = false
    
    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                colors: [
                    Color(hex: "#fff5f8"),
                    Color(hex: "#f0f4ff"),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    NavigationLink(
                        destination: CareReceiverSelectView(familyCode: familyCode),
                        isActive: $goToSelect
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Header Icon
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Brand.green, Brand.green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Brand.green.opacity(0.2), radius: 15, y: 8)
                    
                    VStack(spacing: 8) {
                        Text("Family Code")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Brand.green, Brand.green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Use the 6 digit family code given by your caretaker")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 8)
                    
                    // OTP Boxes
                    OTPBoxes(code: familyCode, slots: 6)
                        .onTapGesture { isFocused = true }
                        .padding(.vertical, 8)
                    
                    // Paste & Help Buttons
                    HStack(spacing: 12) {
                        Button {
                            #if canImport(UIKit)
                            let paste = UIPasteboard.general.string ?? ""
                            let digits = paste.filter { $0.isNumber }
                            familyCode = String(digits.prefix(6))
                            #endif
                            errorMessage = nil
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.clipboard.fill")
                                    .font(.system(size: 13))
                                Text("Paste")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Brand.green)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button {
                            errorMessage = "Ask your caretaker. The family code is generated after they log in and set up your family."
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 12))
                                Text("Need help?")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                    
                    // Hidden TextField
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
                    
                    // Error Message
                    if let msg = errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                            Text(msg)
                                .font(.system(size: 13))
                        }
                        .foregroundColor(Brand.red)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Continue Button
                    Button {
                        if familyCode.count < 6 {
                            errorMessage = "Code must be 6 digits"
                        } else {
                            verifyCode()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if isVerifying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            }
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(isVerifying ? "Verifying..." : "Continue")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    (familyCode.count == 6 && !isVerifying)
                                    ? LinearGradient(
                                        colors: [Brand.green, Brand.green.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.25)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(
                                    color: (familyCode.count == 6 && !isVerifying) ? Brand.green.opacity(0.3) : .clear,
                                    radius: 15,
                                    y: 8
                                )
                        )
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(familyCode.count != 6 || isVerifying)
                    .padding(.top, 8)
                    
                    // Information Box
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Brand.yellow)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Don't see the code?")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("Ask your caretaker to open WeCare and share the 6-digit family code with you.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    )
                    .padding(.top, 8)
                    
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // 4. Verification Logic
    private func verifyCode() {
        isVerifying = true
        errorMessage = nil
        
        vm.fetchFamily(byFamilyCode: familyCode) { family in
            isVerifying = false
            
            if family != nil {
                // Success: Family found
                goToSelect = true
            } else {
                // Fail: No family found
                errorMessage = "Invalid Family Code. Please check and try again."
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


