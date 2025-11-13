import SwiftUI
// MARK: - Dashboard View (Revisi: Latar Belakang & Progres Lingkaran Tugas)
struct ReceiverDashboardView: View {
    @ObservedObject var viewModel: ReceiverVM
    private let stepGoal = 6000 // Target langkah
    
    // Hitung progress langkah
    private var stepProgressPercentage: Int {
        min(Int(Double(viewModel.steps) / Double(stepGoal) * 100), 100)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) { // Spasi antara elemen
                    
                    // Header (tetap sama)
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundColor(Color(hex: "#91bef8"))
                        
                        VStack(alignment: .leading) {
                            Text("Good Morning!")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Text("Mr/Ms") // Ganti dengan nama
                                .font(.largeTitle.bold())
                        }
                        
                        Spacer()
                        
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(Color(hex: "#91bef8"))
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal)
                    
                    // BARU: Task & Steps Progress Card (Menggantikan DailyOverviewCard)
                    // Sekarang berisi progres lingkaran untuk tugas DAN progres langkah.
                    TaskAndStepsProgressCard(
                        taskCompletionPercentage: viewModel.taskCompletionPercentage,
                        completedTasks: viewModel.tasks.filter { $0.isCompleted }.count,
                        totalTasks: viewModel.tasks.count,
                        currentSteps: viewModel.steps,
                        goalSteps: stepGoal
                    )
                    .padding(.horizontal)
                    
                    // Daftar Tugas Harian (tetap sama)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⏰ Daily Tasks")
                            .font(.title.bold())
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal)
                        
                        if viewModel.tasks.isEmpty {
                            Text("No tasks for today.")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .padding(30)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        } else {
                            ForEach($viewModel.tasks) { $task in
                                ReminderItem(task: $task, viewModel: viewModel)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .background(Color(.systemGray6).ignoresSafeArea()) // Kembali ke latar belakang default systemGray6
        }
    }
}
// MARK: - Komponen Baru: Task & Steps Progress Card (Gabungan)
struct TaskAndStepsProgressCard: View {
    var taskCompletionPercentage: Int
    var completedTasks: Int
    var totalTasks: Int
    var currentSteps: Int
    var goalSteps: Int
    
    private var stepProgressPercentage: Int {
        min(Int(Double(currentSteps) / Double(goalSteps) * 100), 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // Spasi lebih besar di dalam kartu
            
            // Progres Tugas dengan Lingkaran
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Tasks Completed")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("\(completedTasks) of \(totalTasks)")
                        .font(.title2.bold())
                        .foregroundColor(.black.opacity(0.8))
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#a6d17d").opacity(0.3), lineWidth: 10) // Lebih tebal
                        .frame(width: 80, height: 80) // Lebih besar
                    Circle()
                        .trim(from: 0, to: CGFloat(taskCompletionPercentage) / 100.0)
                        .stroke(Color(hex: "#a6d17d"), style: StrokeStyle(lineWidth: 10, lineCap: .round)) // Lebih tebal
                        .frame(width: 80, height: 80) // Lebih besar
                        .rotationEffect(.degrees(-90))
                    Text("\(taskCompletionPercentage)%")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "#a6d17d"))
                }
            }
            
            Divider()
            
            // Progres Langkah (Sederhana, teks saja)
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Daily Steps")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("\(currentSteps) / \(goalSteps) steps")
                        .font(.title2.bold())
                        .foregroundColor(.black.opacity(0.8))
                }
                Spacer()
                Image(systemName: "figure.walk.circle.fill") // Ikon lebih besar dan berwarna
                    .font(.largeTitle)
                    .foregroundColor(Color(hex: "#91bef8"))
            }
            
            // Pesan motivator
            if taskCompletionPercentage < 100 {
                Divider()
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "#fdcb46"))
                        .font(.title2)
                    Text("Keep striving! You have pending goals.")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.7))
                }
            } else {
                Divider()
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#a6d17d"))
                        .font(.title2)
                    Text("All goals for today are complete! 👍")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "#a6d17d"))
                }
            }
        }
        .padding(25) // Padding lebih besar
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
}
// MARK: - Komponen Reminder (tetap sama, sudah bagus)
struct ReminderItem: View {
    @Binding var task: TaskItem
    @ObservedObject var viewModel: ReceiverVM
    
    var body: some View {
        HStack {
            Text(task.time)
                .font(.title2.bold())
                .foregroundColor(Color(hex: "#91bef8"))
                .frame(width: 90, alignment: .leading)
            
            Text(task.title)
                .font(.title2)
                .foregroundColor(task.isCompleted ? .gray : .black)
                .strikethrough(task.isCompleted, color: .gray)
            
            Spacer()
            
            Button(action: {
                viewModel.toggleTaskCompletion(for: task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.largeTitle)
                    .foregroundColor(task.isCompleted ? Color(hex: "#a6d17d") : .gray.opacity(0.5))
                    .padding(10)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}
// MARK: - Preview
#Preview {
    ReceiverDashboardView(viewModel: ReceiverVM())
}

