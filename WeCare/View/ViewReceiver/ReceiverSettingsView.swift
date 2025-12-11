import SwiftUI

struct ReceiverSettingsView: View {
    
    @ObservedObject var viewModel: ReceiverVM
    @State private var goToStart = false
    @State private var showLogoutPopup = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                Spacer().frame(height: 20)
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .foregroundColor(Color(hex: "#91bef8"))
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                
                Text(viewModel.currentUserName)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vision & Mission")
                        .font(.title2.bold())
                    
                    Text("""
This application is designed to support elderly individuals living independently by providing remote monitoring, care reminders, and continuous family support even when loved ones cannot always be physically present. Through this system, family members can stay connected and ensure the well-being, daily activities, and safety of their parents at all times.
""")
                        .foregroundColor(.black.opacity(0.7))
                        .font(.body)
                }
                .padding(20)
                .background(Color(hex: "#f2f7ff"))
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.06), radius: 5, y: 3)
                .padding(.horizontal)
                
                Spacer()
                
                NavigationLink(
                    destination: StartView().navigationBarBackButtonHidden(true),
                    isActive: $goToStart
                ) { EmptyView() }
                
                Button(action: {
                    showLogoutPopup = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title3)
                        Text("Sign Out")
                            .font(.title2.bold())
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .background(Color(.systemGray6).ignoresSafeArea())
        
        // POPUP
        .overlay(
            Group {
                if showLogoutPopup {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showLogoutPopup = false }
                    
                    VStack(spacing: 20) {
                        Image(systemName: "door.right.hand.open")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color(hex: "#f4b4b4"))
                        
                        Text("Oh no! You're leaving…")
                            .font(.title2.bold())
                        
                        Text("Are you sure?")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showLogoutPopup = false
                        }) {
                            Text("Naah, Just Kidding")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#91bef8"))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            showLogoutPopup = false
                            goToStart = true
                        }) {
                            Text("Yes, Log Me Out")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color(hex: "#91bef8"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#91bef8"), lineWidth: 2)
                                )
                        }
                    }
                    .padding(30)
                    .frame(width: 280)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
        )
        .onAppear {
            viewModel.fetchUserProfile(userId: 2)
        }
    }
}


#Preview {
    NavigationView {
        ReceiverSettingsView(viewModel: ReceiverVM())
    }
}
