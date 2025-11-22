import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: TaskStore
    
    // In later steps we’ll use this for the “+” button.
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.secondarySystemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        announcementsSection
                        foldersSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 80) // space for floating button
                }
                
                floatingAddButton
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Subviews

private extension HomeView {
    
    // Big "ORACLE" title, like "YABA"
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("ORACLE")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                
                Text("Announcements")
                    .font(.headline)
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
    
    // Two rounded announcement cards
    var announcementsSection: some View {
        VStack(spacing: 12) {
            AnnouncementRow(
                icon: "🎉",
                title: "What’s new in ORACLE v1.0?"
            )
            
            AnnouncementRow(
                icon: "⚠️",
                title: "ToS and EULA are updated"
            )
        }
    }
    
    // "Folders" label + social-style folder rows
    var foldersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "folder")
                Text("Folders")
                    .font(.headline)
                Spacer()
            }
            .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                ForEach(Array(store.folders.enumerated()), id: \.element.id) { index, folder in
                    FolderRow(folder: folder, taskCount: folder.openTaskCount)
                }
            }
        }
    }
    
    // Floating blue "+" button
    var floatingAddButton: some View {
        HStack {
            Spacer()
            Button {
                // In the next iteration we’ll present a sheet
                // and actually add a new task.
                showingAddSheet = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 72, height: 72)
                        .shadow(radius: 8)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
            .sheet(isPresented: $showingAddSheet) {
                // Placeholder for now – will become AddTaskView soon.
                Text("Add Task Coming Soon")
                    .font(.title2)
                    .padding()
            }
        }
    }
}

// MARK: - Reusable Rows

/// Little rounded card used for each announcement row.
struct AnnouncementRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

/// Social-style folder row (icon + name + task count)
struct FolderRow: View {
    let folder: Folder
    let taskCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(folder.accentColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                
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
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
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
//
//  HomeView.swift
//  Oracle
//
//  Created by Matt Lieder on 11/21/25.
//

