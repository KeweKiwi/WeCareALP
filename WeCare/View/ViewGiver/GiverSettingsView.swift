import SwiftUI

struct GiverSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    
    @StateObject private var viewModel: GiverSettingsVM
    
    @State private var showingImagePicker = false
    @State private var showingLogoutAlert = false
    @State private var isEditMode = false
    @State private var isPasswordVisible = false
    @State private var showContent = false
    
    let genderOptions = ["Male", "Female"]
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: GiverSettingsVM(userId: userId))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5F5").ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            profileImageSection
                            
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 20)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                            VStack(spacing: 12) {
                                settingsField(
                                    title: "Name",
                                    text: $viewModel.name,
                                    icon: "person.fill"
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)),
                                    removal: .opacity
                                ))
                                
                                settingsField(
                                    title: "Email",
                                    text: $viewModel.email,
                                    icon: "envelope.fill"
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)),
                                    removal: .opacity
                                ))
                                
                                genderPicker
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.15)),
                                        removal: .opacity
                                    ))
                                
                                settingsField(
                                    title: "Password",
                                    text: $viewModel.password,
                                    icon: "lock.fill",
                                    isSecure: true
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2)),
                                    removal: .opacity
                                ))
                                
                                settingsField(
                                    title: "Phone",
                                    text: $viewModel.phone,
                                    icon: "phone.fill",
                                    isNumeric: true
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.25)),
                                    removal: .opacity
                                ))
                            }
                            .padding(.horizontal, 20)
                            
                            logoutButton
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    }
                }
            }
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authVM.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }
}

extension GiverSettingsView {
    private var header: some View {
        HStack {
            if isEditMode {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isEditMode = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.reloadData()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#8B5CF6"))
                }
                .buttonStyle(ScaleButtonStyle())
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            } else {
                Color.clear
                    .frame(width: 24, height: 24)
            }

            Spacer()

            Text("Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            if isEditMode {
                Button {
                    viewModel.saveChanges()
                    withAnimation {
                        isEditMode = false
                    }
                } label: {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#8B5CF6"))
                }
                .buttonStyle(ScaleButtonStyle())
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            } else {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isEditMode = true
                    }
                } label: {
                    Text("Edit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#8B5CF6"))
                }
                .buttonStyle(ScaleButtonStyle())
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(hex: "#F5F5F5"))
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(hex: "#8B5CF6").opacity(0.15))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#8B5CF6"))
                    )
                    .scaleEffect(isEditMode ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEditMode)
                
                if isEditMode {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Circle()
                            .fill(Color(hex: "#8B5CF6"))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
                    }
                    .buttonStyle(PulseButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    private func settingsField(
        title: String,
        text: Binding<String>,
        icon: String,
        isSecure: Bool = false,
        isNumeric: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#666666"))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#8B5CF6"))
                    .frame(width: 24)
                    .scaleEffect(isEditMode ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isEditMode)
                
                if isEditMode {
                    if isSecure {
                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField("Enter \(title.lowercased())", text: text)
                                } else {
                                    SecureField("Enter \(title.lowercased())", text: text)
                                }
                            }
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isPasswordVisible.toggle()
                                }
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#8B5CF6"))
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    } else {
                        TextField("Enter \(title.lowercased())", text: text)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .keyboardType(isNumeric ? .numberPad : .default)
                            .onChange(of: text.wrappedValue) { newValue in
                                guard isNumeric else { return }
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue {
                                    text.wrappedValue = filtered
                                }
                            }
                    }
                } else {
                    if isSecure {
                        Text("••••••••")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#333333"))
                    } else {
                        Text(text.wrappedValue.isEmpty ? "-" : text.wrappedValue)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#333333"))
                    }
                    Spacer()
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEditMode ? Color(hex: "#8B5CF6").opacity(0.3) : Color.clear,
                            lineWidth: 1.5)
            )
            .shadow(color: isEditMode ? Color(hex: "#8B5CF6").opacity(0.1) : Color.clear, radius: 8, y: 4)
            .scaleEffect(isEditMode ? 1.0 : 0.98)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEditMode)
        }
    }
    
    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#666666"))
            
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "#8B5CF6"))
                    .frame(width: 24)
                    .scaleEffect(isEditMode ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isEditMode)
                
                if isEditMode {
                    Picker("", selection: $viewModel.gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color(hex: "#333333"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(viewModel.gender.isEmpty ? "-" : viewModel.gender)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#333333"))
                    Spacer()
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEditMode ? Color(hex: "#8B5CF6").opacity(0.3) : Color.clear,
                            lineWidth: 1.5)
            )
            .shadow(color: isEditMode ? Color(hex: "#8B5CF6").opacity(0.1) : Color.clear, radius: 8, y: 4)
            .scaleEffect(isEditMode ? 1.0 : 0.98)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEditMode)
        }
    }
    
    private var logoutButton: some View {
        Button {
            showingLogoutAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                Text("Logout")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "#EF4444"))
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}



struct PulseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    GiverSettingsView(userId: "dummy-id")
        .environmentObject(AuthViewModel())
}
