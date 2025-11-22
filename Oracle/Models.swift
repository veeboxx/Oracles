import SwiftUI
import Combine

// MARK: - Task Priority

enum TaskPriority: String, CaseIterable, Identifiable, Codable {
    case chill
    case low
    case medium
    case high
    case urgent

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .chill:  return "😌"
        case .low:    return "🫧"
        case .medium: return "🙂"
        case .high:   return "🔥"
        case .urgent: return "💀"
        }
    }
    var color: Color {
        switch self {
        case .chill:  return .gray
        case .low:    return .green
        case .medium: return .blue
        case .high:   return .orange
        case .urgent: return .red
        }
    }

}

// MARK: - Task Status

enum TaskStatus: String, Codable {
    case inbox
    case focus
    case completed
}

// MARK: - Task Model

struct TaskItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var notes: String?
    var priority: TaskPriority
    var status: TaskStatus
    var createdAt: Date
    var dueDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        priority: TaskPriority = .medium,
        status: TaskStatus = .inbox,
        createdAt: Date = .now,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priority = priority
        self.status = status
        self.createdAt = createdAt
        self.dueDate = dueDate
    }
}

// MARK: - Task Store (single source of truth)

final class TaskStore: ObservableObject {

    @Published var tasks: [TaskItem]

    /// Default to an **empty** task list – no placeholder tasks.
    init(tasks: [TaskItem] = []) {
        self.tasks = tasks
    }

    // MARK: - Computed views on the data

    /// All tasks that live in the inbox, in insertion order.
    var inboxTasks: [TaskItem] {
        tasks.filter { $0.status == .inbox }
    }

    /// The current focus task (first inbox item, if any).
    var focusTask: TaskItem? {
        inboxTasks.first
    }

    // MARK: - Mutating methods

    /// Adds a task to the bottom of the inbox list.
    func addTaskToInbox(title: String, priority: TaskPriority) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let task = TaskItem(title: trimmed, priority: priority, status: .inbox)
        tasks.append(task)
    }

    /// Inserts at the **front** of inbox so it becomes the current Focus Zone task.
    func addTaskAndFocus(title: String, priority: TaskPriority) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let task = TaskItem(title: trimmed, priority: priority, status: .inbox)
        tasks.insert(task, at: 0)
    }

    func markCompleted(_ task: TaskItem) {
        if let idx = tasks.firstIndex(of: task) {
            tasks[idx].status = .completed
        }
    }
}

