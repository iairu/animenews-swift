import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearance: AppearanceMode = .system
    @AppStorage("simulcastAlerts") private var simulcastAlerts = false
    @AppStorage("breakingNews") private var breakingNews = true
    @State private var showingClearCacheAlert = false
    @State private var cacheCleared = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Group {
                    // MARK: - Pro Section
                    proSection
                    
                    Divider()
                    
                    // MARK: - Data & Sync
                    dataSyncSection
                    
                    Divider()
                    
                    // MARK: - Appearance
                    appearanceSection
                }
                
                Group {
                    Divider()
                    
                    // MARK: - Notifications
                    notificationsSection
                    
                    Divider()
                    
                    // MARK: - About
                    aboutSection
                    
                    Divider()
                    
                    // MARK: - Legal
                    legalSection
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Settings")
        .toolbar {
            #if os(macOS)
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                }) {
                    Image(systemName: "sidebar.left")
                }
            }
            #endif
        }
    }
    
    // MARK: - Pro Section
    private var proSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Subscription", icon: "crown.fill")
            
            HStack(spacing: 20) {
                // Status Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("AnimeNews Pro")
                        .font(.headline)
                    Text("Free Plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Unlock all features and remove ads")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button(action: {
                        // Placeholder for StoreKit 2 integration
                    }) {
                        Text("Upgrade to Pro")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Restore Purchases") {
                        // Placeholder for StoreKit 2 restore
                    }
                    .font(.caption)
                }
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Data & Sync Section
    private var dataSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Data & Sync", icon: "arrow.triangle.2.circlepath")
            
            VStack(alignment: .leading, spacing: 12) {
                // Clear Cache Row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cache")
                            .font(.headline)
                        Text("Cached API responses and images")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if cacheCleared {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Cleared!")
                                .foregroundColor(.green)
                        }
                        .font(.subheadline)
                    } else {
                        Button(role: .destructive) {
                            showingClearCacheAlert = true
                        } label: {
                            Text("Clear Cache")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                
                // AniList Sync (Placeholder)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AniList Sync")
                            .font(.headline)
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Connect") {
                        // Placeholder
                    }
                    .buttonStyle(.bordered)
                    .disabled(true)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will remove all cached anime data and images. The data will be re-downloaded when needed.")
        }
    }
    
    // MARK: - Appearance Section
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Appearance", icon: "paintbrush.fill")
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme")
                    .font(.headline)
                
                Picker("Theme", selection: $appearance) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
                
                Text("Choose how AnimeNews appears. System follows your device settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Notifications", icon: "bell.fill")
            
            VStack(spacing: 0) {
                // Simulcast Alerts
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Simulcast Alerts")
                            .font(.headline)
                        Text("Get notified when tracked shows air new episodes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $simulcastAlerts)
                        .toggleStyle(.switch)
                }
                .padding()
                
                Divider()
                    .padding(.horizontal)
                
                // Breaking News
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Breaking News")
                            .font(.headline)
                        Text("Important anime industry announcements")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $breakingNews)
                        .toggleStyle(.switch)
                }
                .padding()
            }
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "About", icon: "info.circle.fill")
            
            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Version")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .fontWeight(.medium)
                    }
                    .frame(width: 150)
                    
                    HStack {
                        Text("Build")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(Bundle.main.buildNumber)
                            .fontWeight(.medium)
                    }
                    .frame(width: 150)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Link("View on GitHub", destination: URL(string: "https://github.com")!)
                    Link("Report an Issue", destination: URL(string: "https://github.com")!)
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Legal", icon: "doc.text.fill")
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Anime data provided by Jikan API (MyAnimeList). This application is not affiliated with or endorsed by MyAnimeList Co., Ltd.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("News content is aggregated from public RSS feeds provided by their respective publishers.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("© 2026 AnimeNews. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.title3.weight(.semibold))
    }
    
    // MARK: - Actions
    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        
        withAnimation {
            cacheCleared = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                cacheCleared = false
            }
        }
    }
}

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .preferredColorScheme(.dark)
    }
}
