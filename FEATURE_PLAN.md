Here is the comprehensive technical blueprint for **AnimeNews**, structured to evolve from a functional Alpha to a sophisticated Release candidate. This hierarchy is designed for an Xcode project using **SwiftUI** with **Mac Catalyst** enabled (Targeting macOS 12 & iOS 15).

------

### **Phase 1: Alpha Version (The "Skeleton")**

**Goal:** Establish the data pipeline (Jikan + RSS) and basic navigation. No complex charts, ads, or persistence yet.

**Complexity:** Low. Focus on "Can we get the data on the screen?"

#### **File Hierarchy**

Plaintext

```
AnimeNews/
├── App/
│   ├── AnimeNewsApp.swift           // Entry point. Sets up the MainTabView/NavigationView.
│   └── Assets.xcassets              // App Icon, placeholder images.
├── Models/
│   ├── Anime.swift                  // Codable struct matching Jikan's /anime/{id}/full.
│   ├── NewsItem.swift               // Struct for RSS items (title, link, date, source).
│   └── JikanResponse.swift          // Generic wrapper for Jikan API responses.
├── Services/
│   ├── JikanService.swift           // Basic Fetch logic: `func fetchSeason()`, `func search(query:)`.
│   └── RSSParser.swift              // Wraps FeedKit to parse XML into [NewsItem].
├── ViewModels/
│   ├── NewsViewModel.swift          // Publishes [NewsItem] array.
│   └── AnimeListViewModel.swift     // Manages search state and results.
├── Views/
│   ├── Main/
│   │   └── RootView.swift           // Basic TabView (iOS) or NavigationView (macOS).
│   ├── News/
│   │   └── NewsListView.swift       // Simple List(newsItems).
│   ├── Database/
│   │   ├── AnimeListView.swift      // List of anime with search bar.
│   │   └── AnimeDetailView.swift    // Basic ScrollView with Title, Image, Synopsis.
│   └── Shared/
│       └── AsyncImageView.swift     // Wrapper for AsyncImage with caching placeholder.
└── Utilities/
    └── Constants.swift              // API Base URLs.
```

------

### **Phase 2: Beta Version (The "Designer")**

**Goal:** Implement the "Apple Health" aesthetic, Mac Catalyst 3-column layout, Charting logic, and AdMob.

**Complexity:** Medium. Visual polish and platform-specific UX.

#### **File Hierarchy (additions/changes to Alpha)**

Plaintext

```
AnimeNews/
├── Services/
│   ├── AdService.swift              // (NEW) Manages AdMob initialization.
│   └── ChartDataCalculator.swift    // (NEW) Helper to normalize data for charts (0.0 to 1.0).
├── ViewModels/
│   └── DashboardViewModel.swift     // (NEW) Aggregates "Seasonal Progress" logic.
├── Views/
│   ├── Navigation/
│   │   ├── Sidebar.swift            // (NEW) The primary navigation column (macOS).
│   │   └── ThreeColumnLayout.swift  // (NEW) Holds Sidebar -> Content -> Detail structure.
│   ├── Dashboard/                   // (NEW: "Apple Health" Style)
│   │   ├── SummaryView.swift        // The main dashboard grid.
│   │   ├── ActivityRing.swift       // Custom Shape for "Watching" rings (Teal/Pink/Green).
│   │   └── TrendChart.swift         // Custom Path/Shape drawing for line charts.
│   ├── Components/
│   │   ├── GradientCard.swift       // (NEW) Reusable card background style.
│   │   └── NativeAdView.swift       // (NEW) UIViewRepresentable for AdMob Native Advanced.
│   └── Modals/
│       └── WebView.swift            // (NEW) Safari wrapper for reading RSS articles.
└── Info.plist                       // Updated with AdMob App ID and Transport Security settings.
```

------

### **Phase 3: Release Version (The "Product")**

**Goal:** Full complexity. IAP (StoreKit 2), Persistence (Core Data), Inspector Panel, Settings, Deep Linking, and production-grade error handling.

**Complexity:** High. Commercial readiness.

