import SwiftUI

// Soft purple accent used throughout the UI
private let oracleAccent = Color(hue: 0.75, saturation: 0.45, brightness: 0.98)

struct HomeView: View {
    @EnvironmentObject var store: TaskStore
    
    @State private var showingAddSheet = false
    
    // Inbox state (local for now)
    @State private var inboxTasks: [InboxTask] = []
    @State private var newTaskTitle: String = ""
    @State private var newTaskPriority: TaskPriority = .medium
    
    // For now, this is a placeholder "one" task and steps.
    // Later we’ll wire this up to real data + Apple Intelligence.
    @State private var focusTaskTitle: String = "Write the weekly progress report"
    @State private var starterSteps: [String] = [
        "Open Notes or your doc template",
        "Jot down 3 wins from this week",
        "List one thing that still feels stuck"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                // Background: very light purple gradient
                LinearGradient(
                    colors: [
                        Color(hue: 0.67, saturation: 0.16, brightness: 0.99),
                        Color(hue: 0.78, saturation: 0.13, brightness: 0.97)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        
                        FocusZoneCard(
                            title: focusTaskTitle,
                            steps: starterSteps
                        )
                        
                        inboxSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 96) // space for floating button
                }
                
                floatingAddButton
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Top Header

private extension HomeView {
    var headerSection: some View {
        HStack(spacing: 16) {
            // App icon / avatar with crystal ball vibe
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 40, height: 40)
                Text("🔮")
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("ORACLE")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                
                Text("One thing at a time")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22, weight: .regular))
            }
            .foregroundStyle(.primary)
        }
    }
}

// MARK: - Inbox Section (bottom half)

private extension HomeView {
    var inboxSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Inbox")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            InboxCardView(items: inboxTasks)
        }
    }
}

// MARK: - Floating Add Button (centered at bottom)

private extension HomeView {
    var floatingAddButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(GlassCircleButtonStyle())
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .center)
        .sheet(isPresented: $showingAddSheet) {
            AddInboxTaskSheet(
                title: $newTaskTitle,
                selectedPriority: $newTaskPriority,
                onAddToFocus: { title, priority in
                    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    
                    // Add to inbox
                    inboxTasks.append(
                        InboxTask(title: trimmed, priority: priority)
                    )
                    
                    // Make it the current Focus Zone task
                    focusTaskTitle = trimmed
                    
                    // Reset + dismiss
                    newTaskTitle = ""
                    newTaskPriority = .medium
                    showingAddSheet = false
                },
                onAddToInbox: { title, priority in
                    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    
                    inboxTasks.append(
                        InboxTask(title: trimmed, priority: priority)
                    )
                    
                    newTaskTitle = ""
                    newTaskPriority = .medium
                    showingAddSheet = false
                },
                onCancel: {
                    newTaskTitle = ""
                    newTaskPriority = .medium
                    showingAddSheet = false
                }
            )
        }
    }
}

// MARK: - Focus Zone Card (ONE task + 3 steps)

