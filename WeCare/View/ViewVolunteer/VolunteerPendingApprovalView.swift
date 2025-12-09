//
//  VolunteerPendingApprovalView.swift
//  WeCare
//
//  Created by student on 09/12/25.
//

import SwiftUI

struct VolunteerPendingApprovalView: View {
    @ObservedObject var viewModel: VolunteerModeVM
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "hourglass.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(Color(hex: "#fdcb46"))
            
            Text("Your volunteer profile is being reviewed")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let profile = viewModel.profile {
                Text("Thank you, \(profile.name). For safety reasons, our team will review your information before you can receive requests.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("For safety reasons, our team will review your information before you can receive requests.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Info tambahan
            Text("This helps us keep caregivers and care receivers safe by making sure each volunteer is verified.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // 🔹 Link biru untuk simulasi approval
            Text("Simulate: admin approved my volunteer profile")
                .font(.caption)
                .foregroundColor(.blue)
                .underline()
                .onTapGesture {
                    // Prototype: langsung set approved
                    viewModel.approveRegistration()
                }
            
            Text("Prototype only – in a real app, approval would be done by the WeCare admin team.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Pending Approval")
        .navigationBarTitleDisplayMode(.inline)
    }
}
