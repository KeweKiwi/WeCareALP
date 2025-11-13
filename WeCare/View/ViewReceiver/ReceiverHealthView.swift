import SwiftUI
// MARK: - TAB 3: Health View (Vitals)
struct ReceiverHealthView: View {
    @ObservedObject var viewModel: ReceiverVM
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // Header
                    Text("❤️ Vital Health Check")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                    
                    // MARK: - CURRENT DATA CARDS
                    VStack(alignment: .leading, spacing: 15) {
                        Text("My Current Health")
                            .font(.title2.bold())
                            .foregroundColor(.gray)
                            .padding(.leading)
                        
                        // Grid of 2x3 cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            DashboardCard(title: "Heart Rate",
                                          value: "\(viewModel.heartRate) bpm",
                                          color: "#fa6255",
                                          icon: "heart.fill")
                            
                            DashboardCard(title: "Oxygen Sat.",
                                          value: String(format: "%.1f%%", viewModel.oxygenSaturation),
                                          color: "#91bef8",
                                          icon: "lungs.fill")
                            
                            DashboardCard(title: "Steps",
                                          value: "\(viewModel.steps)",
                                          color: "#a6d17d",
                                          icon: "figure.walk")
                            
                            DashboardCard(title: "Wrist Temp.",
                                          value: String(format: "%.1f°C", viewModel.wristTemperature),
                                          color: "#fdcb46",
                                          icon: "thermometer.medium")
                            
                            DashboardCard(title: "Sleep Quality",
                                          value: String(format: "%.1f hrs", viewModel.sleepDuration),
                                          color: "#e1c7ec",
                                          icon: "moon.zzz.fill")
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - HEALTH HISTORY (Optional Chart for Steps)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Last 7 Days Steps Trend")
                            .font(.title2.bold())
                            .foregroundColor(.gray)
                            .padding(.leading)
                        
                        HealthHistoryCard()
                            .padding(.horizontal)
                    }
                    
                    // MARK: - CALL TO ACTION BUTTON
                    Button(action: {
                        viewModel.updateHealthData()
                    }) {
                        Text("Update Latest Health Data")
                            .fontWeight(.bold)
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#fdcb46"))
                            .foregroundColor(.black)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.vertical, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}
// MARK: - Single Dashboard Card Component
struct DashboardCard: View {
    var title: String
    var value: String
    var color: String
    var icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Spacer()
            Text(value)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
        }
        .padding(20)
        .frame(minWidth: 0, maxWidth: .infinity, idealHeight: 150, alignment: .leading)
        .background(Color(hex: color))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}
// MARK: - Health History Card (Simple Bar Chart Simulation)
struct HealthHistoryCard: View {
    // Dummy data to simulate steps history
    let historyData: [Int] = [4200, 5000, 3800, 7020, 6100, 5500, 4800]
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Steps History (Past 7 Days)")
                .font(.headline)
                .foregroundColor(.black)
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(historyData.indices, id: \.self) { index in
                    let dataPoint = historyData[index]
                    let normalizedHeight = CGFloat(dataPoint) / 100 // simple scale for bar height
                    
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(dataPoint >= 5000 ? Color(hex: "#a6d17d") : Color(hex: "#fdcb46"))
                            .frame(width: 20, height: normalizedHeight)
                            .cornerRadius(4)
                        Text("Day \(index + 1)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(height: 100)
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(Color(hex: "#387b38"))
                Text("The chart shows steps data from the past 7 days.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
// MARK: - Preview (Tidak berubah)
#Preview {
    ReceiverHealthView(viewModel: ReceiverVM())
}

