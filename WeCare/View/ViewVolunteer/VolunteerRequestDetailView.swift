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
    
    let showActionButtons: Bool
    
    @State private var hasAppeared = false
    @State private var pulseReward = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                
                headerCard
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : -20)
                
                mapCard
                    .padding(.horizontal)
                    .opacity(hasAppeared ? 1 : 0)
                    .scaleEffect(hasAppeared ? 1 : 0.95)
                
                metaRow
                    .padding(.horizontal)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                
                taskCard
                    .padding(.horizontal)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                
                locationCard
                    .padding(.horizontal)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                
                rewardCard
                    .padding(.horizontal)
                    .opacity(hasAppeared ? 1 : 0)
                    .scaleEffect(pulseReward ? 1.02 : 1)
                    .offset(y: hasAppeared ? 0 : 20)
                
                if showActionButtons {
                    actionButtons
                        .padding(.horizontal)
                        .padding(.top, 2)
                        .padding(.bottom, 14)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 30)
                } else {
                    Spacer(minLength: 14)
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Request Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                hasAppeared = true
            }
            
            // Subtle pulse animation for reward card
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseReward = true
                }
            }
        }
    }
}

// MARK: - Subviews
private extension VolunteerRequestDetailView {
    
    var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Request from \(request.caregiverName)")
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            Text("For: \(request.careReceiverName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Request Detail Information")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(999)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 4, y: 2)
    }
    
    var mapCard: some View {
        VolunteerMapView(
            volunteerCoordinate: viewModel.volunteerCoordinate,
            careReceiverCoordinate: request.careReceiverCoordinate
        )
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    var metaRow: some View {
        HStack(spacing: 10) {
            Label(String(format: "%.1f km away", request.distanceKm), systemImage: "location.fill")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            Spacer()
            
            Label(request.scheduledTime, systemImage: "clock.fill")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
    
    var taskCard: some View {
        infoCard(
            title: "Task Description",
            icon: "list.bullet.rectangle.portrait",
            text: request.taskDescription
        )
    }
    
    var locationCard: some View {
        infoCard(
            title: "Location Note",
            icon: "mappin.and.ellipse",
            text: request.locationNote
        )
    }
    
    var rewardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .foregroundColor(Color(hex: "#387b38"))
                Text("Offered Reward")
                    .font(.headline)
                Spacer()
            }
            
            Text(request.offeredReward.asRupiah())
                .font(.title3.bold())
                .foregroundColor(Color(hex: "#387b38"))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background)
        .cornerRadius(16)
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.accept(request)
                dismiss()
            } label: {
                Text("Accept Request")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#a6d17d"))
                    .foregroundColor(.black)
                    .cornerRadius(16)
                    .shadow(radius: 3, y: 2)
            }
            .buttonStyle(BounceButtonStyle1())
            
            Button {
                viewModel.decline(request)
                dismiss()
            } label: {
                Text("Decline")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(Color(hex: "#fa6255"))
                    .background(.background)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#fa6255"), lineWidth: 1)
                    )
            }
            .buttonStyle(ScaleButtonStyle1())
        }
        .padding(14)
        .background(.background)
        .cornerRadius(16)
        .shadow(radius: 4, y: 2)
    }
}

// MARK: - Button Styles
struct BounceButtonStyle1: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle1: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

