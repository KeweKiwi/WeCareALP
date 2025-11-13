import SwiftUI
// ===== Brand Palette =====
//fileprivate extension Color {
//    init(hex: String) {
//        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
//        if h.hasPrefix("#") { h.removeFirst() }
//        var v: UInt64 = 0; Scanner(string: h).scanHexInt64(&v)
//        self = Color(.sRGB,
//                     red: Double((v >> 16) & 0xFF) / 255,
//                     green: Double((v >> 8) & 0xFF) / 255,
//                     blue: Double(v & 0xFF) / 255,
//                     opacity: 1)
//    }
//}
enum Brand {
    static let yellow = Color(hex: "#fdcb46")
    static let red    = Color(hex: "#fa6255")
    static let green  = Color(hex: "#a6d17d")
    static let sky    = Color(hex: "#91bef8")
    static let vlight = Color(hex: "#e1c7ec")
    static let ivory  = Color(hex: "#fff9e6")
}
// ===== Field Border Modifier (tipis & halus) =====
private struct FieldBox: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
            )
    }
}
private extension View { func fieldBox() -> some View { modifier(FieldBox()) } }
// ===== LoginView =====
struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var errorText: String?
    var body: some View {
        ZStack {
            // Konten utama — center nyaman
            VStack(spacing: 30) {
                Spacer(minLength: 0)
                Text("LOG IN")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(hex: "#2b3a67"))
                // Card
                VStack(alignment: .leading, spacing: 16) {
                    // Email
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("", text: $email)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                            .fieldBox()
                    }
                    // Password
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            if showPassword {
                                TextField("••••••••", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("••••••••", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                            }
                            Button { withAnimation { showPassword.toggle() } } label: {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .fieldBox()
                    }
                    // Error
                    if let errorText {
                        Text(errorText)
                            .font(.caption)
                            .foregroundColor(Brand.red)
                    }
                    // Sign In Button
                    Button(action: signIn) {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Text(isLoading ? "Loading..." : "Sign In")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Brand.red, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain) // matikan styling default
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.75 : 1)
                    // Link ke Sign Up
                    HStack {
                        Spacer()
                        NavigationLink { RegisterView() } label: {
                            Text("Don't have an account? Sign Up")
                                .font(.footnote)
                                .underline()
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
                )
                .padding(.horizontal, 30)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -15) // kecilin/naikin sesuai selera
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Back (plain, no double container)
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(8)
                        // kalau mau ada bubble tipis: ganti 0.0 jadi 0.08
                        .background(Color.white.opacity(0.0), in: Circle())
                }
                .buttonStyle(.plain)
            }
            // Register (satu lapis, foreground putih bersih)
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink { RegisterView() } label: {
                    Text("Register")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.blue, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        // Hilangkan glow/aura putih dari nav bar
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .tint(.primary) // cegah iOS inject warna aneh
    }
    private func signIn() {
        errorText = nil
        guard email.contains("@"), email.contains(".") else {
            errorText = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorText = "Password must be at least 6 characters."
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            // TODO: navigate to main app
        }
    }
}

