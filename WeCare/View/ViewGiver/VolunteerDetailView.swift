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
    
    @State private var hasAppeared = false
    @State private var starPulse = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                
                // HEADER CARD
                headerCard
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : -30)
                
                // MAP CARD
                mapCard
                    .padding(.horizontal)
                    .opacity(hasAppeared ? 1 : 0)
                    .scaleEffect(hasAppeared ? 1 : 0.92)
                
                // DETAILS CARDS
                VStack(spacing: 12) {
                    infoCard(
                        title: "Specialty",
                        icon: "sparkles",
                        text: viewModel.volunteer.specialty
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    
                    infoCard(
                        title: "Restrictions / Notes",
                        icon: "exclamationmark.triangle.fill",
                        text: viewModel.volunteer.restrictions
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : 30)
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
                .buttonStyle(PressScaleButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 18)
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Volunteer Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                hasAppeared = true
            }
            
            // Star pulse animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    starPulse = true
                }
            }
        }
    }
}

// MARK: - Subviews
private extension VolunteerDetailView {
    
    var headerCard: some View {
        HStack(spacing: 14) {
            // Animated avatar with subtle pulse
            ZStack {
                Circle()
                    .fill(Color(hex: "#fdcb46").opacity(0.15))
                    .frame(width: 84, height: 84)
                    .scaleEffect(hasAppeared ? 1 : 0.8)
                    .opacity(hasAppeared ? 0.4 : 0)
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 74, height: 74)
                    .foregroundColor(Color(hex: "#fdcb46"))
                    .scaleEffect(hasAppeared ? 1 : 0.7)
                    .rotationEffect(.degrees(hasAppeared ? 0 : -180))
            }
            
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
                            .scaleEffect(starPulse ? 1.15 : 1)
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

// MARK: - Button Style
struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

