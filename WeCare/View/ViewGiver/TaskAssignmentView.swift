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
    @State private var requestSent = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Assign Task to \(volunteer.name)")
                .font(.title2.bold())
            
            TextField("Task Description", text: $taskDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
            
            TextField("Required Tools / Materials", text: $toolsNeeded)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()
            
            Button(action: {
                requestSent = true
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
            .padding()
            .sheet(isPresented: $requestSent) {
                VolunteerConfirmationView(volunteer: volunteer)
            }
        }
        .padding()
        .navigationTitle("Task Assignment")
        .navigationBarTitleDisplayMode(.inline)
    }
}
//#Preview {
//    TaskAssignmentView()
//}
