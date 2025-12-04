//
//  VolunteerRequestDetailView.swift
//  WeCare
//
//  Created by student on 03/12/25.
//
import SwiftUI
import MapKit

struct VolunteerRequestDetailView: View {
    let request: VolunteerRequest
    @ObservedObject var viewModel: VolunteerModeVM
    @Environment(\.dismiss) private var dismiss
    
    // Control tombol (digunakan untuk bedakan incoming vs current task)
    let showActionButtons: Bool
    
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
                .padding(.horizontal)
                
                // MAP VIEW (volunteer vs care receiver)
                VolunteerMapView(
                    volunteerCoordinate: viewModel.volunteerCoordinate,
                    careReceiverCoordinate: request.careReceiverCoordinate
                )
                .frame(height: 250)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Info jarak
                Text("Approx. distance: \(String(format: "%.1f", request.distanceKm)) km")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Distance & time
                HStack {
                    Label(
                        String(format: "%.1f km away", request.distanceKm),
                        systemImage: "location.fill"
                    )
                    Spacer()
                    Label(request.scheduledTime, systemImage: "clock.fill")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
                
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
                .padding(.horizontal)
                
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
                .padding(.horizontal)
                
                // Reward
                VStack(alignment: .leading, spacing: 6) {
                    Text("Offered Reward")
                        .font(.headline)
                    Text(request.offeredReward.asRupiah())
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "#387b38"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Spacer(minLength: 10)
                
                // ACTION BUTTONS (hanya kalau incoming request)
                if showActionButtons {
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
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .padding(.top, 16)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Request Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}


