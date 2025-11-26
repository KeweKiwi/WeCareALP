//
//  VolunteerCompletionTipView.swift
//  WeCare
//
//  Created by student on 26/11/25.
//


import SwiftUI

struct VolunteerCompletionTipView: View {
    let volunteer: Volunteer
    @Binding var isPresented: Bool
    var onSubmit: (String?) -> Void   // nil = no tip
    
    @State private var selectedPreset: Int? = nil
    @State private var customTip: String = ""
    
    // contoh preset tip
    private let presets: [Int] = [20000, 50000, 100000]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Thank \(volunteer.name)?")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("The task is completed. You can send an optional tip as appreciation.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // PRESET TIP BUTTONS
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Tip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 10) {
                        ForEach(presets.indices, id: \.self) { index in
                            let amount = presets[index]
                            Button(action: {
                                selectedPreset = index
                                customTip = ""
                            }) {
                                Text("Rp \(formatAmount(amount))")
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        selectedPreset == index
                                        ? Color(hex: "#fdcb46")
                                        : Color(.systemGray6)
                                    )
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // CUSTOM TIP
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Tip")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("Rp")
                            .foregroundColor(.gray)
                        
                        TextField("Enter amount", text: $customTip)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Text("Leave empty if you don't want to send a tip.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // ACTION BUTTONS
                VStack(spacing: 10) {
                    Button(action: {
                        let tipToSend = resolvedTip()
                        onSubmit(tipToSend)
                        isPresented = false
                    }) {
                        Text("Confirm & Finish")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#a6d17d"))
                            .foregroundColor(.black)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                    }
                    
                    Button(action: {
                        // Skip tip, but still mark as done
                        onSubmit(nil)
                        isPresented = false
                    }) {
                        Text("Skip Tip")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color(hex: "#fa6255"))
                    }
                }
            }
            .padding()
            .navigationTitle("Task Completed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func resolvedTip() -> String? {
        if !customTip.trimmingCharacters(in: .whitespaces).isEmpty {
            return customTip
        }
        if let index = selectedPreset {
            return String(presets[index])
        }
        return nil
    }
    
    private func formatAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}


