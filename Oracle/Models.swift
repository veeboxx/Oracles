import SwiftUI
import Combine

// MARK: - Basic To-Do Item

/// A single to-do task inside a folder.
struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
}

// MARK: - Folder Model

/// A folder holds related tasks (like "Instagram", "YouTube", etc.).
struct Folder: Identifiable {
    let id = UUID()
    var name: String
    var symbolName: String   // SF Symbol name for the icon
    var accentColor: Color
    var tasks: [TaskItem] = []
    
    /// Number of incomplete tasks.
    var openTaskCount: Int {
        tasks.filter { !$0.isDone }.count
    }
}

// MARK: - Central Store (Object-Oriented data manager)

/// This class owns all your folders and tasks.
/// Views will observe this so the UI updates automatically.
final class TaskStore: ObservableObject {
    
    /// All folders the app knows about.
    @Published var folders: [Folder]
    
    init() {
        // Start with some example folders, like in your screenshot.
        self.folders = [
            Folder(
                name: "Instagram",
                symbolName: "camera.fill",
                accentColor: Color.purple.opacity(0.9),
                tasks: []
            ),
            Folder(
                name: "X (Twitter)",
                symbolName: "xmark",
                accentColor: Color.blue.opacity(0.9),
                tasks: []
            ),
            Folder(
                name: "YouTube",
                symbolName: "play.rectangle.fill",
                accentColor: Color.red.opacity(0.9),
                tasks: []
            ),
            Folder(
                name: "Facebook",
                symbolName: "f.cursive",
                accentColor: Color.blue.opacity(0.9),
                tasks: []
            ),
            Folder(
                name: "Reddit",
                symbolName: "bubble.left.and.bubble.right.fill",
                accentColor: Color.orange.opacity(0.9),
                tasks: []
            ),
            Folder(
                name: "LinkedIn",
                symbolName: "briefcase.fill",
                accentColor: Color.cyan.opacity(0.9),
                tasks: []
            )
        ]
    }
    
    // MARK: - Future behavior hooks (we’ll fill these in later)
    
    /// Later we’ll use this to add a task to a specific folder.
    func addTask(title: String, toFolderAt index: Int) {
        guard folders.indices.contains(index) else { return }
        let newTask = TaskItem(title: title)
        folders[index].tasks.append(newTask)
    }
    
    /// Later we’ll use this to toggle a task as done / not done.
    func toggleTask(withId id: UUID, inFolderAt index: Int) {
        guard folders.indices.contains(index) else { return }
        if let taskIndex = folders[index].tasks.firstIndex(where: { $0.id == id }) {
            folders[index].tasks[taskIndex].isDone.toggle()
        }
    }
}
//
//  Models.swift
//  Oracle
//
//  Created by Matt Lieder on 11/21/25.
//

