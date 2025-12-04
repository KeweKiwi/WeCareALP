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
    
    // ⬇️ REVISI: sekarang kirim tip + rating (1–5)
    var onSubmit: (_ tip: String?, _ rating: Int) -> Void   // rating 0 bisa diartikan "no rating"
    
    @State private var selectedPreset: Int? = nil
    @State private var customTip: String = ""
    
    // ⭐ NEW: state rating bintang
    @State private var rating: Int = 0   // 0 = belum pilih
    
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
                
                // ⭐ NEW: Rating bintang
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rate the help")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 6) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundColor(Color(hex: "#fdcb46"))
                                .onTapGesture {
                                    rating = index
                                }
                        }
                    }
                    
                    Text("Tap to rate from 1 to 5 stars.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // PRESET TIP BUTTONS (tetap seperti lama)
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
                
                // CUSTOM TIP (tetap seperti lama)
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
                        // ⬇️ FILTER: hanya boleh angka
                        .onChange(of: customTip) { newValue in
                            let filtered = newValue.digitsOnly
                            if filtered != newValue {
                                customTip = filtered
                            }
                        }

                    }
                    Text("Leave empty if you don't want to send a tip.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // ACTION BUTTONS (tetap ada dua, tapi sekarang kirim rating juga)
                VStack(spacing: 10) {
                    Button(action: {
                        let tipToSend = resolvedTip()
                        onSubmit(tipToSend, rating)   // ⬅️ kirim tip + rating
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
                    // opsional: rating wajib dulu baru bisa confirm
                    .disabled(rating == 0)
                    
                    Button(action: {
                        // Skip tip, tapi tetap selesai; rating bisa ikut (atau rating = 0)
                        onSubmit(nil, rating)        // ⬅️ tidak ada tip
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

extension String {
    /// Mengembalikan hanya karakter angka 0-9 dari string
    var digitsOnly: String {
        self.filter { $0.isNumber }
    }
}


