//
//  GiverCalendarView.swift
//  WeCare
//
//  Created by student on 13/11/25.
//
import SwiftUI
struct GiverCalendarView: View {
    @StateObject var usersVM = UsersTableViewModel()
    @StateObject var vm = GiverCalendarVM()
    @StateObject var medicinesVM = MedicinesViewModel()
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color(hex: "#FFFFFF").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                    filterScroll
                    calendarCard
                    agendaCard
                }
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        }
        .sheet(isPresented: $vm.showingAddAgenda) {
            vmAddAgendaSheet
        }
        .alert("Add agenda on a past date?",
               isPresented: $vm.showPastDateAlert) {
            
            Button("Yes, Continue") {
                vm.confirmSavingPastAgenda()
            }
            
            Button("Cancel", role: .cancel) { }
            
        } message: {
            Text("You are adding an agenda on a date before today. Are you sure you want to continue?")
        }
        .sheet(item: $vm.selectedAgenda) { agenda in
            agendaDetailView(agenda)
        }
        .sheet(isPresented: $vm.showingEditAgenda) {
            vmEditAgendaSheet
        }
        .onReceive(usersVM.$users) { newUsers in
            vm.updateUsers(newUsers)
        }
        .onAppear {
            medicinesVM.fetchAllMedicines()
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    private var header: some View {
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
    }
    private var filterScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterButton(user: nil, label: "All")
                ForEach(vm.receiverUsers) { user in
                    filterButton(user: user, label: user.fullName)
                }
            }
            .padding(.horizontal)
        }
    }
    private func filterButton(user: Users?, label: String) -> some View {
        let isSelected = vm.selectedPerson?.userId == user?.userId

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                vm.selectedPerson = user
                vm.selectedUser = user
            }
        } label: {
            Text(label)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color(hex: "#b87cf5") : Color(hex: "#e1c7ec"))
                )
                .foregroundColor(.black)
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(ScaleButtonStyle())
    }


    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(vm.currentMonthName)
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        vm.currentMonthOffset -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.title3)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        vm.currentMonthOffset += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .font(.title3)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(1...vm.daysInMonth, id: \.self) { day in
                    let thisDate = vm.dateForDay(day)
                    let isSelected = Calendar.current.isDate(thisDate, inSameDayAs: vm.selectedDate)
                    VStack(spacing: 4) {
                        if Calendar.current.isDateInToday(thisDate) {
                            Text("Today")
                                .font(.caption2.bold())
                                .foregroundColor(Color(hex: "#fa6255"))
                        } else {
                            Text(" ")
                                .font(.caption2)
                        }
                        ZStack {
                            Circle()
                                .fill(vm.colorForDay(day))
                                .frame(width: 36, height: 36)
                            if isSelected {
                                Circle()
                                    .stroke(Color(hex: "#fdcb46"), lineWidth: 3)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color(hex: "#fdcb46").opacity(0.3), radius: 4, y: 2)
                                    .scaleEffect(isSelected ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                            }
                            if Calendar.current.isDateInToday(thisDate) {
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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.selectedDate = thisDate
                        }
                    }
                }
            }
            .padding(.horizontal)
            
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
    }
    
    private var agendaCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Agenda - \(formattedSelectedDate(vm.selectedDate))")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Button {
                    if vm.newAgendaOwner == nil {
                        vm.newAgendaOwner = vm.selectedPerson ?? vm.receiverUsers.first
                    }
                    vm.showingAddAgenda = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "#b87cf5"))
                        .font(.title2)
                }
                .buttonStyle(BounceButtonStyle())
            }
            if vm.currentAgenda.isEmpty {
                Text("No agenda for this date.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(vm.currentAgenda.enumerated()), id: \.element.id) { index, item in
                        Button {
                            vm.selectedAgenda = item
                        } label: {
                            let displayTitle =
                                item.medicineId != nil
                                ? "💊 \(item.medicineName ?? "Unknown Medicine")"
                                : item.title
                            let shownOwner =
                                vm.selectedPerson == nil
                                    ? item.receiverName
                                    : item.receiverName
                            agendaItem(title: displayTitle,
                                       time: item.time,
                                       status: item.status,
                                       owner: shownOwner,
                                       isCompleted: item.isCompleted
                            )
                        }
                        .buttonStyle(.plain)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05)),
                            removal: .scale.combined(with: .opacity).animation(.easeOut(duration: 0.2))
                        ))
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "#e1c7ec"))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)
        .padding(.horizontal)
    }
    
    private func legendColor(color: String, text: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(Color(hex: color)).frame(width: 10, height: 10)
            Text(text).font(.caption).foregroundColor(.gray)
        }
    }
    
    private func agendaItem(title: String, time: String, status: UrgencyStatus, owner: String, isCompleted: Bool = false) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(owner)
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "#b87cf5"))
                    if isCompleted {
                        Spacer(minLength: 6)
                        Text("Done")
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(10)
                            .foregroundColor(.green)
                    }
                }

                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(isCompleted ? .gray : .black)
                    .strikethrough(isCompleted, color: .gray)

                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Circle()
                .fill(color(for: status))
                .frame(width: 18, height: 18)
                .overlay(
                    Group {
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.caption2)
                                .foregroundColor(.white)
                        } else { EmptyView() }
                    }
                )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
    }

    private func color(for status: UrgencyStatus) -> Color {
        switch status {
        case .low: return Color(hex: "#a6d17d")
        case .medium: return Color(hex: "#91bef8")
        case .high: return Color(hex: "#fdcb46")
        case .critical: return Color(hex: "#fa6255")
        case .none: return Color.gray.opacity(0.15)
        }
    }
    
    private var vmAddAgendaSheet: some View {
        ZStack {
            Color(hex: "#FDFBF8").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") {
                        withAnimation(.easeOut(duration: 0.2)) {
                            vm.showingAddAgenda = false
                        }
                    }
                    .foregroundColor(Color(hex: "#fa6255"))
                    Spacer()
                    Text("Add Agenda")
                        .font(.headline.bold())
                    Spacer()
                    Button("Save") {
                        vm.saveNewAgenda()
                        withAnimation(.easeOut(duration: 0.2)) {
                            vm.showingAddAgenda = false
                        }
                    }
                    .foregroundColor(Color(hex: "#b87cf5"))
                    .disabled(
                        (vm.newAgendaType == .activity && vm.newAgendaTitle.isEmpty) ||
                        (vm.newAgendaType == .medicine && vm.selectedMedicine == nil)
                    )
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        sectionCard(title: "Agenda Type") {
                            Picker("Agenda Type", selection: $vm.newAgendaType) {
                                Text("Activity").tag(AgendaType.activity)
                                Text("Medicine").tag(AgendaType.medicine)
                            }
                            .pickerStyle(.segmented)
                            .background(Color(hex: "#fff9e6"))
                            .cornerRadius(10)
                        }
                        
                        sectionCard(title: "Agenda Details") {
                            VStack(spacing: 12) {
                                Group {
                                    if vm.newAgendaType == .medicine {
                                        Picker("Select Medicine", selection: $vm.selectedMedicine) {
                                            Text("Choose Medicine").tag(nil as Medicines?)
                                            ForEach(medicinesVM.medicines, id: \.self) { med in
                                                Text(med.medicineName).tag(Optional(med))
                                            }
                                        }
                                    } else {
                                        TextField("Activity Title", text: $vm.newAgendaTitle)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .animation(.easeInOut(duration: 0.3), value: vm.newAgendaType)
                                
                                Divider()
                                
                                TextField("Description (Optional)", text: $vm.newAgendaDescription)
                                    .padding(.horizontal, 10)
                                
                                Divider()
                                HStack {
                                    Text("Select Time")
                                    Spacer()
                                    DatePicker("", selection: $vm.newAgendaTimeDate, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        
                        sectionCard(title: "For Who") {
                            Picker("For", selection: $vm.newAgendaOwner) {
                                ForEach(vm.receiverUsers) { user in
                                    Text(user.fullName).tag(Optional(user))
                                }
                            }
                        }
                        
                        sectionCard(title: "Urgency Status") {
                            Picker("Status", selection: $vm.newAgendaStatus) {
                                Text("Low").tag(UrgencyStatus.low)
                                Text("Medium").tag(UrgencyStatus.medium)
                                Text("High").tag(UrgencyStatus.high)
                                Text("Critical").tag(UrgencyStatus.critical)
                            }
                            .pickerStyle(.segmented)
                            .background(Color(hex: "#fff9e6"))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.black)
                .padding(.leading, 10)
            
            VStack {
                content()
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
        }
    }
    
    private var vmEditAgendaSheet: some View {
        ZStack {
            Color(hex: "#FDFBF8").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") {
                        withAnimation(.easeOut(duration: 0.2)) {
                            vm.showingEditAgenda = false
                        }
                    }
                    .foregroundColor(Color(hex: "#fa6255"))
                    Spacer()
                    Text("Edit Agenda")
                        .font(.headline.bold())
                    Spacer()
                    Button("Save") {
                        vm.saveEditedAgenda()
                        withAnimation(.easeOut(duration: 0.2)) {
                            vm.showingEditAgenda = false
                        }
                    }
                    .foregroundColor(Color(hex: "#b87cf5"))
                    .disabled(vm.editAgendaTitle.isEmpty || vm.editAgendaOwner == nil)
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        sectionCard(title: "Agenda Details") {
                            VStack(spacing: 12) {
                                if vm.editAgendaType == .medicine {
                                    HStack {
                                        Text("Medicine")
                                            .font(.headline)
                                        Spacer()
                                        Text(vm.editAgendaTitle)
                                            .font(.body)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    .padding(.horizontal, 10)
                                } else {
                                    TextField("Title", text: $vm.editAgendaTitle)
                                        .padding(.horizontal, 10)
                                }
                                Divider()
                                TextField("Description (Optional)", text: $vm.editAgendaDescription)
                                    .padding(.horizontal, 10)
                                Divider()
                                HStack {
                                    Text("Select Time")
                                    Spacer()
                                    DatePicker("", selection: $vm.editAgendaTimeDate, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        
                        sectionCard(title: "For Who") {
                            Picker("For", selection: $vm.editAgendaOwner) {
                                ForEach(vm.receiverUsers) { user in
                                    Text(user.fullName).tag(Optional(user))
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                        
                        sectionCard(title: "Urgency Status") {
                            Picker("Status", selection: $vm.editAgendaStatus) {
                                Text("Low").tag(UrgencyStatus.low)
                                Text("Medium").tag(UrgencyStatus.medium)
                                Text("High").tag(UrgencyStatus.high)
                                Text("Critical").tag(UrgencyStatus.critical)
                            }
                            .pickerStyle(.segmented)
                            .background(Color(hex: "#fff9e6"))
                            .cornerRadius(10)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func agendaDetailView(_ agenda: AgendaItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = agenda.medicineImage,
                   let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 220)
                                .cornerRadius(16)
                                .shadow(radius: 6)
                                .padding(.bottom, 8)
                                .transition(.scale.combined(with: .opacity))
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 150)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.bottom, 8)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                if agenda.medicineId != nil {
                    Text("💊 \(agenda.medicineName ?? "Unknown Medicine")")
                        .font(.title2.bold())
                } else {
                    Text(agenda.title)
                        .font(.title2.bold())
                }
                
                if agenda.isCompleted {
                    Text("✅ Completed")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 6) {
                    Text("For")
                        .foregroundColor(.gray)
                    Text(agenda.receiverName)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#b87cf5"))
                }
                .font(.subheadline)

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
                
                Button {
                    vm.selectedAgenda = nil
                    vm.startEditing(agenda)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        vm.showingEditAgenda = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Edit Agenda").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#b87cf5").opacity(0.15))
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(role: .destructive) {
                    vm.deleteAgenda(agenda)
                    vm.selectedAgenda = nil
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Agenda").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
    }
    
    private func formattedSelectedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: date)
    }
}

// MARK: - Custom Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


#Preview {
    GiverCalendarView()
}
