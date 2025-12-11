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

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hello, \(profile.name)")
                                .font(.title3.bold())
                                .foregroundColor(.black)

                            Text("Thank you for volunteering to help other caregivers.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }


            // STATUS CARD
            statusCard

            // CURRENT TASKS
            if !viewModel.currentTasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Tasks")
                        .font(.headline)
                        .padding(.leading, 4)

                    VStack(spacing: 12) {
                        ForEach(viewModel.currentTasks) { task in
                            activeTaskSection(task)
                        }
                    }
                }
            }

            incomingRequestsSection

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
                        ForEach(viewModel.incomingRequests) { request in
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
                        }
                    }
                }
            }
        }
    }
}






#Preview {
    VolunteerModeRootView()
}


