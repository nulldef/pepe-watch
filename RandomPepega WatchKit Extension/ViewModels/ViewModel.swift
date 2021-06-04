//
//  ViewMOdel.swift
//  RandomPepega WatchKit Extension
//
//  Created by nulldef on 04.06.2021.
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
            .map { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink { (image) in
                self.image = image
                self.loading = false
            }
            .store(in: &cancellable)
    }
}
