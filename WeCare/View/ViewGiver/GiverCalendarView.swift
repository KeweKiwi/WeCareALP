import SwiftUI
// MARK: - Data Models
enum UrgencyStatus: String {
    case low, medium, high, critical, none
}
struct PersonCardViewData: Identifiable, Hashable {
    let id: UUID
    let name: String
    let role: String
    let avatarURL: URL?
    let heartRateText: String
    let status: UrgencyStatus
}
struct AgendaItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let time: String
    let status: UrgencyStatus
    let owner: String
}
enum SampleData {
    static let demoList: [PersonCardViewData] = [
        .init(id: .init(), name: "Grandma Siti", role: "Grandmother", avatarURL: nil, heartRateText: "76 bpm", status: .low),
        .init(id: .init(), name: "Grandpa Budi", role: "Grandfather", avatarURL: nil, heartRateText: "82 bpm", status: .high),
        .init(id: .init(), name: "Uncle Rudi", role: "Uncle", avatarURL: nil, heartRateText: "95 bpm", status: .critical),
        .init(id: .init(), name: "Aunt Lina", role: "Aunt", avatarURL: nil, heartRateText: "72 bpm", status: .medium)
    ]
}
// MARK: - Main View
struct GiverCalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var currentMonthOffset = 0
    @State private var selectedPerson: PersonCardViewData? = nil
    @State private var showingAddAgenda = false
    @State private var newAgendaTitle = ""
    @State private var newAgendaTime = ""
    @State private var newAgendaStatus: UrgencyStatus = .low
    @State private var newAgendaOwner: PersonCardViewData? = nil
    @State private var newAgendaTimeDate = Date()
    @State private var selectedAgenda: AgendaItem? = nil
    @State private var showingAgendaDetail = false
    @State private var newAgendaDescription = ""
    let persons = SampleData.demoList
    
    // Dummy health and agenda data
    let healthData: [String: [Int: UrgencyStatus]] = [
        "Grandma Siti": [1: .low, 2: .medium, 5: .high, 10: .critical, 15: .low],
        "Grandpa Budi": [3: .low, 6: .high, 9: .medium, 13: .critical],
        "Uncle Rudi": [4: .critical, 8: .medium, 11: .high, 20: .low],
    ]
    
    @State private var agendaData: [String: [String: [AgendaItem]]] = [
        "Grandma Siti": [
            "2025-11-13": [.init(title: "Check blood pressure", description: "testestes", time: "08:00 AM", status: .low, owner: "Grandma Siti")],
            "2025-11-14": [.init(title: "Take regular medication", description: "testestes", time: "10:00 AM", status: .medium, owner: "Grandma Siti")],
            "2025-11-5": [.init(title: "Doctor’s appointment", description: "testestes", time: "09:00 AM", status: .high, owner: "Grandma Siti")],
            "2025-11-10": [.init(title: "Lab test", description: "testestes", time: "01:00 PM", status: .critical, owner: "Grandma Siti")]
        ],
        "Grandpa Budi": [
            "2025-11-3": [.init(title: "Leg therapy", description: "testestes", time: "09:00 AM", status: .high, owner: "Grandpa Budi")],
            "2025-11-9": [.init(title: "Take vitamins", description: "testestes", time: "07:30 AM", status: .medium, owner: "Grandpa Budi")]
        ],
        "Uncle Rudi": [
            "2025-11-4": [.init(title: "Doctor consultation", description: "testestes", time: "02:00 PM", status: .critical, owner: "Uncle Rudi")],
            "2025-11-8": [.init(title: "Light exercise", description: "testestes", time: "07:00 AM", status: .medium, owner: "Uncle Rudi")]
        ],
        "Aunt Lina": [
            "2025-11-2": [.init(title: "Morning yoga", description: "testestes", time: "06:30 AM", status: .low, owner: "Aunt Lina")],
            "2025-11-21": [.init(title: "Medical check-up", description: "testestes", time: "10:00 AM", status: .critical, owner: "Aunt Lina")]
        ]
    ]
    
    var currentDate: Date {
        Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
    }
    
    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: currentDate)?.count ?? 30
    }
    
    var currentAgenda: [AgendaItem] {
        let key = dateKey(from: selectedDate)
        if let person = selectedPerson {
            return agendaData[person.name]?[key] ?? []
        } else {
            return persons.flatMap { agendaData[$0.name]?[key] ?? [] }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color(hex: "#FDFBF8").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // HEADER
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Calendar")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color(hex: "#fa6255"))
                        Text("Monitor family health schedules & activities")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // FILTER
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            filterButton(person: nil, label: "All")
                            ForEach(persons) { person in
                                filterButton(person: person, label: person.name)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // CALENDAR
                    VStack(spacing: 16) {
                        HStack {
                            Text(currentMonthName)
                                .font(.headline)
                            Spacer()
                            Button {
                                withAnimation { currentMonthOffset -= 1 }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                            }
                            Button {
                                withAnimation { currentMonthOffset += 1 }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                            ForEach(1...daysInMonth, id: \.self) { day in
                                let thisDate = Calendar.current.date(bySetting: .day, value: day, of: currentDate) ?? currentDate
                                let isSelected = Calendar.current.isDate(thisDate, inSameDayAs: selectedDate)
                                
                                VStack(spacing: 4) {
                                    if isToday(day) {
                                        Text("Today")
                                            .font(.caption2.bold())
                                            .foregroundColor(Color(hex: "#fa6255"))
                                    } else {
                                        Text(" ")
                                            .font(.caption2)
                                    }
                                    
                                    ZStack {
                                        // background status color
                                        Circle()
                                            .fill(colorForDay(day))
                                            .frame(width: 36, height: 36)
                                        
                                        // highlight ring yellow for selected date
                                        if isSelected {
                                            Circle()
                                                .stroke(Color(hex: "#fdcb46"), lineWidth: 3)
                                                .frame(width: 44, height: 44)
                                                .shadow(color: Color(hex: "#fdcb46").opacity(0.3), radius: 4, y: 2)
                                        }
                                        // today's ring
                                        if isToday(day) {
                                            Circle()
                                                .stroke(Color(hex: "#b87cf5"), lineWidth: 2.5)
                                                .frame(width: 40, height: 40)
                                        }
                                        Text("\(day)")
                                            .font(.callout.bold())
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(height: 55)
                                        .onTapGesture {
                                            selectedDate = thisDate
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // LEGEND
                        HStack(spacing: 16) {
                            legendColor(color: "#a6d17d", text: "Low")
                            legendColor(color: "#91bef8", text: "Medium")
                            legendColor(color: "#fdcb46", text: "High")
                            legendColor(color: "#fa6255", text: "Critical")
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 20)
                    .background(Color(hex: "#fff9e6"))
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)
                    .padding(.horizontal)
                    
                    // AGENDA
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Agenda - \(formattedSelectedDate())")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Button {
                                showingAddAgenda = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(hex: "#b87cf5"))
                                    .font(.title2)
                            }
                        }
                        if currentAgenda.isEmpty {
                            Text("No agenda for this date.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(currentAgenda) { item in
                                    Button {
                                        selectedAgenda = item
                                        showingAgendaDetail = true
                                    } label: {
                                        agendaItem(title: item.title, time: item.time, status: item.status, owner: item.owner)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#e1c7ec"))
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)
                    .padding(.horizontal)
                    .sheet(isPresented: $showingAddAgenda) {
                        addAgendaSheet
                    }
                    .sheet(item: $selectedAgenda) { agenda in
                        VStack(alignment: .leading, spacing: 16) {
                            Text(agenda.title)
                                .font(.title2.bold())
                            Text("By \(agenda.owner)")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#b87cf5"))
                            HStack {
                                Text("⏰ \(agenda.time)")
                                Spacer()
                                Text(agenda.status.rawValue.capitalized)
                                    .font(.subheadline.bold())
                                    .foregroundColor(color(for: agenda.status))
                            }
                            Divider()
                            Text(agenda.description.isEmpty ? "No description provided." : agenda.description)
                                .font(.body)
                                .padding(.top, 8)
                            
                            Spacer()
                        }
                        .padding()
                        .presentationDetents([.medium, .large])
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Helpers
    func formattedSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    func isToday(_ day: Int) -> Bool {
        let today = Date()
        let todayDay = Calendar.current.component(.day, from: today)
        let todayMonth = Calendar.current.component(.month, from: today)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        return todayDay == day && todayMonth == currentMonth
    }
    
    func filterButton(person: PersonCardViewData?, label: String) -> some View {
        let isSelected = selectedPerson?.id == person?.id
        return Button(action: {
            selectedPerson = person
        }) {
            Text(label)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color(hex: "#b87cf5") : Color(hex: "#e1c7ec"))
                )
                .foregroundColor(.black)
        }
    }
    
    func colorForDay(_ day: Int) -> Color {
        var combinedStatuses: [UrgencyStatus] = []
        let key = dateKey(forDay: day, in: currentDate)
            if let person = selectedPerson {
                // Get status from health data and agenda data for selected person
                if let healthStatus = healthData[person.name]?[day] {
                    combinedStatuses.append(healthStatus)
                }
                if let agendas = agendaData[person.name]?[key] {
                    combinedStatuses.append(contentsOf: agendas.map { $0.status })
                }
            } else {
                // For "All" view, gather statuses from all people
                for person in persons {
                    if let healthStatus = healthData[person.name]?[day] {
                        combinedStatuses.append(healthStatus)
                    }
                    if let agendas = agendaData[person.name]?[key] {
                        combinedStatuses.append(contentsOf: agendas.map { $0.status })
                    }
                }
            }
            // Determine color priority
            if combinedStatuses.contains(.critical) { return Color(hex: "#fa6255") }
            if combinedStatuses.contains(.high) { return Color(hex: "#fdcb46") }
            if combinedStatuses.contains(.medium) { return Color(hex: "#91bef8") }
            if combinedStatuses.contains(.low) { return Color(hex: "#a6d17d") }
            return Color.gray.opacity(0.15)
    }
    
    func color(for status: UrgencyStatus) -> Color {
        switch status {
        case .low: return Color(hex: "#a6d17d")
        case .high: return Color(hex: "#fdcb46")
        case .critical: return Color(hex: "#fa6255")
        case .medium: return Color(hex: "#91bef8")
        case .none: return Color.gray.opacity(0.15)
        }
    }
    
    func legendColor(color: String, text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 10, height: 10)
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    func agendaItem(title: String, time: String, status: UrgencyStatus, owner: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(owner)
                    .font(.caption.bold())
                    .foregroundColor(Color(hex: "#b87cf5"))
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.black)
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Circle()
                .fill(color(for: status))
                .frame(width: 18, height: 18)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
    }
    
    func saveNewAgenda() {
        guard let owner = newAgendaOwner else { return }
//        let day = Calendar.current.component(.day, from: selectedDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: newAgendaTimeDate)
        let newItem = AgendaItem(
            title: newAgendaTitle,
            description: newAgendaDescription,
            time: timeString,
            status: newAgendaStatus,
            owner: owner.name
        )
        let key = dateKey(from: selectedDate)
        var personAgendas = agendaData[owner.name] ?? [:]
        var agendasForDay = personAgendas[key] ?? []
        agendasForDay.append(newItem)
        personAgendas[key] = agendasForDay
        agendaData[owner.name] = personAgendas
        // Reset fields
        newAgendaTitle = ""
        newAgendaDescription = ""
        newAgendaOwner = nil
        newAgendaStatus = .low
        newAgendaTimeDate = Date()
    }
    @ViewBuilder
    var addAgendaSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Agenda Details")) {
                    TextField("Title", text: $newAgendaTitle)
                    TextField("Description", text: $newAgendaDescription)
                    DatePicker("Select Time", selection: $newAgendaTimeDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                }
                Section(header: Text("For Who")) {
                    Picker("Select Person", selection: $newAgendaOwner) {
                        ForEach(persons) { person in
                            Text(person.name).tag(Optional(person))
                        }
                    }
                }
                Section(header: Text("Urgency Status")) {
                    Picker("Health Status", selection: $newAgendaStatus) {
                        Text("Low").tag(UrgencyStatus.low)
                        Text("Medium").tag(UrgencyStatus.medium)
                        Text("High").tag(UrgencyStatus.high)
                        Text("Critical").tag(UrgencyStatus.critical)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Add Agenda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNewAgenda()
                        showingAddAgenda = false
                    }
                    .disabled(newAgendaTitle.isEmpty || newAgendaOwner == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddAgenda = false
                    }
                }
            }
        }
    }
}

// MARK: - Color Extension
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default: (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
//    }
//}


//DATEKEY supaya agenda update di tanggal itu aja, bulan lain ga ikut keganti
func dateKey(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
func dateKey(forDay day: Int, in baseDate: Date) -> String {
    var components = Calendar.current.dateComponents([.year, .month], from: baseDate)
    components.day = day
    let date = Calendar.current.date(from: components) ?? baseDate
    return dateKey(from: date)
}
#Preview {
    GiverCalendarView()
}

