//
//  SpotResponses.swift
//  Saloo
//
//  Created by Sam Black on 1/31/23.
//

import Foundation




struct SpotResponse: Decodable {
    let tracks: Tracks
}

struct Tracks: Decodable {
    let items: [SpotItem]
}

struct SpotItem: Decodable {
    let id: String
    let name: String
    let album: AlbumData?
    let artists: [ArtistObject]
    //let previews: [PreviewURL]
    let preview_url: String?
    let duration_ms: Int
    //let availableMarkets: [String]
    let restrictions: RestrictionObj?
    let disc_number: Int?
    let external_urls: ExternalURLObj?
}



struct ExternalURLObj: Decodable {
    let spotify: String?
}

struct RestrictionObj: Decodable {
    let reason: String
}

struct ArtistObject: Decodable {
    let name: String
}

struct AlbumData: Decodable, Hashable {
    let name: String
    let id: String
    let images: [AlbumImages]
    let album_type: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    static func ==(lhs: AlbumData, rhs: AlbumData) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    
}

struct SearchResult {
    let songName: String
    let artistName: String
    let albumName: String
    let albumID: String
    let trackID: String
}

struct AlbumImages: Decodable {
    let height: Int
    let url: String
    let width: Int
}

struct SpotDevices: Decodable {
    let devices: [SpotDevice]
}

struct SpotDevice: Decodable {
    let id: String
    let type: String
}

struct CallBackURL: Decodable {
    let url: String
}

struct SpotAuthCode: Decodable {
    let code: String
}

struct SpotTokenResponse: Decodable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Double
}


struct SpotPlayBackState: Decodable {
    let is_playing: Bool
}

struct QueueResponse: Decodable {
    let queue: [QueueItem]
}
struct QueueItem: Decodable {
    let id: String
}

struct SpotProfile: Decodable {
    let id: String
}


struct SpotPlaylist: Decodable {
    let id: String
    let name: String
}

struct PlaylistArray: Decodable {
    let items: [SpotPlaylist]
}

struct SnapShotID: Decodable {
    let snapshot_id: String
}


struct SpotifyAlbumResponse: Codable {
    let albums: SpotifyAlbums
}

struct SpotifyAlbums: Codable {
    let items: [SpotifyAlbum]
}

struct SpotifyAlbum: Codable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    //let images: [SpotifyImage]
    //let tracks: SpotifyTracks

    enum CodingKeys: String, CodingKey {
        case id, name, artists
    }
}

struct SpotifyArtist: Codable {
    let name: String
}

struct SpotifyImage: Codable {
    let url: String
}

struct SpotifyTracks: Codable {
    let items: [SpotifyTrack]
}

struct SpotifyTrack: Codable {
    let id: String
    let name: String
    let durationMs: Int

    enum CodingKeys: String, CodingKey {
        case id, name, durationMs = "duration_ms"
    }
}
