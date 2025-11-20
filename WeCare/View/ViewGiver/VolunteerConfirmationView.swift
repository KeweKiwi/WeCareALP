//
//  VolunteerConfirmationView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import SwiftUI
struct VolunteerConfirmationView: View {
    let volunteer: Volunteer
    @State private var accepted = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Request Sent")
                .font(.largeTitle.bold())
                .foregroundColor(Color(hex: "#387b38"))
            
            Text("Waiting for \(volunteer.name) to accept...")
                .font(.headline)
                .foregroundColor(.gray)
            
            // Simulate acceptance after delay
            Button("Simulate Acceptance") {
                accepted = true
            }
            
            if accepted {
                NavigationLink(destination: CommunicationView(volunteer: volunteer)) {
                    Text("Start Chat / Video Call")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#91bef8"))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                .padding()
            }
        }
        .padding()
    }
}
//#Preview {
//    VolunteerConfirmationView()
//}