#### **File Hierarchy (Final)**

Plaintext

```
AnimeNews/
├── App/
│   ├── Persistence.swift            // (NEW) Core Data stack setup.
│   └── NavigationStore.swift        // (NEW) Central ObservableObject for deep linking state.
├── Models/
│   ├── CoreData/                    // (NEW) .xcdatamodeld file.
│   └── StoreProduct.swift           // (NEW) Wrapper for StoreKit 2 Product.
├── Services/
│   ├── StoreManager.swift           // (NEW) Handles IAP transactions and entitlement checks.
│   ├── NetworkThrottler.swift       // (NEW) Token bucket logic to respect Jikan's 3 req/sec limit.
│   └── ImageCache.swift             // (NEW) Custom cache to save bandwidth.
├── Views/
│   ├── Settings/
│   │   ├── SettingsView.swift       // (NEW) Preferences pane.
│   │   └── StoreView.swift          // (NEW) "Go Pro" paywall with Restore Purchases.
│   ├── Detail/
│   │   ├── InspectorPanel.swift     // (NEW) The collapsible right sidebar for metadata.
│   │   ├── FranchiseTreeView.swift  // (NEW) Visualizing relations (Prequels/Sequels).
│   │   └── StaffGrid.swift          // (NEW) Grid of Voice Actors.
│   └── Navigation/
│       └── ToolbarItems.swift       // (NEW) Extracted toolbar logic for cleaner views.
└── Resources/
    └── Localizable.strings          // (NEW) All static text moved here for localization.
```

------

### **4. Component & Navigation Map**

#### **A. Global Navigation Structure**

- **macOS (Catalyst):** `DoubleColumnNavigationViewStyle` (Sidebar + Content). The Content view pushes the Detail view.
- **iOS (iPhone):** `TabView` (Bottom Bar).
- **iOS (iPad):** `NavigationView` with `.columns` style.

| **Main Sidebar (Root)** | **Secondary Sidebar (Content List)** | **Detail View (Inspector)**        |
| ----------------------- | ------------------------------------ | ---------------------------------- |
| **Summary** (Dashboard) | *(None - Dashboard fills space)*     | *(None)*                           |
| **Newsroom** (RSS)      | **Article List** (Filterable)        | **Web View** (Article Content)     |
| **Database** (Search)   | **Anime List** (Search Results)      | **Anime Detail** (+ Right Sidebar) |
| **Library** (Watchlist) | **My List** (Watching/Plan to Watch) | **Anime Detail**                   |
| **Trends** (Charts)     | *(None - Charts fill space)*         | *(None)*                           |
| **Settings**            | *(None)*                             | *(None)*                           |

#### **B. Toolbar Contents (Customizable)**

| **Context**      | **Left Items**                        | **Center Items**                 | **Right Items**                                              |
| ---------------- | ------------------------------------- | -------------------------------- | ------------------------------------------------------------ |
| **Dashboard**    | `DateString` (e.g., "Friday, Jan 30") | *(Empty)*                        | `ProfileIcon` (AniList Sync Status)                          |
| **Newsroom**     | `FilterMenu` (All Sources/Specific)   | `SearchField`                    | `ShareButton`                                                |
| **Anime Detail** | `Back` (System)                       | `InlineTitle` (Scroll dependent) | `FavoriteToggle` (Heart), `Share`, **`ToggleInspector`** (Sidebar Icon) |

------

### **5. Settings Options**

Located in `Views/Settings/SettingsView.swift`.

1. **AnimeNews Pro (Header)**
   - **Status:** "Free Plan" / "Pro Active"
   - **Action:** "Upgrade to Pro" (Triggers `StoreView`) or "Restore Purchases".
2. **Data & Sync**
   - **AniList Integration:** Login/Logout (OAuth).
   - **Clear Cache:** Button to wipe cached Jikan responses/images (Frees storage).
3. **Appearance**
   - **App Icon:** Picker (Default, Retro, Neon).
   - **Theme:** System / Light / Dark.
