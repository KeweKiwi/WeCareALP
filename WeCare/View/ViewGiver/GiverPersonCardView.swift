////
////  PersonCard.swift
////  wecare kevin
////
////  Created by student on 05/11/25.
////
//import SwiftUI
//struct PersonCard: View {
//    let data: PersonCardViewData
//    var onInfo: () -> Void
//    var onLocation: () -> Void
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            // Top row (Avatar + name + role + status)
//            HStack(alignment: .top, spacing: 12) {
//                GiverAvatarView(url: data.avatarURL)
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(data.name)
//                        .font(.headline)
//                        .foregroundStyle(Color.blue)
//                    Text(data.role)
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                }
//                Spacer()
//                StatusDot(status: data.status)
//            }
//            
//            // Vital summaries (heart rate + steps)
//            HStack(spacing: 20) {
//                // ❤️ heart rate
//                HStack(spacing: 6) {
//                    Image(systemName: "heart.fill")
//                        .foregroundStyle(.red)
//                        .font(.subheadline)
//                    Text(data.heartRateText ?? "- bpm")
//                        .font(.subheadline)
//                }
//                // 👟 steps
//                if let steps = data.steps {
//                    HStack(spacing: 6) {
//                        Image(systemName: "figure.walk")
//                            .foregroundStyle(.green)
//                            .font(.subheadline)
//                        Text("\(steps) steps")
//                            .font(.subheadline)
//                    }
//                }
//            }
//            HStack(spacing: 10) {
//                            Button("Info", action: onInfo)
//                                .buttonStyle(.borderedProminent)
//                                .tint(GiverColorPaletteView.skyBlue)
//                                .font(.subheadline)
//                            Spacer()
//                            GiverIconButtonCircleView(systemName: "location.fill")
//                                .onTapGesture(perform: onLocation)   // ✅ ganti jadi location
//                            GiverIconButtonCircleView(systemName: "info.circle")
//                        }
//                    }
//                    .padding(14)
//                    .background(
//                        RoundedRectangle(cornerRadius: 18)
//                            .fill(GiverColorPaletteView.lilac.opacity(0.4))
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 18)
//                            .stroke(GiverColorPaletteView.skyBlue, lineWidth: 2)
//                    )
//                    .shadow(radius: 6, y: 3)
//                }
//            }
//
