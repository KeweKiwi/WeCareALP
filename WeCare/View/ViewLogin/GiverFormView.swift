import SwiftUI

struct GiverFormView: View {
    // Care Taker (yang login)
    @State private var email: String = ""
    @State private var fullName: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var dob: Date = Calendar.current.date(byAdding: .year, value: -25, to: .now) ?? .now
    @State private var gender: String = "Male"   // default
    
    // Relasi ke Care Receiver
    @State private var hasExistingReceiver: Bool = true
    @State private var familyCode: String = ""
    @FocusState private var fcFocused: Bool
    
    // MULTI MEMBER TANPA STRUCT — arrays paralel
    @State private var rcNames:   [String] = [""]
    @State private var rcPhones:  [String] = [""]
    @State private var rcDOBs:    [Date]   = [Calendar.current.date(byAdding: .year, value: -60, to: .now) ?? .now]
    @State private var rcGenders: [String] = ["Male"]
    
    // Animation states
    @State private var appeared: Bool = false
    @State private var shakeAnimation: CGFloat = 0
    
    // gender hanya dua
    let genders = ["Male", "Female"]
    
    var body: some View {
        ZStack {
            Form {
            // === Care Taker ===
            Section(header: Text("Care Taker")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password").font(.caption).foregroundStyle(.secondary)
                    HStack {
                        if showPassword {
                            TextField("••••••••", text: $password)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .transition(.opacity)
                        } else {
                            SecureField("••••••••", text: $password)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .transition(.opacity)
                        }
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(showPassword ? 180 : 0))
                        }
                    }
                }
                
                TextField("Full name", text: $fullName)
                
                TextField("Phone number", text: $phone)
                    .keyboardType(.phonePad)
                
                DatePicker("Date of birth", selection: $dob, displayedComponents: .date)
                
                Picker("Gender", selection: $gender) {
                    ForEach(genders, id: \.self) { Text($0) }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appeared)
            
            // === Care Receiver toggle / Family Code ===
            Section(header: Text("Care Receiver")) {
                Toggle("Already have care receiver?", isOn: $hasExistingReceiver)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hasExistingReceiver)
                
                if hasExistingReceiver {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Family code (6 digits)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        OTPBoxes(code: familyCode, slots: 6)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    fcFocused = true
                                }
                            }
                            .scaleEffect(fcFocused ? 1.02 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: fcFocused)
                        
                        // TextField tersembunyi utk tangkap angka
                        TextField("", text: Binding(
                            get: { familyCode },
                            set: { newVal in
                                let digits = newVal.filter { $0.isNumber }
                                familyCode = String(digits.prefix(6))
                            })
                        )
                        .keyboardType(.numberPad)
                        .focused($fcFocused)
                        .frame(width: 0, height: 0)
                        .opacity(0.01)
                        .accessibilityHidden(true)
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                } else {
                    Text("Add your care receiver(s) below.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
            
            // === Member Sections (satu member = satu section dg header abu-abu) ===
            if !hasExistingReceiver {
                ForEach(rcNames.indices, id: \.self) { i in
                    Section(header: Text("Member \(i + 1)")) {
                        TextField("Full name", text: $rcNames[i])
                        TextField("Phone number", text: $rcPhones[i])
                            .keyboardType(.phonePad)
                        DatePicker("Date of birth", selection: $rcDOBs[i], displayedComponents: .date)
                        Picker("Gender", selection: $rcGenders[i]) {
                            ForEach(genders, id: \.self) { Text($0) }
                        }
                        
                        if rcNames.count > 1 {
                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    removeMember(at: i)
                                }
                            } label: {
                                Label("Remove member", systemImage: "trash")
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
                
                // Add member berdiri sendiri (bukan di dalam Section)
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        addMember()
                    }
                } label: {
                    Label("Add member", systemImage: "plus.circle.fill")
                        .font(.body.weight(.semibold))
                }
                .scaleEffect(rcNames.isEmpty ? 1.0 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rcNames.count)
            }
            
            // === Submit ===
            Section {
                Button {
                    if isContinueEnabled {
                        if hasExistingReceiver {
                            // TODO: link receiver via familyCode
                        } else {
                            // TODO: create receivers
                        }
                    } else {
                        // Shake animation when disabled
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                            shakeAnimation += 1
                        }
                    }
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isContinueEnabled ? Color.black : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .scaleEffect(isContinueEnabled ? 1.0 : 0.98)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isContinueEnabled)
                .modifier(ShakeEffect(shakes: shakeAnimation))
                // tetap disable untuk cegah tap
                .disabled(!isContinueEnabled)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.95)
        }
        .navigationTitle("Care Taker Biodata")
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
    
    // Helpers
    private func addMember() {
        rcNames.append("")
        rcPhones.append("")
        rcDOBs.append(Calendar.current.date(byAdding: .year, value: -60, to: .now) ?? .now)
        rcGenders.append("Male")
    }
    
    private func removeMember(at index: Int) {
        rcNames.remove(at: index)
        rcPhones.remove(at: index)
        rcDOBs.remove(at: index)
        rcGenders.remove(at: index)
    }
    
    private var isContinueEnabled: Bool {
        guard !email.isEmpty, email.contains("@"),
              !password.isEmpty, password.count >= 6,
              !fullName.isEmpty, !phone.isEmpty else { return false }
        
        if hasExistingReceiver {
            return familyCode.count == 6
        } else {
            for i in rcNames.indices {
                if !rcNames[i].isEmpty && !rcPhones[i].isEmpty {
                    return true
                }
            }
            return false
        }
    }
}

// Shake effect modifier
struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 10 * sin(shakes * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
