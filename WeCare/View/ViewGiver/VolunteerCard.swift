//
//  VolunteerCard.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import SwiftUI
struct VolunteerCard: View {
    let volunteer: Volunteer
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 55, height: 55)
                .foregroundColor(Color(hex: "#a6d17d"))
            VStack(alignment: .leading) {
                Text(volunteer.name)
                    .font(.headline)
                    .foregroundColor(.black)
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", volunteer.rating))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("• \(volunteer.distance)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
//#Preview {
//    VolunteerCard()
//}

