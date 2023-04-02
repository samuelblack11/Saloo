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


struct SongsReponse: Decodable {
    let results: SongResults
}

struct SongResults: Decodable {
    let songs: Songs
}

struct Songs: Decodable {
    let data: [Song]
}

struct Song: Decodable {
    let attributes: SongAttributes
}

struct SongAttributes: Decodable {
    let name: String
    let artistName: String
    let albumName: String
    let artwork: Artwork
    let playParams: PlayParams
    let previews: [PreviewURL]
    let durationInMillis: Int
}

struct PlayParams: Decodable {
    let id: String
}

struct Artwork: Decodable {
    let url: String
}

struct PreviewURL: Decodable {
    let url: String
}

struct AMStoreFrontResponse: Decodable {
    let data: [StoreFrontDataPoints]
}

struct StoreFrontDataPoints: Decodable {
    let id: String
}
