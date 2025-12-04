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
            vm.selectedPerson = user
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
                            let displayTitle =
                                item.medicineId != nil
                                ? "💊 \(item.medicineName ?? "Unknown Medicine")"
                                : item.title

                            agendaItem(title: displayTitle,
                                       time: item.time,
                                       status: item.status,
                                       owner: item.ownerName)
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
    
    // MARK: - Redesigned Add Agenda Sheet (Aesthetic and Spacing Improvements)

    private var vmAddAgendaSheet: some View {
        // Use a ZStack with a soft background color
        ZStack {
            Color(hex: "#FDFBF8").ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Navigation Bar / Header
                HStack {
                    Button("Cancel") { vm.showingAddAgenda = false }
                        .foregroundColor(Color(hex: "#fa6255"))
                    Spacer()
                    Text("Add Agenda")
                        .font(.headline.bold())
                    Spacer()
                    Button("Save") {
                        vm.saveNewAgenda()
                        vm.showingAddAgenda = false
                    }
                    .foregroundColor(Color(hex: "#b87cf5"))
                    .disabled(
                        vm.newAgendaOwner == nil ||
                        (vm.newAgendaType == .activity && vm.newAgendaTitle.isEmpty) ||
                        (vm.newAgendaType == .medicine && vm.selectedMedicine == nil)
                    )
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)

                ScrollView(showsIndicators: false) {
                    // Use generous vertical spacing between sections
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // 1. AGENDA TYPE
                        sectionCard(title: "Agenda Type") {
                            Picker("Agenda Type", selection: $vm.newAgendaType) {
                                Text("Activity").tag(AgendaType.activity)
                                Text("Medicine").tag(AgendaType.medicine)
                            }
                            .pickerStyle(.segmented)
                            .background(Color(hex: "#fff9e6")) // Light yellow background for this specific picker
                            .cornerRadius(10)
                            // Remove extra padding here, let the card padding handle it
                        }
                        
                        // 2. AGENDA DETAILS
                        sectionCard(title: "Agenda Details") {
                            VStack(spacing: 12) { // Increased spacing for form fields
                                // Title field changes depending on type
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
                                
                                Divider()
                                
                                TextField("Description (Optional)", text: $vm.newAgendaDescription)
                                    .padding(.horizontal, 10)
                                
                                Divider()

                                // Use a standard DatePicker style for cleaner look (not wheel in this field)
                                HStack {
                                    Text("Select Time")
                                    Spacer()
                                    DatePicker("", selection: $vm.newAgendaTimeDate, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        
                        // 3. OWNER
                        sectionCard(title: "For Who") {
                            Picker("Select Person", selection: $vm.newAgendaOwner) {
                                Text("Choose Person").tag(nil as Users?)
                                ForEach(vm.users) { user in
                                    Text(user.fullName).tag(Optional(user))
                                }
                            }
                        }
                        
                        // 4. URGENCY
                        sectionCard(title: "Urgency Status") {
                            Picker("Status", selection: $vm.newAgendaStatus) {
                                Text("Low").tag(UrgencyStatus.low)
                                Text("Medium").tag(UrgencyStatus.medium)
                                Text("High").tag(UrgencyStatus.high)
                                Text("Critical").tag(UrgencyStatus.critical)
                            }
                            .pickerStyle(.segmented)
                            .background(Color(hex: "#fff9e6")) // Light yellow background for this specific picker
                            .cornerRadius(10)
                        }
                        
                    }
                    .padding(.horizontal) // Padding for the whole content
                    .padding(.top, 20) // Spacing from the header
                    .padding(.bottom, 40) // Extra padding for scroll safety
                }
            }
        }
        .presentationDetents([.large]) // Ensure it takes up full screen height
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
                    Button("Cancel") { vm.showingEditAgenda = false }
                        .foregroundColor(Color(hex: "#fa6255"))

                    Spacer()

                    Text("Edit Agenda")
                        .font(.headline.bold())

                    Spacer()

                    Button("Save") {
                        vm.saveEditedAgenda()
                        vm.showingEditAgenda = false
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
                                TextField("Title", text: $vm.editAgendaTitle)
                                    .disabled(!vm.isTitleEditable)
                                       .opacity(vm.isTitleEditable ? 1.0 : 0.5)
                                    .padding(.horizontal, 10)
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
                            Picker("Select Person", selection: $vm.editAgendaOwner) {
                                Text("Choose Person").tag(nil as Users?)
                                ForEach(vm.users) { user in
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
    }

    private func agendaDetailView(_ agenda: AgendaItem) -> some View {
        ScrollView {   // ← FIX: ensures image fully appears
            VStack(alignment: .leading, spacing: 16) {

                // MARK: - Medicine Image (only if exists)
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

                // MARK: - Proper title for medicine
                if agenda.medicineId != nil {
                    // Always display medicine name, ignore stored title
                    Text("💊 \(agenda.medicineName ?? "Unknown Medicine")")
                        .font(.title2.bold())
                } else {
                    // Normal activity title
                    Text(agenda.title)
                        .font(.title2.bold())
                }

                Text("By \(agenda.ownerName)")
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

#Preview {
    GiverCalendarView()
}
