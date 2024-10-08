//
//  PersistenceController.swift
//  ToDoApp
//
//  Created by Anvar on 30/09/24.
//

import Combine
import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    let errorHandler = ErrorHandler()

    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Create sample data
        for _ in 0..<10 {
            let newItem = ToDoItem(context: viewContext)
            newItem.id = UUID()
            newItem.title = "Sample Task"
            newItem.details = "This is a sample task."
            newItem.dueDate = Date()
            newItem.priority = 1
            newItem.isCompleted = false
        }
        do {
            try viewContext.save()
        } catch {
            // Handle the error appropriately
            // Since this is a preview, you might choose to ignore the error
        }
        return result
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoApp")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(
                fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { [weak self] (_, error) in
            if let error = error as NSError? {
                // Handle the error by setting the alertMessage in errorHandler
                DispatchQueue.main.async {
                    self?.errorHandler.alertMessage =
                        "An error occurred while loading the app data."
                }
                // Removed print statements for production release
            }
        }
        // Merge changes from other contexts automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
