//
//  CommunicationView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import SwiftUI
struct CommunicationView: View {
    let volunteer: Volunteer
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Chat with \(volunteer.name)")
                .font(.title2.bold())
            
            Spacer()
            
            Button(action: {
                // Integrate actual video call in future
            }) {
                Text("Start Video Call")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#fdcb46"))
                    .foregroundColor(.black)
                    .cornerRadius(15)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Communication")
        .navigationBarTitleDisplayMode(.inline)
    }
}
//#Preview {
//    CommunicationView()
//}
