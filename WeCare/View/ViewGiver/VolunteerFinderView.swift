//
//  VolunteerFinderView.swift
//  WeCare
//
//  Created by student on 19/11/25.
// INGAT: VIEW INI AKAN MUNCUL SETELAH DI DALAM KONTAINER DETAIL LANSIA KITA BISA MINTOL FIND VOLUNTEER
// yg masih kurang: tampilan maps, pas tampilan vidcall itu jgn force vidcall tp usahakan bisa kyk gojek bisa chat atau call sampe selese, tips di akhir
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
                                NavigationLink(destination: VolunteerDetailView(volunteer: volunteer)) {
                                    VolunteerCard(volunteer: volunteer)
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

