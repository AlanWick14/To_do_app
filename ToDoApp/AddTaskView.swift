//
//  AddTaskView.swift
//  ToDoApp
//
//  Created by Anvar on 30/09/24.
//

import SwiftUI
import UserNotifications

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: Int16 = 1
    @State private var showDatePicker: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                // Task Information Section
                Section(header: Text("Task Info")) {
                    TextField("Title", text: $title)
                    TextField("Details", text: $details)
                }

                // Additional Information Section
                Section(header: Text("Additional Info")) {
                    Toggle(isOn: $showDatePicker.animation()) {
                        Text("Set Due Date")
                    }
                    if showDatePicker {
                        DatePicker(
                            "Due Date", selection: $dueDate, in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .padding()
                        Text(
                            "Notifications will be sent at 9:00 AM on the due date."
                        )
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(Int16(0))
                        Text("Medium").tag(Int16(1))
                        Text("High").tag(Int16(2))
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("New Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    addTask()
                    presentationMode.wrappedValue.dismiss()
                }.disabled(title.isEmpty)
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }

        }
    }

    private func addTask() {
        let newTask = ToDoItem(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.details = details
        newTask.dueDate = showDatePicker ? dueDate : nil
        newTask.priority = priority
        newTask.isCompleted = false

        do {
            try viewContext.save()
            // Schedule notification if due date is set
            if showDatePicker {
                scheduleNotification(for: newTask)
            }
        } catch {
            alertMessage = "Failed to save task: \(error.localizedDescription)"
            showAlert = true
        }
    }

    func scheduleNotification(for task: ToDoItem) {
        guard let dueDate = task.dueDate else { return }
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Your task is due soon."
        content.sound = UNNotificationSound.default

        var triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: dueDate)
        triggerDate.hour = 9
        triggerDate.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: task.id?.uuidString ?? UUID().uuidString,
            content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage =
                        "Failed to schedule notification: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }

}
