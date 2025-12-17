//
//  VolunteerModeRootView.swift
//  WeCare
//
//  Created by student on 03/12/25.
import Foundation
import SwiftUI

struct VolunteerModeRootView: View {
    @StateObject private var viewModel = VolunteerModeVM()
    
    var body: some View {
        NavigationStack {
            switch viewModel.registrationStatus {
            case .notRegistered:
                VolunteerRegistrationView(viewModel: viewModel)
            case .pendingApproval:
                VolunteerPendingApprovalView(viewModel: viewModel)
            case .approved:
                VolunteerHomeView(viewModel: viewModel)
            }
        }
    }
}

struct VolunteerHomeView: View {
    @ObservedObject var viewModel: VolunteerModeVM
    @State private var hasAppeared = false
    
    // Palette
    private let yellow = Color(hex: "#fdcb46")
    private let red = Color(hex: "#fa6255")
    private let green = Color(hex: "#a6d17d")
    private let skyBlue = Color(hex: "#91bef8")
    private let softBlue = Color(hex: "#e1c7ec")
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: Greeting Section
            if let profile = viewModel.profile {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(yellow)
                            .frame(width: 6, height: 28)
                            .scaleEffect(hasAppeared ? 1 : 0.5, anchor: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hello, \(profile.name)")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            Text("Thank you for volunteering to help other caregivers.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(x: hasAppeared ? 0 : -20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // STATUS CARD
            statusCard
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
            
            // CURRENT TASKS
            if !viewModel.currentTasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Tasks")
                        .font(.headline)
                        .padding(.leading, 4)
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.currentTasks.enumerated()), id: \.element.id) { index, task in
                            activeTaskSection(task)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: hasAppeared ? 0 : 30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: hasAppeared)
                        }
                    }
                }
            }
            
            incomingRequestsSection
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 20)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    VolunteerHistoryView(viewModel: viewModel)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("History")
                    }
                    .font(.subheadline)
                    .foregroundColor(skyBlue)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                hasAppeared = true
            }
        }
    }
    
    // MARK: STATUS CARD
    private var statusCard: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Volunteer Status")
                    .font(.headline)
                HStack(spacing: 6) {
                    Image(systemName: viewModel.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(viewModel.isAvailable ? green : red)
                        .scaleEffect(viewModel.isAvailable ? 1.1 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isAvailable)
                    Text(viewModel.isAvailable ? "Available to receive requests" : "Not available")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            Spacer()
            Toggle(isOn: $viewModel.isAvailable) {
                EmptyView()
            }
            .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(softBlue.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(skyBlue.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: ACTIVE TASK CARD
    private func activeTaskSection(_ task: VolunteerRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.careReceiverName)
                    .font(.headline)
                Spacer()
                NavigationLink {
                    VolunteerActiveTaskView(task: task, viewModel: viewModel)
                } label: {
                    Text("Open")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(green.opacity(0.2))
                        .foregroundColor(green)
                        .cornerRadius(8)
                }
                .buttonStyle(VolunteerScaleButtonStyle())
            }
            Text("\(task.distanceKm, specifier: "%.1f") km away")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(task.taskDescription)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(softBlue.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
    // MARK: INCOMING REQUESTS
    private var incomingRequestsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Incoming Requests")
                    .font(.headline)
                Spacer()
                if viewModel.incomingRequests.isEmpty {
                    Text("No new requests")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            if !viewModel.incomingRequests.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.incomingRequests.enumerated()), id: \.element.id) { index, request in
                            NavigationLink {
                                VolunteerRequestDetailView(
                                    request: request,
                                    viewModel: viewModel,
                                    showActionButtons: true
                                )
                            } label: {
                                VolunteerRequestCardView(request: request)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(skyBlue.opacity(0.4), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .opacity(hasAppeared ? 1 : 0)
                            .offset(x: hasAppeared ? 0 : -30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.08), value: hasAppeared)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Scale Button Style
struct VolunteerScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VolunteerModeRootView()
}

