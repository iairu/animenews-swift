import Foundation
import Combine

class AnimeListViewModel: ObservableObject {
    @Published var animeList = [Anime]()
    @Published var searchQuery = ""
    @Published var isLoading = false
    
    private let jikanService = JikanService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Use a Combine pipeline to react to search query changes with debouncing
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMap { [unowned self] query in
                // Using a Future to wrap the async closure-based service call
                Future<[Anime], Error> { promise in
                    self.jikanService.searchAnime(query: query) { result in
                        switch result {
                        case .success(let anime):
                            promise(.success(anime))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
                }
                .catch { _ in Just<[Anime]>([]) } // On error, return an empty array
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] animeList in
                self?.isLoading = false
                self?.animeList = animeList
            }
            .store(in: &cancellables)
        
        // Initial fetch when the view model is created
        fetchInitialAnime()
    }
    
    func fetchInitialAnime() {
        self.isLoading = true
        jikanService.fetchSeasonalAnime { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let anime):
                    self?.animeList = anime
                case .failure(let error):
                    print("Error fetching anime: \(error.localizedDescription)")
                    self?.animeList = []
                }
            }
        }
    }
}
