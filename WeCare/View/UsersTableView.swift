//
//  UsersTableView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//

import SwiftUI

struct UsersTableView: View {
    @StateObject private var vm = UsersTableViewModel(
        familyId: nil   // atau "A1B2C3" kalau mau filter per keluarga
    )
    
    var body: some View {
        NavigationStack {
            List {
                // Header “tabel”
                Section {
                    HStack {
                        Text("User").bold().frame(maxWidth: .infinity, alignment: .leading)
                        Text("Role").bold().frame(maxWidth: .infinity, alignment: .leading)
                        Text("Admin").bold().frame(width: 60, alignment: .center)
                    }
                }
                
                // Rows
                ForEach(vm.users) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        // Baris 1 – nama + email
                        HStack {
                            Text(user.fullName)
                                .font(.headline)
                            Spacer()
                            Text(user.role)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Baris 2 – email & phone
                        HStack {
                            Text(user.email)
                                .font(.footnote)
                            Spacer()
                            Text(user.phoneNumber)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Baris 3 – gender + admin + family
                        HStack(spacing: 8) {
                            Text("Gender: \(user.gender)")
                                .font(.footnote)
                            Text("Family: \(user.familyId)")
                                .font(.footnote)
                            if user.isAdmin {
                                Text("ADMIN")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(6)
                            }
                        }
                        
                        // Baris 4 – created_at
                        if let created = user.createdAt {
                            Text("Created: \(created.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Baris 5 (opsional) – password hash & profile url (lebih ke debug)
                        /*
                        Text("password_hash: \(user.passwordHash)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Text("profile_image_url: \(user.profileImageURL)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        */
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Users Table")
        }
    }
}




