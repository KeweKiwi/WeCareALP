//
//  GiverCalendarView.swift
//  WeCare
//
//  Created by student on 13/11/25.
//

import SwiftUI

struct GiverCalendarView: View {
    @StateObject var usersVM = UsersTableViewModel(familyId: 1)
    @StateObject var vm = GiverCalendarVM()
    
    var body: some View {
        ZStack {
            Color(hex: "#FDFBF8").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                    filterScroll
                    calendarCard
                    agendaCard
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $vm.showingAddAgenda) {
            vmAddAgendaSheet
        }
        .sheet(item: $vm.selectedAgenda) { agenda in
            agendaDetailView(agenda)
        }
        .sheet(isPresented: $vm.showingEditAgenda) {
            vmEditAgendaSheet
        }
        .onChange(of: usersVM.users) { newUsers in
            vm.updateUsers(newUsers)
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
                ForEach(vm.users) { user in
                    filterButton(user: user, label: user.fullName)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func filterButton(user: Users?, label: String) -> some View {
        let isSelected = vm.selectedUser?.id == user?.id

        return Button {
            vm.selectedUser = user
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
        }
    }

    
    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(vm.currentMonthName)
                    .font(.headline)
                Spacer()
                Button { withAnimation { vm.currentMonthOffset -= 1 } } label: { Image(systemName: "chevron.left").foregroundColor(.black) }
                Button { withAnimation { vm.currentMonthOffset += 1 } } label: { Image(systemName: "chevron.right").foregroundColor(.black) }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(1...vm.daysInMonth, id: \.self) { day in
                    let thisDate = Calendar.current.date(bySetting: .day, value: day, of: vm.currentDate) ?? vm.currentDate
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
                        vm.selectedDate = thisDate
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
                    vm.showingAddAgenda = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "#b87cf5"))
                        .font(.title2)
                }
            }
            
            if vm.currentAgenda.isEmpty {
                Text("No agenda for this date.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 12) {
                    ForEach(vm.currentAgenda) { item in
                        Button {
                            vm.selectedAgenda = item
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
    }
    
    private func legendColor(color: String, text: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(Color(hex: color)).frame(width: 10, height: 10)
            Text(text).font(.caption).foregroundColor(.gray)
        }
    }
    
    private func agendaItem(title: String, time: String, status: UrgencyStatus, owner: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(owner).font(.caption.bold()).foregroundColor(Color(hex: "#b87cf5"))
                Text(title).font(.subheadline.bold()).foregroundColor(.black)
                Text(time).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            Circle().fill(color(for: status)).frame(width: 18, height: 18)
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
        NavigationView {
            Form {
                // -------------------------
                // AGENDA TYPE PICKER
                // -------------------------
                Section(header: Text("Agenda Type")) {
                    Picker("Agenda Type", selection: $vm.newAgendaType) {
                        Text("Activity").tag(AgendaType.activity)
                        Text("Medicine").tag(AgendaType.medicine)
                    }
                    .pickerStyle(.segmented)
                }

                // -------------------------
                // FORM FIELDS (dynamic)
                // -------------------------
                Section(header: Text("Agenda Details")) {

                    // Title field changes depending on type
                    if vm.newAgendaType == .medicine {
                        TextField("Medicine Name", text: $vm.newAgendaTitle)
                    } else {
                        TextField("Activity Title", text: $vm.newAgendaTitle)
                    }

                    TextField("Description", text: $vm.newAgendaDescription)

                    DatePicker("Select Time",
                               selection: $vm.newAgendaTimeDate,
                               displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                }

                // -------------------------
                // OWNER
                // -------------------------
                Section(header: Text("For Who")) {
                    Picker("Select Person", selection: $vm.newAgendaOwner) {
                        Text("Choose Person").tag(nil as Users?)
                        ForEach(vm.users) { user in
                            Text(user.fullName).tag(Optional(user))
                        }
                    }
                }

                // -------------------------
                // URGENCY
                // -------------------------
                Section(header: Text("Urgency Status")) {
                    Picker("Status", selection: $vm.newAgendaStatus) {
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
                        vm.saveNewAgenda()
                        vm.showingAddAgenda = false
                    }
                    .disabled(vm.newAgendaTitle.isEmpty || vm.newAgendaOwner == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.showingAddAgenda = false }
                }
            }
        }
    }

    
    private var vmEditAgendaSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Agenda")) {
                    TextField("Title", text: $vm.editAgendaTitle)
                    TextField("Description", text: $vm.editAgendaDescription)
                    DatePicker("Select Time", selection: $vm.editAgendaTimeDate, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                }

                Section(header: Text("For Who")) {
                    Picker("Select Person", selection: $vm.editAgendaOwner) {
                        Text("Choose Person").tag(nil as Users?)
                        ForEach(vm.users) { user in
                            Text(user.fullName).tag(Optional(user))
                        }
                    }
                }

                Section(header: Text("Urgency Status")) {
                    Picker("Status", selection: $vm.editAgendaStatus) {
                        Text("Low").tag(UrgencyStatus.low)
                        Text("Medium").tag(UrgencyStatus.medium)
                        Text("High").tag(UrgencyStatus.high)
                        Text("Critical").tag(UrgencyStatus.critical)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Agenda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.saveEditedAgenda()
                    }
                    .disabled(vm.editAgendaTitle.isEmpty || vm.editAgendaOwner == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.showingEditAgenda = false }
                }
            }
        }
    }

    
    private func agendaDetailView(_ agenda: AgendaItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(agenda.title).font(.title2.bold())
            Text("By \(agenda.owner)").font(.subheadline).foregroundColor(Color(hex: "#b87cf5"))

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
                // 1. Close the detail sheet
                vm.selectedAgenda = nil
                
                // 2. Prepare edit data
                vm.startEditing(agenda)
                
                // 3. Open edit sheet AFTER the detail sheet closes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    vm.showingEditAgenda = true
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Edit Agenda")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#b87cf5").opacity(0.15))
                .cornerRadius(12)
            }

            Button(role: .destructive) {
                vm.deleteAgenda(agenda)
                vm.selectedAgenda = nil
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Agenda")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.12))
                .cornerRadius(12)
            }
        }
        .padding()
        .presentationDetents([.medium, .large])
    }


    private func formattedSelectedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: date)
    }
}

#Preview {
    GiverCalendarView()
}

