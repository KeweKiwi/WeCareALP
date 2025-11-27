import SwiftUI

struct ReceiverDashboardView: View {
    @StateObject var viewModel = ReceiverVM()
    
    private let stepGoal = 6000
    private let currentUserId = 2
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // --- Header ---
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundColor(Color(hex: "#91bef8"))
                        
                        VStack(alignment: .leading) {
                            Text("Good Morning!")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            // UPDATED: Show Name instead of ID
                            Text(viewModel.currentUserName)
                                .font(.largeTitle.bold())
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
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
                    
                    // --- Task & Steps Progress Card ---
                    TaskAndStepsProgressCard(
                        taskCompletionPercentage: viewModel.taskCompletionPercentage,
                        completedTasks: viewModel.tasks.filter { $0.isCompleted }.count,
                        totalTasks: viewModel.tasks.count,
                        currentSteps: viewModel.steps,
                        goalSteps: stepGoal
                    )
                    .padding(.horizontal)
                    
                    // --- Daily Tasks List ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("⏰ Daily Tasks")
                            .font(.title.bold())
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal)
                        
                        if viewModel.tasks.isEmpty {
                            Text("No tasks found.")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .padding(30)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.tasks) { task in
                                ReminderItem(task: task, viewModel: viewModel)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .background(Color(.systemGray6).ignoresSafeArea())
            .onAppear {
                // 1. Fetch User Profile (Name)
                viewModel.fetchUserProfile(userId: currentUserId)
                
                // 2. Fetch Tasks
                viewModel.fetchTasks(forReceiverId: currentUserId)
                
                // 3. Fetch Steps
                viewModel.fetchLatestSteps(forUserId: currentUserId)
            }
        }
    }
}

// MARK: - TaskAndStepsProgressCard
struct TaskAndStepsProgressCard: View {
    var taskCompletionPercentage: Int
    var completedTasks: Int
    var totalTasks: Int
    var currentSteps: Int
    var goalSteps: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                        .stroke(Color(hex: "#a6d17d").opacity(0.3), lineWidth: 10)
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: CGFloat(taskCompletionPercentage) / 100.0)
                        .stroke(Color(hex: "#a6d17d"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    Text("\(taskCompletionPercentage)%")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "#a6d17d"))
                }
            }
            Divider()
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
                Image(systemName: "figure.walk.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color(hex: "#91bef8"))
            }
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
        .padding(25)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
}

// MARK: - ReminderItem
struct ReminderItem: View {
    let task: Tasks
    @ObservedObject var viewModel: ReceiverVM
    
    var body: some View {
        HStack {
            Text(formatTime(task.dueTime))
                .font(.title2.bold())
                .foregroundColor(Color(hex: "#91bef8"))
                .frame(width: 90, alignment: .leading)
            
            Text(task.title)
                .font(.title2)
                .foregroundColor(task.isCompleted ? .gray : .black)
                .strikethrough(task.isCompleted, color: .gray)
            
            Spacer()
            
            Button(action: {
                viewModel.toggleTaskCompletion(task: task)
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
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    ReceiverDashboardView()
}
