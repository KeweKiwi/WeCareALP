//
//  TaskAssignmentView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//

import SwiftUI

struct TaskAssignmentView: View {
    let volunteer: Volunteer
    
    @State private var taskDescription = ""
    @State private var deadline = Date()
    @State private var toolsNeeded = ""
    @State private var offeredReward = ""   // price offer from caregiver
    
    @State private var goToConfirmation = false   // ⬅️ untuk NavigationLink, bukan sheet
    
    var body: some View {
        VStack(spacing: 20) {
            // TITLE
            Text("Assign Task to \(volunteer.name)")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // TASK DESCRIPTION
            VStack(alignment: .leading, spacing: 6) {
                Text("Task Description")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField(
                    "Describe what you need help with",
                    text: $taskDescription,
                    axis: .vertical
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3, reservesSpace: true)
            }
            
            // DEADLINE
            VStack(alignment: .leading, spacing: 6) {
                Text("Deadline")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                DatePicker(
                    "",
                    selection: $deadline,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading) // ⬅️ tetap rata kiri
            }
            
            // TOOLS / MATERIALS
            VStack(alignment: .leading, spacing: 6) {
                Text("Required Tools / Materials")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField(
                    "Example: gloves, wheelchair, disinfectant, etc.",
                    text: $toolsNeeded,
                    axis: .vertical
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(2, reservesSpace: true)
            }
            
            // 💰 PROPOSED REWARD / FEE
            VStack(alignment: .leading, spacing: 6) {
                Text("Proposed Reward for Volunteer")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Rp")
                        .foregroundColor(.gray)
                    
                    TextField("e.g. 150000", text: $offeredReward)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Text("This is your suggested fee and can be discussed with the volunteer.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // SEND REQUEST BUTTON
            Button(action: {
                // Prototype only: data belum dikirim ke backend / VM lanjutan.
                // Di sini kita hanya navigate ke halaman konfirmasi.
                goToConfirmation = true
            }) {
                Text("Send Request")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#a6d17d"))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .shadow(radius: 3)
            }
            .padding(.bottom)
            
            // 🔒 Hidden NavigationLink → VolunteerConfirmationView
            NavigationLink(
                destination: VolunteerConfirmationView(
                    viewModel: VolunteerConfirmationVM(volunteer: volunteer)
                ),
                isActive: $goToConfirmation
            ) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Task Assignment")
        .navigationBarTitleDisplayMode(.inline)
    }
}


