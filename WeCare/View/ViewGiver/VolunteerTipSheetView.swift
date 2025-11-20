//
//  TipSheetView.swift
//  WeCare
//
//  Created by student on 19/11/25.
//
import SwiftUI
struct TipSheetView: View {
    let volunteer: Volunteer
    @Binding var tipAmount: String
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Give a tip to \(volunteer.name)")
                    .font(.title2.bold())
                    .padding(.top)
                TextField("Enter tip amount ($)", text: $tipAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                Button(action: {
                    // Prototype tip confirmation
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Send Tip")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#fdcb46"))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .navigationTitle("Tip Volunteer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
//#Preview {
//    TipSheetView()
//}
