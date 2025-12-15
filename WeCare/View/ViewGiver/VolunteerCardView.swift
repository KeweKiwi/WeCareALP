//
//  VolunteerCardView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import SwiftUI

struct VolunteerCardView: View {
    let volunteer: Volunteer
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "#fdcb46").opacity(0.22))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color(hex: "#fdcb46"))
            }
            .overlay(
                Circle().stroke(Color(.systemGray5), lineWidth: 1)
            )
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(volunteer.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    chip(icon: "star.fill",
                         iconColor: .yellow,
                         text: String(format: "%.1f", volunteer.rating))
                    
                    chip(icon: "location.fill",
                         iconColor: .secondary,
                         text: volunteer.distance)
                }
            }
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .compositingGroup() // ✅ bantu shadow render rapi
        .shadow(color: Color.black.opacity(0.10),
                radius: 6,
                x: 0,
                y: 4) // ✅ shadow lebih “turun” (atas tidak kepotong)
        .padding(.vertical, 4) // ✅ ruang napas buat shadow atas/bawah
    }
    
    // MARK: - Chip
    private func chip(icon: String, iconColor: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(iconColor)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}


