import SwiftUI
import Combine

// Soft purple accent used throughout the UI
private let oracleAccent = Color(hue: 0.75, saturation: 0.45, brightness: 0.98)

struct HomeView: View {
    @EnvironmentObject var store: TaskStore

    @State private var showingAddSheet = false
    @State private var newTaskTitle: String = ""
    @State private var newTaskPriority: TaskPriority = .medium

    // Starter steps – will be replaced by AI-generated ones.
    @State private var starterSteps: [String] = [
        "Open Notes or your doc template",
        "Jot down 3 wins from this week",
        "List one thing that still feels stuck"
    ]

    // Apple Intelligence / Oracle state
    @State private var isGeneratingSteps = false
    @State private var aiErrorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hue: 0.67, saturation: 0.16, brightness: 0.99),
                        Color(hue: 0.78, saturation: 0.13, brightness: 0.97)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // CONTENT LAYOUT
                ZStack(alignment: .top) {

                    // MARK: - SCROLLING LAYER (Inbox only)
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {

                            Spacer(minLength: 450)

                            inboxSection

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 96)
                    }
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.20),   // fully transparent at very top
                                .init(color: .black, location: 0.45),  // fade in
                                .init(color: .black, location: 1.0)    // fully visible below
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // MARK: - STATIC LAYER (Header + Focus Zone)
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection

                        FocusZoneCard(
                            title: focusTaskTitle,
                            steps: starterSteps,
                            isGenerating: isGeneratingSteps,
                            onGenerateSteps: generateStepsForFocusTask
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }

                // MARK: - Floating + Button
                floatingAddButton
            }
            .navigationBarHidden(true)
            .alert("Oracle couldn’t help", isPresented: Binding(
                get: { aiErrorMessage != nil },
                set: { newValue in
                    if !newValue { aiErrorMessage = nil }
                }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(aiErrorMessage ?? "")
            }
        }
    }
}

// MARK: - Focus Zone Title

private extension HomeView {
    /// Title shown in the Focus Zone card.
    /// Uses the first inbox task if available; otherwise a friendly prompt.
    var focusTaskTitle: String {
        if let task = store.focusTask {
            return task.title
        } else {
            return "What’s your one important thing today?"
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

// MARK: - Inbox Section

private extension HomeView {
    var inboxSection: some View {
        // The first inbox task is used by Focus Zone,
        // so the list shows only "everything else".
        let remainingInbox = Array(store.inboxTasks.dropFirst())

        return VStack(alignment: .leading, spacing: 16) {
            InboxCardView(items: remainingInbox)
        }
    }
}

// MARK: - Apple Intelligence / Oracle logic

private extension HomeView {
    func generateStepsForFocusTask() {
        let title = focusTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }

        isGeneratingSteps = true
        aiErrorMessage = nil

        Task {
            do {
                let steps = try await OracleStepGenerator.shared.generateSteps(for: title)
                await MainActor.run {
                    self.starterSteps = steps
                    self.isGeneratingSteps = false
                }
            } catch {
                await MainActor.run {
                    self.isGeneratingSteps = false
                    self.aiErrorMessage =
                        (error as? LocalizedError)?.errorDescription
                        ?? "Oracle couldn’t break this task into steps right now."
                }
            }
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
                    store.addTaskAndFocus(title: title, priority: priority)
                    newTaskTitle = ""
                    newTaskPriority = .medium
                    showingAddSheet = false
                },
                onAddToInbox: { title, priority in
                    store.addTaskToInbox(title: title, priority: priority)
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
            .presentationDetents([.height(360)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
        }
    }
}

// MARK: - Focus Zone Card (ONE task + 3 steps)

struct FocusZoneCard: View {
    let title: String
    let steps: [String]
    let isGenerating: Bool
    let onGenerateSteps: () -> Void

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
                    // FUTURE:
                    // ask TaskStore for a random inbox task and promote it to focus
                } label: {
                    Label("Random task", systemImage: "dice")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 18, weight: .semibold))
                }
                .buttonStyle(.plain)
                .disabled(isGenerating)
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

            Button {
                onGenerateSteps()
            } label: {
                if isGenerating {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                        Text("Asking Oracle…")
                            .font(.subheadline.weight(.semibold))
                    }
                } else {
                    Label("Let Oracle find first 3 steps", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
            .disabled(isGenerating)
        }
        .padding(20)
        .glassEffect(
            .regular.tint(oracleAccent.opacity(0.8)),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }
}

// MARK: - Inbox Card

struct InboxCardView: View {
    let items: [TaskItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Inbox")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Menu {
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

// MARK: - Inbox Row

struct InboxItemRow: View {
    let task: TaskItem

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

// MARK: - Add Task Sheet (short bottom card)

struct AddInboxTaskSheet: View {
    @Binding var title: String
    @Binding var selectedPriority: TaskPriority
    let onAddToFocus: (String, TaskPriority) -> Void
    let onAddToInbox: (String, TaskPriority) -> Void
    let onCancel: () -> Void

    @FocusState private var isTitleFocused: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
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

                // Task field
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

                // Priority row
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
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                // Buttons
                VStack(spacing: 10) {
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
                    .shadow(color: oracleAccent.opacity(0.45),
                            radius: 18, x: 0, y: 10)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

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
            .padding(.top, 30)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(Color.clear)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isTitleFocused = true
            }
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
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.03), lineWidth: 0.8)
                    .blur(radius: 0.6)
            )
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.65), lineWidth: 1.2)
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .blur(radius: 1.2)
            )
            .shadow(color: Color.black.opacity(0.22), radius: 14, x: 0, y: 10)
            .shadow(color: oracleAccent.opacity(0.40), radius: 26, x: 0, y: 0)
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

