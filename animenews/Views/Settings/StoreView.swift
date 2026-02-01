import SwiftUI
import StoreKit

/// StoreKit 2 manager for In-App Purchases
@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    // Product IDs
    static let proMonthlyID = "com.animenews.pro.monthly"
    static let proYearlyID = "com.animenews.pro.yearly"
    static let proLifetimeID = "com.animenews.pro.lifetime"
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    var isPro: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = [
                Self.proMonthlyID,
                Self.proYearlyID,
                Self.proLifetimeID
            ]
            
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
                
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("StoreKit error: \(error)")
        }
        
        isLoading = false
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true
            
        case .pending:
            return false
            
        case .userCancelled:
            return false
            
        @unknown default:
            return false
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        isLoading = true
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                _ = await MainActor.run {
                    Task {
                        do {
                            let transaction = try self.checkVerified(result)
                            await self.updatePurchasedProducts()
                            await transaction.finish()
                        } catch {
                            print("Transaction verification failed: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    /// Update purchased products set
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchased.insert(transaction.productID)
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    /// Verify transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let item):
            return item
        }
    }
}

enum StoreError: LocalizedError {
    case verificationFailed
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        }
    }
}

/// Pro upgrade paywall view
struct StoreView: View {
    @StateObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Benefits
                benefitsSection
                
                // Products
                if storeManager.isLoading {
                    ProgressView()
                        .frame(height: 200)
                } else if storeManager.products.isEmpty {
                    placeholderProducts
                } else {
                    productsSection
                }
                
                // Restore
                restoreButton
                
                // Terms
                termsSection
            }
            .padding()
        }
        .navigationTitle("AnimeNews Pro")
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 500)
        #endif
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Unlock AnimeNews Pro")
                .font(.title.weight(.bold))
            
            Text("Remove ads and unlock all features")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            BenefitRow(icon: "xmark.circle.fill", color: .red, text: "Remove all advertisements")
            BenefitRow(icon: "chart.line.uptrend.xyaxis", color: .blue, text: "Advanced charting & trends")
            BenefitRow(icon: "bell.badge.fill", color: .purple, text: "Priority notifications")
            BenefitRow(icon: "icloud.fill", color: .cyan, text: "Cloud sync across devices")
            BenefitRow(icon: "heart.fill", color: .pink, text: "Support indie development")
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var productsSection: some View {
        VStack(spacing: 12) {
            ForEach(storeManager.products) { product in
                ProductButton(product: product) {
                    Task {
                        do {
                            let success = try await storeManager.purchase(product)
                            if success {
                                dismiss()
                            }
                        } catch {
                            print("Purchase failed: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    private var placeholderProducts: some View {
        VStack(spacing: 12) {
            PlaceholderProductButton(title: "Monthly", price: "$2.99/month", isPopular: false)
            PlaceholderProductButton(title: "Yearly", price: "$19.99/year", isPopular: true)
            PlaceholderProductButton(title: "Lifetime", price: "$49.99", isPopular: false)
        }
    }
    
    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await storeManager.restorePurchases()
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(.accentColor)
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.caption)
        }
        .padding(.top)
    }
}

struct BenefitRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct ProductButton: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.headline)
            }
            .padding()
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct PlaceholderProductButton: View {
    let title: String
    let price: String
    let isPopular: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.headline)
                    if isPopular {
                        Text("BEST VALUE")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Text(price)
                .font(.headline)
        }
        .padding()
        .background(isPopular ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPopular ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoreView()
        }
    }
}
