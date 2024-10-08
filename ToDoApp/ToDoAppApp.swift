//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by Anvar on 30/09/24.
//
import SwiftUI

@main
struct ToDoAppApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
