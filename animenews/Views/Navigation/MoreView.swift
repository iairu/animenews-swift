import SwiftUI

#if os(iOS)
struct MoreView: View {
    @ObservedObject var tabManager: TabManager
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            ForEach(tabManager.hiddenTabs) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.icon)
                }
            }
        }
        .navigationDestination(for: SidebarSection.self) { section in
            // This relies on RootView's navigation destination handling or we duplicate the switch here
            // Since we are inside the "More" tab's NavigationStack, we need a way to resolve the view.
            // For now, we'll use a wrapper that reproduces the content switching logic.
            SectionContentWrapper(section: section)
        }
        .navigationTitle("More")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditTabsView(tabManager: tabManager)
            }
        }
    }
}

struct SectionContentWrapper: View {
    let section: SidebarSection
    
    var body: some View {
        switch section {
        case .dashboard: DashboardView()
        case .news: NewsListView()
        case .database: AnimeListView()
        case .schedule: ScheduleView()
        case .myAnime: MyAnimeListView()
        case .settings: SettingsView()
        }
    }
}

struct EditTabsView: View {
    @ObservedObject var tabManager: TabManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                Text("Drag your favorite items to the top. The first 4 items will appear in the tab bar.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            }
            
            Section(header: Text("All Tabs")) {
                ForEach(tabManager.allTabs) { section in
                    HStack {
                        Label(section.title, systemImage: section.icon)
                        Spacer()
                        if tabManager.visibleTabs.contains(section) {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.accentColor)
                                .font(.caption)
                        }
                    }
                }
                .onMove(perform: tabManager.moveTab)
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Edit Tabs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
#endif
