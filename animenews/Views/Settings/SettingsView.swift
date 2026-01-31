import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.largeTitle)
            .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
