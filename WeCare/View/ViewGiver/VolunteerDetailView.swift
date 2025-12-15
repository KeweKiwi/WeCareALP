//
//  VolunteerDetailView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//

import SwiftUI
import MapKit

struct VolunteerDetailView: View {
    @StateObject var viewModel: VolunteerDetailVM
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                
                // HEADER CARD
                headerCard
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // MAP CARD
                mapCard
                    .padding(.horizontal)
                
                // DETAILS CARDS
                VStack(spacing: 12) {
                    infoCard(
                        title: "Specialty",
                        icon: "sparkles",
                        text: viewModel.volunteer.specialty
                    )
                    
                    infoCard(
                        title: "Restrictions / Notes",
                        icon: "exclamationmark.triangle.fill",
                        text: viewModel.volunteer.restrictions
                    )
                }
                .padding(.horizontal)
                
                // CTA BUTTON
                NavigationLink(destination: VolunteerTaskAssignmentView(volunteer: viewModel.volunteer)) {
                    Text("Request Help")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#fdcb46"))
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .shadow(radius: 3, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 18)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Volunteer Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension VolunteerDetailView {
    
    var headerCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 74, height: 74)
                .foregroundColor(Color(hex: "#fdcb46"))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.volunteer.name)
                    .font(.title3.bold())
                    .lineLimit(1)
                
                HStack(spacing: 10) {
                    Label("Age \(viewModel.volunteer.age)", systemImage: "calendar")
                    Label(viewModel.volunteer.gender, systemImage: "person.fill")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", viewModel.volunteer.rating))
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(999)
                    
                    Spacer()
                    
                    Text("Distance: \(viewModel.calculateDistanceKm())")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(999)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 4, y: 2)
    }
    
    var mapCard: some View {
        VolunteerMapView(
            volunteerCoordinate: viewModel.volunteer.coordinate,
            careReceiverCoordinate: viewModel.careReceiverLocation
        )
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    func infoCard(title: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            Text(text.isEmpty ? "-" : text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(.background)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}


