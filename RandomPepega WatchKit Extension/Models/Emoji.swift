//
//  Emoji.swift
//  RandomPepega WatchKit Extension
//
//  Created by nulldef on 04.06.2021.
//

import Foundation

struct Emoji: Decodable, Identifiable {
    var id: UInt
    var image: String
    var category: UInt
    var description: String
}
