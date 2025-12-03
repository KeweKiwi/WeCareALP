//
//  VolunteerModeRootView.swift
//  WeCare
//
//  Created by student on 03/12/25.
// yg kur

import Foundation
import SwiftUI

struct VolunteerModeRootView: View {
    @StateObject private var viewModel = VolunteerModeVM()
    
    var body: some View {
        NavigationStack {
            VolunteerHomeView(viewModel: viewModel)
        }
    }
}

struct VolunteerHomeView: View {
    @ObservedObject var viewModel: VolunteerModeVM
    
    var body: some View {
        VStack(spacing: 16) {
            statusCard
            
            if let active = viewModel.activeTask {
                activeTaskSection(active)
            }
            
            incomingRequestsSection
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Volunteer Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    
    private var statusCard: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Volunteer Status")
                    .font(.headline)
                Text(viewModel.isAvailable ? "Available to receive requests" : "Not available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle(isOn: $viewModel.isAvailable) {
                Text("")
            }
            .labelsHidden()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
    
    private func activeTaskSection(_ task: VolunteerRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Current Task")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    VolunteerActiveTaskView(task: task)
                } label: {
                    Text("Open")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#387b38"))
                }
            }
            
            Text("\(task.careReceiverName) • \(task.distanceKm, specifier: "%.1f") km away")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(task.taskDescription)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
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
                                    viewModel: viewModel
                                )
                            } label: {
                                VolunteerRequestCardView(request: request)
                            }
                            .buttonStyle(PlainButtonStyle())
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

