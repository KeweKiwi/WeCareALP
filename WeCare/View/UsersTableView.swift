//
//  UsersTableView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//

import SwiftUI

struct UsersTableView: View {
    @StateObject private var vm = UsersTableViewModel(
        familyId: nil
    )
    
    var body: some View {
        NavigationStack {
            List {
                // Header
                Section {
                    HStack {
                        Text("User").bold().frame(maxWidth: .infinity, alignment: .leading)
                        Text("Role").bold().frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
               
                // Rows
                ForEach(vm.users) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        // Row 1 – Name + Role
                        HStack {
                            Text(user.fullName)
                                .font(.headline)
                            Spacer()
                            Text(user.role)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                       
                        // Row 2 – Email & Phone
                        HStack {
                            Text(user.email)
                                .font(.footnote)
                            Spacer()
                            Text(user.phoneNumber)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                       
                        // Row 3 – Gender Only
                        HStack(spacing: 8) {
                            Text("Gender: \(user.gender)")
                                .font(.footnote)
                        }
                       
                        // Row 4 – Created Date
                        if let created = user.createdAt {
                            Text("Created: \(created.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Users Table")
        }
    }
}
