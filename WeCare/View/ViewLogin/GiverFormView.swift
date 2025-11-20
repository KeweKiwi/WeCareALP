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
    // gender hanya dua
    let genders = ["Male", "Female"]
    var body: some View {
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
                        } else {
                            SecureField("••••••••", text: $password)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        Button { withAnimation { showPassword.toggle() } } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(.secondary)
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
            // === Care Receiver toggle / Family Code ===
            Section(header: Text("Care Receiver")) {
                Toggle("Already have care receiver?", isOn: $hasExistingReceiver)
                if hasExistingReceiver {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Family code (6 digits)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        OTPBoxes(code: familyCode, slots: 6)
                            .contentShape(Rectangle())
                            .onTapGesture { fcFocused = true }
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
                } else {
                    Text("Add your care receiver(s) below.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
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
                                removeMember(at: i)
                            } label: {
                                Label("Remove member", systemImage: "trash")
                            }
                        }
                    }
                }
                // Add member berdiri sendiri (bukan di dalam Section)
                Button {
                    addMember()
                } label: {
                    Label("Add member", systemImage: "plus.circle.fill")
                        .font(.body.weight(.semibold))
                }
            }
            // === Submit ===
            Section {
                Button {
                    if hasExistingReceiver {
                        // TODO: link receiver via familyCode
                    } else {
                        // TODO: create receivers
                    }
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isContinueEnabled ? Color.black : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                // tetap disable untuk cegah tap
                .disabled(!isContinueEnabled)
            }
        }
        .navigationTitle("Care Taker Biodata")
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


