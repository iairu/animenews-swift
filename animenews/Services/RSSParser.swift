import Foundation

/// A service that fetches and parses RSS feeds from multiple anime news sources.
class RSSParser {
    
    // RSS Feed URLs
    private let feedURLs: [String: String] = [
        "Anime News Network": "https://www.animenewsnetwork.com/news/rss.xml",
        "Crunchyroll": "https://www.crunchyroll.com/newsrss?lang=en",
        "MyAnimeList": "https://myanimelist.net/rss/news.xml"
    ]
    
    /// Fetches news from all configured RSS feeds.
    func fetchNews() async throws -> [NewsItem] {
        var allItems: [NewsItem] = []
        
        // Fetch from all feeds concurrently
        await withTaskGroup(of: [NewsItem].self) { group in
            for (source, urlString) in feedURLs {
                group.addTask {
                    do {
                        return try await self.fetchFeed(from: urlString, source: source)
                    } catch {
                        print("Failed to fetch \(source): \(error.localizedDescription)")
                        return []
                    }
                }
            }
            
            for await items in group {
                allItems.append(contentsOf: items)
            }
        }
        
        // If all feeds failed, return placeholders
        if allItems.isEmpty {
            return NewsItem.placeholders
        }
        
        // Sort by publication date (newest first)
        return allItems.sorted { $0.pubDate > $1.pubDate }
    }
    
    /// Fetches and parses a single RSS feed.
    private func fetchFeed(from urlString: String, source: String) async throws -> [NewsItem] {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // Use a separate delegate instance for each parse to avoid shared state issues
        let parserDelegate = RSSParserDelegate(source: source)
        let parser = XMLParser(data: data)
        parser.delegate = parserDelegate
        parser.parse()
        
        return parserDelegate.parsedItems
    }
}

// MARK: - Isolated Parser Delegate
// Each feed gets its own delegate instance to avoid shared state issues

private class RSSParserDelegate: NSObject, XMLParserDelegate {
    let source: String
    var parsedItems: [NewsItem] = []
    
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDescription = ""
    private var currentPubDate = ""
    private var isInsideItem = false
    
    // Date formatters for RSS date parsing
    private static let dateFormatters: [DateFormatter] = {
        let formats = [
            "EEE, dd MMM yyyy HH:mm:ss Z",      // RFC 822
            "EEE, dd MMM yyyy HH:mm:ss zzz",    // With timezone name
            "yyyy-MM-dd'T'HH:mm:ssZ",           // ISO 8601
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"        // ISO 8601 with milliseconds
        ]
        return formats.map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            return formatter
        }
    }()
    
    init(source: String) {
        self.source = source
        super.init()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" || elementName == "entry" {
            isInsideItem = true
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentPubDate = ""
        }
        
        // Handle Atom feeds where link is an attribute
        if elementName == "link" && isInsideItem {
            if let href = attributeDict["href"] {
                currentLink = href
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideItem else { return }
        
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        switch currentElement {
        case "title":
            currentTitle += trimmed
        case "link":
            if currentLink.isEmpty {
                currentLink += trimmed
            }
        case "description", "summary", "content":
            currentDescription += trimmed
        case "pubDate", "published", "updated":
            currentPubDate += trimmed
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" || elementName == "entry" {
            isInsideItem = false
            
            // Create NewsItem if we have required fields
            if !currentTitle.isEmpty && !currentLink.isEmpty {
                let pubDate = Self.parseDate(from: currentPubDate) ?? Date()
                let cleanDescription = Self.stripHTML(from: currentDescription)
                
                let item = NewsItem(
                    title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                    link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                    pubDate: pubDate,
                    source: source,
                    description: cleanDescription
                )
                parsedItems.append(item)
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Attempts to parse a date string using multiple formats.
    private static func parseDate(from string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try direct parsing first
        for formatter in dateFormatters {
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        
        // Fallback: Extract RFC 822 date pattern from potentially malformed string
        let rfc822Pattern = #"[A-Za-z]{3},?\s+\d{1,2}\s+[A-Za-z]{3}\s+\d{4}\s+\d{2}:\d{2}:\d{2}\s+[+-]?\d{4}"#
        if let range = trimmed.range(of: rfc822Pattern, options: .regularExpression) {
            let extractedDate = String(trimmed[range])
            for formatter in dateFormatters {
                if let date = formatter.date(from: extractedDate) {
                    return date
                }
            }
        }
        
        return nil
    }
    
    /// Strips HTML tags from a string.
    private static func stripHTML(from string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return string
        }
        
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        ) {
            return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Fallback: simple regex-based stripping
        return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

