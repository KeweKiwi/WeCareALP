//
//  VolunteerDetailView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import SwiftUI
struct VolunteerDetailView: View {
    let volunteer: Volunteer
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.yellow)
                VStack(alignment: .leading) {
                    Text(volunteer.name)
                        .font(.title.bold())
                    Text("Age: \(volunteer.age)")
                        .font(.subheadline)
                    Text("Gender: \(volunteer.gender)")
                        .font(.subheadline)
                    
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", volunteer.rating))
                            .font(.subheadline)
                        Text(volunteer.distance)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Specialty")
                    .font(.headline)
                Text(volunteer.specialty)
                    .padding()
                    .background(Color(hex: "#e1c7ec"))
                    .cornerRadius(10)
                
                Text("Restrictions / Notes")
                    .font(.headline)
                Text(volunteer.restrictions)
                    .padding()
                    .background(Color(hex: "#e1c7ec"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
            
            NavigationLink(destination: TaskAssignmentView(volunteer: volunteer)) {
                Text("Request Help")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#fdcb46"))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .shadow(radius: 3)
            }
            .padding()
        }
        .navigationTitle("Volunteer Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
//#Preview {
//    VolunteerDetailView()
//}

