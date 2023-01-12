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
    let attributes: [String]
    let hRef: String
    let id: String
    let type: String
}

struct Attributes: Decodable {
    let defaultLanguageTag: String
    let explicitContentPolicy: String
    let name: String
    let supportedLanguageTags: [String]
}