struct FocusZoneCard: View {
    let title: String
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Text("FOCUS ZONE")
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                    
                    Text("🔮")
                        .font(.caption)
                }
                
                Spacer()
                
                // Random task button – logic comes later
                Button {
                    // LATER:
                    //  - Randomly pick another task from your list
                    //  - Update the focus task + steps
                } label: {
                    Label("Random task", systemImage: "dice")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 18, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            
            // The ONE task
            Text(title)
                .font(.title3.weight(.semibold))
            
            // 3 tiny starter steps
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 22, height: 22)
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.primary)
                        }
                        
                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    .padding(10)
                    .glassEffect(
                        .regular.tint(Color.white.opacity(0.65)),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                }
            }
            
            // Future Apple Intelligence hook
            Button {
                // FUTURE AI integration
            } label: {
                Label("Let Oracle find first 3 steps", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(20)
        .glassEffect(
            .regular.tint(oracleAccent.opacity(0.8)),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }
}

// MARK: - Inbox Card (one glass box with items inside)

struct InboxCardView: View {
    let items: [InboxTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row inside the card
            HStack {
                Text("Inbox")
                    .font(.subheadline.weight(.semibold))
                
                Spacer()
                
                Menu {
                    // NEXT: hook these up to real sorting
                    Button("By Created Date") {}
                    Button("By Priority") {}
                    Button("Alphabetical") {}
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.system(size: 18, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            
            if items.isEmpty {
                VStack(spacing: 8) {
                    Text("📬")
                        .font(.system(size: 40))
                    
                    Text("Your inbox is peacefully empty.")
                        .font(.subheadline.weight(.semibold))
                    
                    Text("Tap the + button when the next task pops into your mind.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(items) { task in
                    InboxItemRow(task: task)
                        .padding(.vertical, 10)
                    
                    if task.id != items.last?.id {
                        Divider()
                            .overlay(Color.white.opacity(0.18))
                    }
                }
            }
        }
        .padding(16)
        .glassEffect(
            .regular.tint(Color.white.opacity(0.55)),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

// MARK: - One row inside the Inbox card

struct InboxItemRow: View {
    let task: InboxTask
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(task.priority.color.opacity(0.18))
                    .frame(width: 32, height: 32)
                
                Text(task.priority.emoji)
                    .font(.system(size: 18))
            }
            
            Text(task.title)
                .font(.body)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

// MARK: - Add Task Sheet (card-style, refined)

struct AddInboxTaskSheet: View {
    @Binding var title: String
    @Binding var selectedPriority: TaskPriority
    let onAddToFocus: (String, TaskPriority) -> Void
    let onAddToInbox: (String, TaskPriority) -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.9)
                .ignoresSafeArea()
            
            VStack {
                // smaller spacer so card sits higher, less white above
                Spacer(minLength: 24)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header row
                    HStack {
                        Text("Add task")
                            .font(.title2.weight(.semibold))
                        
                        Spacer()
                        
                        Button {
                            onCancel()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Task title field (underline style)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Task")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 2) {
                            TextField("Type task here…", text: $title)
                                .textFieldStyle(.plain)
                                .focused($isTitleFocused)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.25))
                        }
                    }
                    
                    // Priority chips – emoji only, 5 options
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 14) {
                            ForEach(TaskPriority.allCases) { priority in
                                Button {
                                    selectedPriority = priority
                                } label: {
                                    Text(priority.emoji)
                                        .font(.system(size: 20))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    priority == selectedPriority
                                                    ? oracleAccent.opacity(0.22)
                                                    : Color.white.opacity(0.9)
                                                )
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    priority == selectedPriority
                                                    ? oracleAccent.opacity(0.7)
                                                    : Color.clear,
                                                    lineWidth: 1
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center) // center & evenly space
                    }
                    
                    // Two big buttons
                    VStack(spacing: 10) {
                        // Add to Focus Zone
                        Button {
                            onAddToFocus(title, selectedPriority)
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text("Add to ")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.white)
                                
                                Text("Focus Zone")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(oracleAccent)
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.vertical, 12)
                        }
                        .background(
                            Capsule()
                                .fill(Color.black)
                        )
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        
                        // Add to Inbox
                        Button {
                            onAddToInbox(title, selectedPriority)
                        } label: {
                            HStack {
                                Spacer()
                                Text("Add to Inbox")
                                    .font(.body.weight(.semibold))
                                Spacer()
                            }
                            .padding(.vertical, 11)
                        }
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .padding(.top, 4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                
                Spacer(minLength: 0)
            }
        }
        .onAppear {
            // Autofocus the keyboard – slightly longer delay helps on sheets
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTitleFocused = true
            }
        }
    }
}

// MARK: - Simple Inbox Task Model + Priority

struct InboxTask: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: TaskPriority = .medium
}

enum TaskPriority: String, CaseIterable, Identifiable {
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

// MARK: - Liquid Glass Circular Button Style

struct GlassCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 30, weight: .bold))
            .frame(width: 72, height: 72)
            .glassEffect(
                .regular.tint(oracleAccent.opacity(0.1)),
                in: Circle()
            )
            // inner subtle edge for depth
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.03), lineWidth: 0.8)
                    .blur(radius: 0.6)
            )
            // bright crisp main edge
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.65), lineWidth: 1.2)
            )
            // ✨ top rim light (halo highlight)
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),   // top highlight
                                Color.white.opacity(0.00)    // fades down
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .blur(radius: 1.2)
            )
            // deeper downward shadow + magical glow
            .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 10)   // stronger drop shadow
            .shadow(color: oracleAccent.opacity(0.40), radius: 26, x: 0, y: 0)   // magical purple glow
            // press animation
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.90 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = TaskStore()
        HomeView()
            .environmentObject(store)
    }
}

