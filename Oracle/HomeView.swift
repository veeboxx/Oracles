import SwiftUI

// Soft purple accent used throughout the UI
private let oracleAccent = Color(hue: 0.75, saturation: 0.45, brightness: 0.98)

struct HomeView: View {
    @EnvironmentObject var store: TaskStore
    
    @State private var showingAddSheet = false
    @State private var quickDumpText: String = ""
    
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
                        
                        otherTasksSection
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

// MARK: - Other Tasks Section

private extension HomeView {
    var otherTasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Other Tasks")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    // NEXT: hook these up to real sorting
                    Button("By Created Date") {}
                    Button("By Priority") {}
                    Button("Alphabetical") {}
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 20, weight: .semibold))
                }
                .foregroundStyle(.primary)
            }
            .foregroundStyle(.secondary)
            
            QuickDumpInboxView(text: $quickDumpText)
            
            VStack(spacing: 12) {
                ForEach(Array(store.folders.enumerated()), id: \.element.id) { _, folder in
                    FolderRow(folder: folder, taskCount: folder.openTaskCount)
                }
            }
        }
    }
}

// MARK: - Floating Add Button (centered at bottom)

private extension HomeView {
    var floatingAddButton: some View {
        Button {
            // NEXT ITERATION: present a real add-task sheet.
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
        }
        .buttonStyle(GlassCircleButtonStyle())
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .center)
        .sheet(isPresented: $showingAddSheet) {
            // Placeholder for now – just UI.
            VStack(spacing: 12) {
                Text("Add Task")
                    .font(.title2.weight(.semibold))
                Text("Next step we’ll connect this to your Quick Dump Inbox and folders.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
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
                // .regular is the standard Liquid Glass material
                .regular.tint(oracleAccent.opacity(0.1)),
                in: Circle()
            )
            // subtle edge highlight so it feels like a puck
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(0.65), lineWidth: 1.2)
            )
            // soft shadow so it “floats”
            .shadow(color: Color.black.opacity(0.16), radius: 10, x: 0, y: 6)
            // press feedback
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.7),
                value: configuration.isPressed
            )
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
                // FUTURE:
                // Use Apple Intelligence / Foundation Models here to:
                //  - Send `title` to the model
                //  - Get back the 3 smallest first steps
                //  - Update `steps` state in HomeView
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

// MARK: - Quick Dump Inbox (bottom-half capture)

struct QuickDumpInboxView: View {
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Dump Inbox")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            HStack(alignment: .top, spacing: 12) {
                TextField("Type the thing that just popped into your head…",
                          text: $text,
                          axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .lineLimit(1...3)
                
                Button {
                    // NEXT ITERATION:
                    //  - Parse natural language for dates/alarms
                    //  - Add as a new task in an Inbox folder via TaskStore
                    text = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .glassEffect(
            .regular.tint(oracleAccent.opacity(0.55)),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

// MARK: - Folder Row (Other tasks / lists)

struct FolderRow: View {
    let folder: Folder
    let taskCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(folder.accentColor.opacity(0.14))
                    .frame(width: 38, height: 38)
                
                Image(systemName: folder.symbolName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(folder.accentColor)
            }
            
            Text(folder.name)
                .font(.body)
            
            Spacer()
            
            Text("\(taskCount)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(
            .regular.tint(Color.white.opacity(0.6)),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
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

