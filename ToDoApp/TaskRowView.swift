//
//  TaskRowView.swift
//  ToDoApp
//
//  Created by Anvar on 30/09/24.
//

import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: ToDoItem
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        HStack {
            // Completion Toggle
            Button(action: {
                task.isCompleted.toggle()
                saveContext()
            }) {
                Image(
                    systemName: task.isCompleted
                        ? "checkmark.circle.fill" : "circle"
                )
                .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())

            // Task Title and Due Date
            VStack(alignment: .leading) {
                Text(task.title ?? "Untitled")
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Priority Indicator
            Text(priorityText(priority: task.priority))
                .font(.subheadline)
                .foregroundColor(colorForPriority(task.priority))
                .padding(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(colorForPriority(task.priority), lineWidth: 1)
                )
        }
    }

    // Save context after toggling completion
    private func saveContext() {
        do {
            try task.managedObjectContext?.save()
        } catch {
            alertMessage =
                "Error saving context: \(error.localizedDescription)"
            showAlert = true
        }
    }

    // Helper functions
    private func priorityText(priority: Int16) -> String {
        switch priority {
        case 0:
            return "Low"
        case 1:
            return "Medium"
        case 2:
            return "High"
        default:
            return "Unknown"
        }
    }

    private func colorForPriority(_ priority: Int16) -> Color {
        switch priority {
        case 0:
            return .green
        case 1:
            return .orange
        case 2:
            return .red
        default:
            return .gray
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
