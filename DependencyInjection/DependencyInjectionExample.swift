//
//  ContentView.swift
//  DependencyInjection
//
//  Created by Christian Skorobogatow on 12/8/22.
//

import SwiftUI
import Combine


// Problems with SINGLETONS
// 1. Singletons are Global
// 2. Can't customize the init
// 3. Can't swap out dependencies

struct PostModel: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

protocol DataServiceProtocol {
    func getData() -> AnyPublisher<[PostModel], Error>
}

class ProductionDataService: DataServiceProtocol {
    
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func getData() -> AnyPublisher<[PostModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: [PostModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class MockDataServic: DataServiceProtocol {
    
    let testData: [PostModel]
    
    init(data: [PostModel]?) {
        self.testData = data ?? [
            PostModel(userId: 1, id: 1, title: "One", body: "One"),
            PostModel(userId: 2, id: 2, title: "two", body: "two")
        ]
    }
    
    func getData() -> AnyPublisher<[PostModel], Error> {
        Just(testData)
            .tryMap({ $0 })
            .eraseToAnyPublisher()
    }
}



class DependencyInjectionViewModel: ObservableObject {
    
    @Published var dataArray: [PostModel] = []
    
    var cancellables = Set<AnyCancellable>()
    let dataService: DataServiceProtocol
    
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        loadPosts()
    }
    
    private func loadPosts() {
        dataService.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedPosts in
                self?.dataArray = returnedPosts
            }
            .store(in: &cancellables)

    }
    
}

class Dependencies {
    // In case you have several dependencies
    // Add dependencies here and pass this class around to inject
    
    let dataservice: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataservice = dataService
    }
    
}

struct DependencyInjectionExample: View {
    
    @StateObject private var vm: DependencyInjectionViewModel
    
    init(dataService: DataServiceProtocol) {
        _vm = StateObject(wrappedValue: DependencyInjectionViewModel(dataService: dataService))
    }
    
    var body: some View {
        ScrollView{
            VStack {
                ForEach(vm.dataArray) { post in
                    Text(post.title)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    
//    static let dataService = ProductionDataService(url: url)
//    static let dataService = MockDataServic(data: nil)
    static let dataService = MockDataServic(data: [
        PostModel(userId: 1, id: 1, title: "One", body: "One"),
        PostModel(userId: 2, id: 2, title: "Two", body: "Two"),
        PostModel(userId: 3, id: 3, title: "Three", body: "Three")
        
    ])
    
    
    static var previews: some View {
        DependencyInjectionExample(dataService: dataService)
    }
}
