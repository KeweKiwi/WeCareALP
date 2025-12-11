//
//  VolunteerRegistrationView.swift
//  WeCare
//
//  Created by student on 04/12/25.
//
import SwiftUI

struct VolunteerRegistrationView: View {
    @ObservedObject var viewModel: VolunteerModeVM
    
    @State private var name: String = ""
    @State private var ageText: String = ""
    @State private var gender: String = "Female"
    @State private var specialty: String = ""
    @State private var restrictions: String = ""
    
    @State private var showValidationError: Bool = false
    
    // NEW: dummy state untuk upload KTP & selfie (prototype only)
    @State private var isKTPUploaded: Bool = false
    @State private var isSelfieUploaded: Bool = false
    
    private let genders = ["Female", "Male", "Other"]
    
    // Palette
    private let yellow = Color(hex: "#fdcb46")
    private let red = Color(hex: "#fa6255")
    private let green = Color(hex: "#a6d17d")
    private let skyBlue = Color(hex: "#91bef8")
    private let softBlue = Color(hex: "#e1c7ec")
    
    var body: some View {
        ZStack {
            // Background pakai system background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header
                    HStack(alignment: .top, spacing: 12) {

                        // Strip kuning sejajar subtitle
                        VStack {
                            Spacer().frame(height: 4)   // geser sedikit agar sejajar teks bawah
                            RoundedRectangle(cornerRadius: 10)
                                .fill(yellow)
                                .frame(width: 8, height: 40) // cukup untuk tinggi subtitle saja
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 4) {

                            Text("Become a Volunteer")
                                .font(.largeTitle.bold())
                                .foregroundColor(.black)

                            Text("As a volunteer, you can help other caregivers by running errands, buying medicine, or visiting care receivers nearby.")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }
                    .padding(.top)

                    
                    // Info card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(skyBlue)
                            Text("Why we need your details")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        
                        Text("Your profile will be shown to caregivers who are looking for help. Please fill in your real information so they can understand who you are and what you can help with.")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(softBlue.opacity(0.9))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(skyBlue.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // FORM WRAPPER
                    VStack(alignment: .leading, spacing: 18) {
                        // Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.black.opacity(0.8))
                            TextField("Your full name", text: $name)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(softBlue, lineWidth: 1)
                                )
                        }
                        
                        // Age
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.black.opacity(0.8))
                            TextField("e.g. 28", text: $ageText)
                                .keyboardType(.numberPad)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(softBlue, lineWidth: 1)
                                )
                        }
                        
                        // Gender
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Gender")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.black.opacity(0.8))
                            Picker("Gender", selection: $gender) {
                                ForEach(genders, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.001)) // biar gak ganggu, cuma supaya kelihatan rapi
                            )
                        }
                        
                        // Specialty
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Specialty")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.black.opacity(0.8))
                            TextField(
                                "Example: elderly care, basic medical check, grocery shopping",
                                text: $specialty,
                                axis: .vertical
                            )
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(softBlue, lineWidth: 1)
                            )
                            .lineLimit(2, reservesSpace: true)
                        }
                        
                        // Restrictions / Notes
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Restrictions / Notes")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.black.opacity(0.8))
                            TextField(
                                "Example: cannot lift heavy objects, available only on weekends, etc.",
                                text: $restrictions,
                                axis: .vertical
                            )
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(softBlue, lineWidth: 1)
                            )
                            .lineLimit(3, reservesSpace: true)
                        }
                    }
                    .padding(16)
                    .background(
                        // ⬇️ Biar beda jelas dari background, pakai abu-abu muda + border biru lembut
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(softBlue.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // NEW: Identity verification (prototype KTP & selfie)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.checkerboard")
                                .foregroundColor(green)
                            Text("Identity Verification (Prototype)")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        
                        Text("In a real app, you would upload your ID card (KTP) and a selfie photo so the WeCare team can verify your identity before activating your volunteer account. For this prototype, you can simply tap the buttons below to simulate uploading.")
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.7))
                        
                        // Upload KTP
                        Button(action: {
                            isKTPUploaded.toggle()
                        }) {
                            HStack {
                                Image(systemName: isKTPUploaded ? "checkmark.circle.fill" : "doc.text.viewfinder")
                                    .foregroundColor(isKTPUploaded ? green : skyBlue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isKTPUploaded ? "ID Card (KTP) uploaded (prototype)" : "Upload ID Card (KTP)")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Helps WeCare verify your identity")
                                        .font(.caption2)
                                        .foregroundColor(.black.opacity(0.6))
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(isKTPUploaded ? green.opacity(0.2) : Color.white.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(skyBlue.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // Upload selfie
                        Button(action: {
                            isSelfieUploaded.toggle()
                        }) {
                            HStack {
                                Image(systemName: isSelfieUploaded ? "checkmark.circle.fill" : "person.crop.square")
                                    .foregroundColor(isSelfieUploaded ? green : skyBlue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isSelfieUploaded ? "Selfie photo uploaded (prototype)" : "Upload selfie photo")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Matches your face with your ID")
                                        .font(.caption2)
                                        .foregroundColor(.black.opacity(0.6))
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(isSelfieUploaded ? green.opacity(0.2) : Color.white.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(skyBlue.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        Text("You can skip these steps for now. They are optional in this prototype and do not block registration.")
                            .font(.caption2)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .padding(16)
                    .background(
                        // ⬇️ Sama: card dibuat beda dengan background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(skyBlue.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    if showValidationError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(red)
                            Text("Please fill in at least your name, age, and specialty.")
                                .font(.caption)
                                .foregroundColor(red)
                        }
                    }
                    
                    Spacer(minLength: 10)
                    
                    // Button
                    Button(action: registerTapped) {
                        Text("Register as Volunteer")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(green) // sesuai tema: hijau #a6d17d
                            .foregroundColor(.black)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 3)
                    }
                    .padding(.top, 4)
                    
                    Text("You can change your availability later from the Volunteer Mode home screen.")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func registerTapped() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSpecialty = specialty.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard
            !trimmedName.isEmpty,
            let ageInt = Int(ageText),
            ageInt > 0,
            !trimmedSpecialty.isEmpty
        else {
            showValidationError = true
            return
        }
        
        viewModel.registerVolunteer(
            name: trimmedName,
            age: ageInt,
            gender: gender,
            specialty: trimmedSpecialty,
            restrictions: restrictions.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}


