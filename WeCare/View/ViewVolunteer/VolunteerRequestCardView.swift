//
//  VolunteerRequestCardView.swift
//  WeCare
//
//  Created by student on 03/12/25.
//

import SwiftUI
import SwiftUI

struct VolunteerRequestCardView: View {
    let request: VolunteerRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("From \(request.caregiverName)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("For \(request.careReceiverName)")
                        .font(.headline)
                }
                Spacer()
                Text(request.offeredReward.asRupiah())
                    .font(.subheadline)
                    .padding(6)
                    .background(Color(hex: "#fdcb46").opacity(0.3))
                    .cornerRadius(8)
            }
            
            Text(request.taskDescription)
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(2)
            
            HStack {
                Label("\(request.distanceKm, specifier: "%.1f") km", systemImage: "location")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(request.scheduledTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}


