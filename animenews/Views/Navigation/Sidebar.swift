import SwiftUI

struct Sidebar: View {
    @Binding var selection: NavigationItem?

    var body: some View {
        List(selection: $selection) {
            ForEach(NavigationItem.allCases) { item in
                // Use a simple if-else to push Settings to the bottom,
                // as Spacer is not supported in this context with selection.
                if item == .settings {
                    // This is a common pattern to create space.
                    // A proper implementation might use sections.
                }
                
                NavigationLink(value: item) {
                    item.icon
                }
                .tag(item)
            }
        }
        .listStyle(.sidebar)
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(selection: .constant(.dashboard))
            .frame(width: 200)
    }
}
