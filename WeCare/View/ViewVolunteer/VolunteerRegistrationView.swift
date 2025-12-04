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
    
    private let genders = ["Female", "Male", "Other"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Become a Volunteer")
                        .font(.largeTitle.bold())
                    
                    Text("As a volunteer, you can help other caregivers by running errands, buying medicine, or visiting care receivers nearby.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                // Info card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why we need your details")
                        .font(.headline)
                    Text("Your profile will be shown to caregivers who are looking for help. Please fill in your real information so they can understand who you are and what you can help with.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                
                // FORM
                Group {
                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Your full name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Age
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Age")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("e.g. 28", text: $ageText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Gender
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Gender")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Gender", selection: $gender) {
                            ForEach(genders, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Specialty
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Specialty")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Example: elderly care, basic medical check, grocery shopping", text: $specialty, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(2, reservesSpace: true)
                    }
                    
                    // Restrictions / Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Restrictions / Notes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Example: cannot lift heavy objects, available only on weekends, etc.", text: $restrictions, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3, reservesSpace: true)
                    }
                }
                
                if showValidationError {
                    Text("Please fill in at least your name, age, and specialty.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer(minLength: 10)
                
                // Button
                Button(action: registerTapped) {
                    Text("Register as Volunteer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#a6d17d"))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                }
                .padding(.top, 4)
                
                Text("You can change your availability later from the Volunteer Mode home screen.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .padding()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Volunteer Registration")
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


