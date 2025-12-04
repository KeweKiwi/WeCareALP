//
//  VolunteerRequestDetailView.swift
//  WeCare
//
//  Created by student on 03/12/25.
//

import SwiftUI

struct VolunteerRequestDetailView: View {
    let request: VolunteerRequest
    @ObservedObject var viewModel: VolunteerModeVM
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Request from \(request.caregiverName)")
                        .font(.title3.bold())
                    Text("For: \(request.careReceiverName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Distance & time
                HStack {
                    Label("\(request.distanceKm, specifier: "%.1f") km away", systemImage: "location.fill")
                    Spacer()
                    Label(request.scheduledTime, systemImage: "clock.fill")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                
                // Task description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Description")
                        .font(.headline)
                    Text(request.taskDescription)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Location note
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location Note")
                        .font(.headline)
                    Text(request.locationNote)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Reward
                VStack(alignment: .leading, spacing: 6) {
                    Text("Offered Reward")
                        .font(.headline)
                    Text(request.offeredReward.asRupiah())
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#387b38"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 10)
                
                // Buttons
                VStack(spacing: 10) {
                    Button {
                        viewModel.accept(request)
                        dismiss()
                    } label: {
                        Text("Accept Request")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#a6d17d"))
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                    }
                    
                    Button {
                        viewModel.decline(request)
                        dismiss()
                    } label: {
                        Text("Decline")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color(hex: "#fa6255"))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Request Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}


