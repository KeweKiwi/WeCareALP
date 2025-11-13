import SwiftUI
// palette sama seperti di atas…
struct StartView: View {
    var body: some View {
        NavigationStack {
            
                // semua item center horizontal, diatur vertikal dengan Spacer
                VStack(spacing: 28) {
                    Spacer(minLength: 0)
                    Image("WeCareLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    Text("Care made simple for your loved ones")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    VStack(spacing: 12) {
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Log In")
                                .bold()
                                .frame(maxWidth: .infinity)
                                 .padding(.vertical, 14)
                                .background(Brand.red)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Brand.red.opacity(0.3), radius: 8, y: 4)
                        }
                        NavigationLink {
                            RegisterView()
                        } label: {
                            Text("Register")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Brand.sky)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Brand.sky.opacity(0.3), radius: 8, y: 4)
                        }
                    }
                    .padding(.horizontal, 60)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            // biarkan navigation bar aktif supaya toolbar di LoginView bekerja
        }
    }
#Preview { StartView() }



