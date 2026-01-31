import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.largeTitle)
            .navigationTitle("Settings")
        
            .navigationTitle("Settings")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        // This action toggles the sidebar in a multi-column layout.
                        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    }) {
                        Image(systemName: "sidebar.left")
                    }
                }
#endif
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
