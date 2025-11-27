//
//  VolunteerDetailView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//

import SwiftUI
import MapKit

struct VolunteerDetailView: View {
    @StateObject var viewModel: VolunteerDetailVM

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // HEADER
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading) {
                        Text(viewModel.volunteer.name)
                            .font(.title.bold())

                        Text("Age: \(viewModel.volunteer.age)")
                        Text("Gender: \(viewModel.volunteer.gender)")

                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", viewModel.volunteer.rating))
                        }
                        .font(.subheadline)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                // MAP VIEW
                VolunteerMapView(
                    volunteerCoordinate: viewModel.volunteer.coordinate,
                    careReceiverCoordinate: viewModel.careReceiverLocation
                )
                .frame(height: 250)
                .cornerRadius(12)
                .padding(.horizontal)


                Text("Distance: \(viewModel.calculateDistanceKm())")
                    .foregroundColor(.gray)

                // SPECIALTY
                VStack(alignment: .leading, spacing: 10) {
                    Text("Specialty")
                        .font(.headline)

                    Text(viewModel.volunteer.specialty)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    Text("Restrictions / Notes")
                        .font(.headline)

                    Text(viewModel.volunteer.restrictions)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                NavigationLink(destination: VolunteerTaskAssignmentView(volunteer: viewModel.volunteer)) {
                    Text("Request Help")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#fdcb46"))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                .padding()
            }
        }
        .navigationTitle("Volunteer Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
