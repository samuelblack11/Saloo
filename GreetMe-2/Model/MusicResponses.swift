//
//  MusicResponses.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/12/23.
//

import Foundation
import UIKit


struct StoreFront: Decodable {
    let data: StoreFrontData
}

struct StoreFrontData: Decodable {
    let attributes: Attributes
    let hRef: String
    // must convert to string
    let id: String
    // must convert to string
    let type: String
}

struct Attributes: Decodable {
    let defaultLanguageTag: String
    // must convert to string
    let explicitContentPolicy: String
    let name: String
    // must convert to string
    let supportedLanguageTags: [String]
}
