//
//  VolunteerFinderView.swift
//  WeCare
//
//  Created by student on 19/11/25.
// INGAT: VIEW INI AKAN MUNCUL SETELAH DI DALAM KONTAINER DETAIL LANSIA KITA BISA MINTOL FIND VOLUNTEER
// yg masih kurang:  pov sebegai pengaju menjadi volunteer
// yg dilakukan saat ada database / diakhir2: tampilan maps itu jaraknya harus sama dengan person card. Selesai kasih tip lgsg navigate ke halaman utama

import SwiftUI
struct VolunteerFinderView: View {
    @StateObject private var viewModel = VolunteerFinderVM()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("Find a Volunteer")
                    .font(.largeTitle.bold())
                    .padding(.top)
                
                Text(viewModel.isSearching ? "Searching for volunteers nearby..." : "Volunteers found")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                // Search Animation
                if viewModel.isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#387b38")))
                        .scaleEffect(2)
                        .padding()
                }
                // Volunteer List
                if !viewModel.isSearching {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(viewModel.volunteers) { volunteer in
                                NavigationLink(
                                    destination: VolunteerDetailView(viewModel: VolunteerDetailVM(volunteer: volunteer))
                                ) {
                                    VolunteerCardView(volunteer: volunteer)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .navigationTitle("Volunteer Finder")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.startSearching()
            }
        }
    }
}
#Preview {
    VolunteerFinderView()
}

