import SwiftUI
import Combine

class TabManager: ObservableObject {
    @AppStorage("tabOrder") private var tabOrderData: Data = Data()
    
    @Published var allTabs: [SidebarSection] = []
    
    var visibleTabs: [SidebarSection] {
        Array(allTabs.prefix(4))
    }
    
    var hiddenTabs: [SidebarSection] {
        Array(allTabs.dropFirst(4))
    }
    
    init() {
        loadTabs()
    }
    
    private func loadTabs() {
        if let decoded = try? JSONDecoder().decode([SidebarSection].self, from: tabOrderData), !decoded.isEmpty {
            // Merge dealing with potential new cases in future updates
             let savedSet = Set(decoded)
             let allCases = SidebarSection.allCases
             
             // Start with saved order
             var result = decoded
             
             // Append any new cases not present in saved data
             for section in allCases {
                 if !savedSet.contains(section) {
                     result.append(section)
                 }
             }
             
             // Remove any cases that no longer exist (cleanup)
             let currentSet = Set(allCases)
             result = result.filter { currentSet.contains($0) }
             
             self.allTabs = result
        } else {
            // Default order
            self.allTabs = SidebarSection.allCases
        }
    }
    
    func saveTabs() {
        if let encoded = try? JSONEncoder().encode(allTabs) {
            tabOrderData = encoded
        }
    }
    
    func moveTab(from source: IndexSet, to destination: Int) {
        allTabs.move(fromOffsets: source, toOffset: destination)
        saveTabs()
    }
    
    func move(from source: SidebarSection, to index: Int) {
        if let sourceIndex = allTabs.firstIndex(of: source) {
            allTabs.remove(at: sourceIndex)
            allTabs.insert(source, at: index)
            saveTabs()
        }
    }
}
