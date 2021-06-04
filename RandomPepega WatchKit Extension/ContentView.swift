//
//  ContentView.swift
//  RandomPepega WatchKit Extension
//
//  Created by nulldef on 29.05.2021.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var loading: Bool = false

    private var service: PepeService = .init()
    private var cancellable: Set<AnyCancellable> = []

    func refresh() {
        if loading { return }

        debugPrint("Start loading...")
        self.loading = true

        service.findPepega()
            .assertNoFailure()
            .flatMap { (emoji: Emoji) -> AnyPublisher<Data, Never> in
                debugPrint("Getting image from \(emoji.image)")
                let url = URL(string: emoji.image)!
                return URLSession.shared
                    .dataTaskPublisher(for: url)
                    .map { $0.data }
                    .assertNoFailure()
                    .eraseToAnyPublisher()
            }
            .map { (data: Data) -> UIImage in
                return UIImage(data: data)!
            }
            .receive(on: DispatchQueue.main)
            .sink { (image) in
                self.image = image
                self.loading = false
            }
            .store(in: &cancellable)
    }
}

struct ContentView: View {
    @ObservedObject var model = ViewModel()

    var body: some View {
        ZStack {
            if model.loading {
                VStack {
                    Text("RandomPepega")
                        .font(.headline)
                        .padding()
                    Text("Wait for it...")
                        .font(.subheadline)
                }
            } else {
                if let image = model.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .padding()
        .onAppear(perform: model.refresh)
        .onTapGesture(perform: model.refresh)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
