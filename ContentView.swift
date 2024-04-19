import SwiftUI
import Combine

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        Button("Button") {
            viewModel.fetch()
        }.overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}

class ViewModel: ObservableObject {
    
    @Published var isLoading = false
    private var bag = Set<AnyCancellable>()
    
    func fetch() {
        request()
            .receive(on: DispatchQueue.main)
            .sink { status in
                switch status {
                case .loading:
                    self.isLoading = true
                    print("loading...")
                case .success(let returnType):
                    print(returnType)
                case .fail(let error):
                    print(error)
                case .finish:
                    self.isLoading = false
                    print("finish")
                }
            }.store(in: &bag)
    }
    
    func request() -> AnyPublisher<NetworkStatus<String>, Never>  {
        let publisher = CurrentValueSubject<NetworkStatus<String>, Never>(.loading)
        Task {
            try await Task.sleep(for: .seconds(2.0))
            publisher.send(.success("Network Success"))
            publisher.send(.finish)
        }
        return publisher.eraseToAnyPublisher()
    }
}

enum NetworkStatus<ReturnType> {
    case loading
    case success(ReturnType)
    case fail(Error)
    case finish
}
