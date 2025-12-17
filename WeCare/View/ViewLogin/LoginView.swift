import SwiftUI

enum Brand {
    static let yellow = Color(hex: "#fdcb46")
    static let red    = Color(hex: "#fa6255")
    static let green  = Color(hex: "#a6d17d")
    static let sky    = Color(hex: "#91bef8")
    static let vlight = Color(hex: "#e1c7ec")
    static let ivory  = Color(hex: "#fff9e6")
}

// ===== Field Border Modifier (soft & minimal) =====
private struct FieldBox: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            )
    }
}

private extension View {
    func fieldBox() -> some View { modifier(FieldBox()) }
}

// ===== LoginView =====
struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var errorText: String?
    
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
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: 20)
                
                // Logo Section
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Brand.red, Brand.vlight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Brand.red.opacity(0.2), radius: 20, y: 10)
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 0) {
                            Text("Welcome")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Brand.red, Brand.vlight.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text(" back")
                                .font(.system(size: 36, weight: .light))
                                .foregroundColor(Color(hex: "#6b7280"))
                        }
                        
                        Text("Sign in to continue")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 50)
                
                // Form Section
                VStack(alignment: .leading, spacing: 20) {
                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "envelope.fill")
                                .font(.caption)
                                .foregroundColor(Brand.red.opacity(0.7))
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.gray.opacity(0.5)))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                            .font(.system(size: 16))
                            .fieldBox()
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(Brand.red.opacity(0.7))
                            Text("Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            if showPassword {
                                TextField("", text: $password, prompt: Text("Enter your password").foregroundColor(.gray.opacity(0.5)))
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .font(.system(size: 16))
                            } else {
                                SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(.gray.opacity(0.5)))
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .font(.system(size: 16))
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showPassword.toggle()
                                }
                            } label: {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                        }
                        .fieldBox()
                    }
                    
                    // Error Messages
                    if let errorText {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                            Text(errorText)
                                .font(.system(size: 13))
                        }
                        .foregroundColor(Brand.red)
                        .padding(.horizontal, 4)
                    } else if let vmError = authVM.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                            Text(vmError)
                                .font(.system(size: 13))
                        }
                        .foregroundColor(Brand.red)
                        .padding(.horizontal, 4)
                    }
                    
                    // Sign In Button
                    Button(action: signIn) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 16, weight: .semibold))
                            
                            if isLoading || authVM.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                                Text("Signing in...")
                                    .font(.system(size: 17, weight: .semibold))
                            } else {
                                Text("Log In")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Brand.red, Brand.red.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Brand.red.opacity(0.3), radius: 15, y: 8)
                        )
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading || authVM.isLoading || email.isEmpty || password.isEmpty)
                    .opacity((isLoading || authVM.isLoading || email.isEmpty || password.isEmpty) ? 0.5 : 1)
                    .padding(.top, 8)
                    
                    // Sign Up Link
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 12))
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                            NavigationLink { RegisterView() } label: {
                                Text("Sign Up")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Brand.sky, Brand.sky.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Bottom text
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.caption)
                        .foregroundColor(Brand.green)
                    Text("Easy access, anytime")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#2b3a67"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .toolbarBackground(.clear, for: .navigationBar)
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
        
        authVM.signIn(email: email, password: password) { success in
            isLoading = false
            if !success, errorText == nil {
                if authVM.errorMessage == nil {
                    errorText = "Login failed, please try again."
                }
            }
        }
    }
}

// MARK: - Preview Flow (Login -> Main Tab) khusus untuk Canvas
struct LoginPreviewFlow: View {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var coordinator = NavigationCoordinator()
    
    var body: some View {
        Group {
            if authVM.isLoggedIn {
                GiverMainTabView()
                    .environmentObject(coordinator)
                    .environmentObject(authVM)
            } else {
                NavigationStack {
                    LoginView()
                }
                .environmentObject(authVM)
            }
        }
    }
}

#Preview {
    LoginPreviewFlow()
}
