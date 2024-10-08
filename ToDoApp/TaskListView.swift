//
//  TaskListView.swift
//  ToDoApp
//
//  Created by Anvar on 30/09/24.
//

import CoreData
import SwiftUI

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch Request to retrieve tasks
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ToDoItem.dueDate, ascending: true)
        ],
        animation: .default)
    private var tasks: FetchedResults<ToDoItem>

    @State private var showingAddTaskView = false

    @State private var searchText = ""
    @State private var filter: TaskFilter = .all
    @State private var showAlert = false
    @State private var alertMessage = ""

    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case completed = "Completed"
        case pending = "Pending"
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                // Filter Picker
                Picker("Filter", selection: $filter) {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Task List
                List {
                    ForEach(filteredTasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task))
                        {
                            TaskRowView(task: task)
                        }
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("To-Do List")
            .toolbar {
                // Edit Button
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                // Add Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTaskView.toggle() }) {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView().environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private var filteredTasks: [ToDoItem] {
        tasks.filter { task in
            // Search Filter
            (searchText.isEmpty
                || task.title?.localizedCaseInsensitiveContains(searchText)
                    == true)
                // Status Filter
                && (filter == .all || (filter == .completed && task.isCompleted)
                    || (filter == .pending && !task.isCompleted))
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach { task in
                // Cancel notification
                if let identifier = task.id?.uuidString {
                    UNUserNotificationCenter.current()
                        .removePendingNotificationRequests(withIdentifiers: [
                            identifier
                        ])
                }
                // Delete task
                viewContext.delete(task)
            }
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            // Handle the error appropriately
            alertMessage =
                "Failed to save changes: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
