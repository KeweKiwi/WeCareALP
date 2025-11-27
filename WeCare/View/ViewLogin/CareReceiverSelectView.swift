import SwiftUI

struct CareReceiverSelectView: View {
    let familyCode: String
    
    // 1. Connect the ViewModel (Make sure you use the updated 3-step ViewModel!)
    @StateObject private var vm = CareReceiverViewModel()
    
    // 2. State for selection
    @State private var selectedUser: Users?
    @State private var goDashboard: Bool = false
    
    var body: some View {
        ZStack {
            // Background color using the Helper Extension below
            Color(hex: "FFF9E6").ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // --- Family Code Header ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Family code")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.secondary)
                            Text(familyCode)
                                .font(.title2.monospaced())
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(radius: 4, y: 2)
                                )
                        }
                        
                        Text("Select your profile")
                            .font(.title2.weight(.semibold))
                        
                        // --- Loading / Error State ---
                        if vm.isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                Text("Finding family members...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                        } else if let error = vm.errorMessage {
                            Text("Error: \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if vm.members.isEmpty {
                            Text("No members found for this code.")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        
                        // --- User Cards ---
                        VStack(spacing: 20) {
                            ForEach(vm.members) { user in
                                Button {
                                    selectedUser = user
                                } label: {
                                    HStack(spacing: 18) {
                                        // Profile Initial
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: "91BEF8").opacity(0.25))
                                                .frame(width: 70, height: 70)
                                            
                                            // Safety check if name is empty
                                            Text(user.fullName.isEmpty ? "?" : String(user.fullName.prefix(1)))
                                                .font(.largeTitle.weight(.bold))
                                                .foregroundColor(.black)
                                        }
                                        
                                        // User Details
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(user.fullName)
                                                .font(.title3.weight(.semibold))
                                                .foregroundColor(.black)
                                            
                                            Text(user.gender)
                                                .font(.body)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    Capsule().fill(Color(hex: "E1C7EC").opacity(0.7))
                                                )
                                                .foregroundColor(.black)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(user.phoneNumber)
                                                    .font(.body)
                                                    .foregroundColor(.secondary)
                                                
                                                if let date = user.createdAt {
                                                    Text("Joined: \(date.formatted(date: .abbreviated, time: .omitted))")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        Spacer()
                                        
                                        // Checkmark Logic
                                        if selectedUser?.id == user.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(Color(hex: "A6D17D"))
                                        }
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .shadow(radius: 5, y: 3)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                
                // --- Navigation ---
                // Ensure ReceiverView and ReceiverVM exist in your project
                NavigationLink(
                    destination: ReceiverView(viewModel: ReceiverVM()),
                    isActive: $goDashboard
                ) {
                    EmptyView()
                }
                
                // --- Continue Button ---
                VStack(spacing: 12) {
                    Button {
                        if selectedUser != nil {
                            goDashboard = true
                        }
                    } label: {
                        Text("Continue")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(selectedUser == nil
                                          ? Color.gray.opacity(0.3)
                                          : Color(hex: "FA6255"))
                            )
                            .foregroundColor(selectedUser == nil ? .secondary : .white)
                    }
                    .disabled(selectedUser == nil)
                    
                    if selectedUser == nil {
                        Text("Please select a profile first")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Who are you?")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Fetch data when view appears
            vm.fetchMembers(familyCode: familyCode)
        }
    }
}



