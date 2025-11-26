//
//  TasksViewModel.swift
//  WeCare
//
//  Created by student on 26/11/25.
//

import Foundation
import FirebaseFirestore
import Combine


class TasksViewModel: ObservableObject {
    @Published var tasks: [Tasks] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil


    private let db = Firestore.firestore()
    private let collectionName = "tasks" // ganti kalau di Firestore beda


    // MARK: - Fetch all tasks
    func fetchAllTasks() {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .order(by: "due_time", descending: false) // optional: urutkan by due_time
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
                        self.tasks = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.tasks = []
                    }
                    return
                }


                let fetchedTasks = documents.map { doc -> Tasks in
                    return Tasks(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.tasks = fetchedTasks
                }
            }
    }


    // MARK: - Fetch tasks for specific careReceiver (ex: elderly user)
    func fetchTasksForCareReceiver(_ careReceiverId: Int) {
        isLoading = true
        errorMessage = nil


        db.collection(collectionName)
            .whereField("careReceiver_id", isEqualTo: careReceiverId)
            .order(by: "due_time", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                }


                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
                        self.tasks = []
                    }
                    return
                }


                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.tasks = []
                    }
                    return
                }


                let fetchedTasks = documents.map { doc -> Tasks in
                    return Tasks(id: doc.documentID, data: doc.data())
                }


                DispatchQueue.main.async {
                    self.tasks = fetchedTasks
                }
            }
    }
}