4. **Notifications**
   - **Simulcast Alerts:** Toggle (Notify when "Watching" shows air).
   - **Breaking News:** Toggle.
5. **About**
   - **Version:** Static string.
   - **Legal:** "Data provided by Jikan/MyAnimeList. App is not affiliated with MAL."

------

### **6. Static vs. Dynamic Text Mapping**

This table defines what text is hardcoded (`Localizable.strings`) and what is pulled from the API (`JikanResponse` or `RSSFeed`).

#### **Dashboard (Summary)**

| **UI Element** | **Source Type** | **Content Example** | **Source Field**                    |
| -------------- | --------------- | ------------------- | ----------------------------------- |
| Header         | Static          | "Summary"           | `App Strings`                       |
| Ring 1 Label   | Static          | "WATCHING"          | `App Strings`                       |
| Ring 1 Value   | **Dynamic**     | "5/12"              | User Data / AniList                 |
| Ring 2 Label   | Static          | "SEASONAL COVERAGE" | `App Strings`                       |
| Ring 2 Value   | **Dynamic**     | "30%"               | `Calc: (UserWatched / Top10Season)` |
| Trend Card     | Static          | "TRENDING NOW"      | `App Strings`                       |
| Trend Title    | **Dynamic**     | "Chainsaw Man"      | Jikan: `/top/anime` -> `title`      |

#### **Anime Detail View (The Encyclopedia)**

| **UI Element**    | **Source Type** | **Content Example**  | **Source Field (Jikan)**                       |
| ----------------- | --------------- | -------------------- | ---------------------------------------------- |
| **Header**        | **Dynamic**     | "Attack on Titan"    | `data.title`                                   |
| Subhead           | **Dynamic**     | "TV • MAPPA • 2020"  | `type`, `studios[0].name`, `year`              |
| **Inspector**     | Static          | "INFORMATION"        | `App Strings`                                  |
| Field: Alt Title  | **Dynamic**     | "Shingeki no Kyojin" | `title_japanese`                               |
| Field: Status     | **Dynamic**     | "Finished Airing"    | `status`                                       |
| Field: Episodes   | **Dynamic**     | "75 eps × 24 min"    | `episodes`, `duration`                         |
| Field: Rating     | **Dynamic**     | "R - 17+"            | `rating`                                       |
| **Cast Section**  | Static          | "MAIN CAST"          | `App Strings`                                  |
| Actor Name        | **Dynamic**     | "Yuki Kaji"          | `/characters` -> `voice_actors[0].person.name` |
| **Staff Section** | Static          | "KEY STAFF"          | `App Strings`                                  |
| Director          | **Dynamic**     | "Yuichiro Hayashi"   | `/staff` -> Filter by "Director"               |
| **Franchise**     | Static          | "RELATED WORKS"      | `App Strings`                                  |
| Relation Type     | **Dynamic**     | "Prequel"            | `/relations` -> `relation`                     |

#### **News Feed**

| **UI Element** | **Source Type** | **Content Example**          | **Source Field (RSS)** |
| -------------- | --------------- | ---------------------------- | ---------------------- |
| Source Tag     | **Dynamic**     | "ANN"                        | Derived from Feed URL  |
| Headline       | **Dynamic**     | "Studio Ghibli Announces..." | `<item><title>`        |
| Timestamp      | **Dynamic**     | "2h ago"                     | `<item><pubDate>`      |
| Snippet        | **Dynamic**     | "The legendary director..."  | `<item><description>`  |

#### **IAP Screen**

| **UI Element** | **Source Type** | **Content Example**          | **Source Field**                   |
| -------------- | --------------- | ---------------------------- | ---------------------------------- |
| Title          | Static          | "Unlock AnimeNews Pro"       | `App Strings`                      |
| Benefit 1      | Static          | "Remove all advertisements"  | `App Strings`                      |
| Benefit 2      | Static          | "Advanced Charting & Trends" | `App Strings`                      |
| Price Button   | **Dynamic**     | "$4.99"                      | StoreKit 2: `product.displayPrice` |