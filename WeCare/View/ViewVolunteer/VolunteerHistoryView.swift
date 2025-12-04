//
//  VolunteerHistoryView.swift
//  WeCare
//
//  Created by student on 04/12/25.
//

import SwiftUI

struct VolunteerHistoryView: View {
    @ObservedObject var viewModel: VolunteerModeVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.historyTasks.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No completed tasks yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.historyTasks) { item in
                            historyCard(item)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func historyCard(_ item: CompletedVolunteerTask) -> some View {
        let task = item.originalRequest
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.careReceiverName)
                        .font(.headline)
                    Text("Caregiver: \(task.caregiverName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(formatDate(item.completedAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(task.taskDescription)
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(2)
            
            HStack(spacing: 12) {
                if let tip = item.tipAmount {
                    Text("Tip: \(tip.asRupiah())")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#387b38"))
                } else {
                    Text("Tip: -")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let rating = item.rating {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.caption2)
                        }
                    }
                    .foregroundColor(Color(hex: "#fdcb46"))
                } else {
                    Text("No rating")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



