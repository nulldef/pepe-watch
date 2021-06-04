//
//  PepeService.swift
//  RandomPepega WatchKit Extension
//
//  Created by nulldef on 29.05.2021.
//

import Foundation
import Combine

struct Emoji: Decodable, Identifiable {
    var id: UInt
    var image: String
    var category: UInt
    var description: String
}

struct NoPepegaError: Error {}

class PepeService {
    private var url = URL(string: "https://emoji.gg/api/")!

    private var pepeCategory = 13

    private var cache: [Emoji] = []

    func findPepega() -> AnyPublisher<Emoji, Error> {
        return getPepegas()
            .map { (pepegas: [Emoji]) in pepegas.randomElement() }
            .tryMap { (pepega: Emoji?) in
                guard let pepe = pepega else { throw NoPepegaError() }
                return pepe
            }
            .eraseToAnyPublisher()
    }

    func getPepegas() -> AnyPublisher<[Emoji], Never> {
        if cache.isEmpty {
            return loadPepegas()
                .map { (emojis) -> [Emoji] in
                    self.cache = emojis
                    return emojis
                }
                .eraseToAnyPublisher()
        }

        return getFromCache()
    }

    func getFromCache() -> AnyPublisher<[Emoji], Never> {
        debugPrint("Getting from cache...")
        
        return Just(cache).eraseToAnyPublisher()
    }

    func loadPepegas() -> AnyPublisher<[Emoji], Never> {
        debugPrint("Loading pepegas...")

        return URLSession
            .shared
            .dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Emoji].self, decoder: JSONDecoder())
            .map { $0.filter { (emoji) -> Bool in emoji.category == self.pepeCategory } }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
