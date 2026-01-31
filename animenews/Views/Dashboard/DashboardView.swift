import SwiftUI

struct DashboardView: View {
    var body: some View {
        Text("Dashboard")
            .font(.largeTitle)
            .navigationTitle("Dashboard")
            .navigationTitle("Dashboard")
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
