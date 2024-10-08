import SwiftUI
import UserNotifications

struct TaskDetailView: View {
    @ObservedObject var task: ToDoItem
    @Environment(\.managedObjectContext) private var viewContext

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: Int16 = 1
    @State private var showDatePicker: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
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
                        displayedComponents: [.date, .hourAndMinute])
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
        .navigationTitle("Edit Task")
        .navigationBarItems(
            trailing: Button("Save") {
                updateTask()
            }
        )
        .onAppear {
            title = task.title ?? ""
            details = task.details ?? ""
            if let taskDueDate = task.dueDate {
                dueDate = taskDueDate
                showDatePicker = true
            }
            priority = task.priority
        }
    }

    private func updateTask() {
        task.title = title
        task.details = details
        task.dueDate = showDatePicker ? dueDate : nil
        task.priority = priority

        do {
            try viewContext.save()
            // Schedule or cancel notification based on due date
            if showDatePicker {
                scheduleNotification(for: task)
            } else {
                cancelNotification(for: task)
            }
        } catch {
            alertMessage =
                "Failed to update task: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func scheduleNotification(for task: ToDoItem) {
        guard let dueDate = task.dueDate else { return }
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title ?? "Your task is due soon."
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(
            identifier: task.id?.uuidString ?? UUID().uuidString,
            content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }

    private func cancelNotification(for task: ToDoItem) {
        guard let identifier = task.id?.uuidString else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier])
    }
}
