//
//  SpotifyAPI.swift
//  Saloo
//
//  Created by Sam Black on 1/29/23.
//

import StoreKit
import SwiftUI
import UIKit
import CoreData
import MediaPlayer
import Foundation

class SpotifyAPI {
    static let shared = SpotifyAPI()
    static let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string: "saloo://")!
    let cleanMusicData = CleanMusicData()
    @EnvironmentObject var appDelegate: AppDelegate
    let defaults = UserDefaults.standard

    lazy var configuration = SPTConfiguration(
        clientID: APIManager.shared.spotClientIdentifier,
        redirectURL: redirectUri
    )
    
    func searchSpotify(_ songName: String!, artistName: String!, authToken: String,  completionHandler: @escaping ([SpotItem]?,Error?) -> Void) -> [SongForList] {
        let songs = [SongForList]()
        let songNameClean = cleanMusicData.cleanMusicString(input: songName, removeList: AppDelegate().songFilterForSearchRegex).replacingOccurrences(of: " ", with: "%20")
        let artistNameClean = cleanMusicData.cleanMusicString(input: artistName, removeList: AppDelegate().songFilterForSearchRegex).replacingOccurrences(of: " ", with: "%20")
        let spotURL = URL(string:"https://api.spotify.com/v1/search?q=\(songNameClean)+\(artistNameClean)&type=track&market=ES&limit=50&offset=0")
        var spotRequest = URLRequest(url: spotURL!)
        spotRequest.httpMethod = "GET"
        spotRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        spotRequest.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: spotRequest) { (data, response, error) in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            }
            do {
                let songResponse = try JSONDecoder().decode(SpotResponse.self, from: data!)
                DispatchQueue.main.async {completionHandler(songResponse.tracks.items, nil)}
            }
            catch {
                print("Request failed: \(error)")
                DispatchQueue.main.async {completionHandler(nil, error)}
            }
        }.resume()
        return songs
    }
    
    func getAlbumIDUsingNameOnly(albumName: String, offset: Int?, authToken: String,   completion: @escaping ([SpotifyAlbum]?, Error?) -> Void) {
        let formattedAlbumName = cleanMusicData.cleanMusicString(input: albumName, removeList: AppDelegate().songFilterForMatchRegex).replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.spotify.com/v1/search?q=album:\(formattedAlbumName)%20&type=album&market=US&offset=\(offset!)&limit=50"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let task = try URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            }
            do {
                let decoder = JSONDecoder()
                let albums = try decoder.decode(SpotifyAlbumResponse.self, from: data!)
                completion(albums.albums.items, error)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func searchForAlbum(albumId: String, authToken: String, completionHandler: @escaping (AlbumData?, Error?) -> Void) {
        let url = "https://api.spotify.com/v1/albums/\(albumId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            }
            
            do {
                let decoder = JSONDecoder()
                let album = try decoder.decode(AlbumData.self, from: data!)
                completionHandler(album, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
        
        task.resume()
    }

    func getAlbumID(albumName: String, artistName: String, authToken: String,   completion: @escaping ([SpotifyAlbum]?, Error?) -> Void) {
        
        var formattedAlbumName = cleanMusicData.cleanMusicString(input: albumName, removeList: AppDelegate().songFilterForSearchRegex).replacingOccurrences(of: " ", with: "%20")
        var formattedArtistName = cleanMusicData.cleanMusicString(input: artistName, removeList: AppDelegate().songFilterForSearchRegex).replacingOccurrences(of: " ", with: "%20")
        do {
            var urlString = "https://api.spotify.com/v1/search?q=album:\(formattedAlbumName)%20artist:\(formattedArtistName)&type=album&market=US&limit=50"
            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "GET"
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            let session = URLSession.shared
            let task = try session.dataTask(with: request) { (data, response, error) in
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                }
                
                do {
                    let albums = try JSONDecoder().decode(SpotifyAlbumResponse.self, from: data!)
                    DispatchQueue.main.async {completion(albums.albums.items, nil)}
                } catch let error {
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        completion(nil, error)
                    }
                    
                }
            }
            task.resume()
        }
    }
    
    func generateIncrementList(A: Int, B: Int) -> [Int] {
        var list: [Int] = []
        let increment = A
        var currentIncrement = A
        while currentIncrement <= B {
            list.append(currentIncrement)
            currentIncrement += increment
        }
        return list
    }

    func getAlbumTracks(albumId: String, authToken: String, completion: @escaping ([SpotItem]?, Error?) -> Void) {
        var tracksList: [SpotItem] = []; var totalTracks: Int?; var offsetList: [Int] = []
        let urlString = "https://api.spotify.com/v1/albums/\(albumId)/tracks?limit=50"

        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                totalTracks = (jsonObj["total"] as? Int)!
            }
            do {
                let songResponse = try JSONDecoder().decode(Tracks.self, from: data!)
                tracksList.append(contentsOf: songResponse.items)
                offsetList = generateIncrementList(A: songResponse.items.count, B: totalTracks!)
                if offsetList[0] < 50 {
                    offsetList.remove(at: 0)
                }
                let dispatchGroup = DispatchGroup()
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                if offsetList.count > 0 {
                    let dispatchGroup = DispatchGroup()
                    dispatchGroup.enter()
                    let maxLimit = 50
                    let limit = min(offsetList.last! + 20 - offsetList[0], maxLimit)
                    let urlString = "https://api.spotify.com/v1/albums/\(albumId)/tracks?offset=\(offsetList[0])&limit=50"
                    guard let url = URL(string: urlString) else {
                        dispatchGroup.leave()
                        completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                        return
                    }
                    var request2 = URLRequest(url: url)
                    request2.httpMethod = "GET"
                    request2.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                    let task2 = URLSession.shared.dataTask(with: request2) { (data2, response2, error2) in
                        defer { dispatchGroup.leave() }
                        do {
                            let songResponse = try JSONDecoder().decode(Tracks.self, from: data2!)
                            tracksList.append(contentsOf: songResponse.items)
                            DispatchQueue.main.async {completion(tracksList, nil)}
                        }
                        catch {
                            print(error2)
                            DispatchQueue.main.async {completion(nil, error2)}
                        }
                    }
                    task2.resume()
                }
                else {
                    print("Completion called for one set of tracks for the album.")
                    DispatchQueue.main.async {completion(tracksList, nil)}}
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            }
            catch {
                print(error)
                DispatchQueue.main.async {completion(nil, error)}
            }
        }
        task.resume()
    }
        
        func getTokenViaRefresh(refresh_token: String, completionHandler: @escaping (SpotTokenResponse?,Error?) -> Void) {
            let auth_val = Data("\(APIManager.shared.spotClientIdentifier):\(APIManager.shared.spotSecretKey)".utf8).base64EncodedString()
            let spotURL = URL(string:"https://accounts.spotify.com/api/token")
            var components = URLComponents(url: spotURL!, resolvingAgainstBaseURL: false)
            let queryGrant = URLQueryItem(name: "grant_type", value: "refresh_token")
            let queryCode = URLQueryItem(name: "refresh_token", value: refresh_token)
            let queryRedirect = URLQueryItem(name: "redirect_uri", value: "https://salooapp.com")
            components!.queryItems = [queryGrant, queryCode, queryRedirect]
            var spotRequest = URLRequest(url: (components?.url!)!)
            spotRequest.httpMethod = "POST"
            spotRequest.setValue("Basic \(auth_val)", forHTTPHeaderField: "Authorization")
            spotRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: spotRequest) { (data, response, error) in
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
                print(String(data: data!, encoding: .utf8) ?? "no data")
                if error != nil {
                    DispatchQueue.main.async {completionHandler(nil, error)}
                    return
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let tokenResponse = try JSONDecoder().decode(SpotTokenResponse.self, from: data)
                        DispatchQueue.main.async {completionHandler(tokenResponse, nil)
                        }}
                    catch {
                        print("Request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {completionHandler(nil, error)}
                    }
                }
            }
            .resume()
        }
        
    
    func getCurrentUserProfile(accessToken: String, completionHandler: @escaping (SpotProfile?, Error?) -> Void) {
        
        let urlString = "https://api.spotify.com/v1/me"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    print("Error...\(error.localizedDescription)")
                    completionHandler(nil, error)
                }
                return
            }
            
            if let data = data {
                do {
                    let profile = try JSONDecoder().decode(SpotProfile.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(profile, nil)
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey : "No data received from server"]))
                }
            }
        }
        task.resume()
    }

        func getToken(authCode: String, completionHandler: @escaping (SpotTokenResponse?,Error?) -> Void) {
            let auth_val = Data("\(APIManager.shared.spotClientIdentifier):\(APIManager.shared.spotSecretKey)".utf8).base64EncodedString()
            let spotURL = URL(string:"https://accounts.spotify.com/api/token")
            var components = URLComponents(url: spotURL!, resolvingAgainstBaseURL: false)
            let queryGrant = URLQueryItem(name: "grant_type", value: "authorization_code")
            let queryCode = URLQueryItem(name: "code", value: authCode)
            let queryRedirect = URLQueryItem(name: "redirect_uri", value: "https://salooapp.com")
            components!.queryItems = [queryGrant, queryCode, queryRedirect,queryRedirect]
            print(components!.url)
            var spotRequest = URLRequest(url: (components?.url!)!)
            spotRequest.httpMethod = "POST"
            spotRequest.setValue("Basic \(auth_val)", forHTTPHeaderField: "Authorization")
            spotRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: spotRequest) { (data, response, error) in
                if error != nil {
                    print("[[[Error not nil....]")
                    DispatchQueue.main.async {completionHandler(nil, error)}
                    return
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let tokenResponse = try JSONDecoder().decode(SpotTokenResponse.self, from: data)
                        DispatchQueue.main.async {completionHandler(tokenResponse, nil)
                        }}
                    catch {
                        print("Request failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {completionHandler(nil, error)}
                    }
                }
            }
            .resume()
        }
        
        func requestAuth(completionHandler: @escaping (String?,Error?) -> Void)  {
            let url = URL(string: "https://accounts.spotify.com/authorize?")
            var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
            let queryClientID = URLQueryItem(name: "client_id", value: APIManager.shared.spotClientIdentifier)
            let queryResponseType = URLQueryItem(name: "response_type", value: "code")
            let queryRedirect = URLQueryItem(name: "redirect_uri", value: "https://salooapp.com")
            let allScopes = URLQueryItem(name: "scope", value:"user-read-private user-read-playback-state app-remote-control streaming user-modify-playback-state user-read-currently-playing")
            components!.queryItems = [queryResponseType, queryClientID, queryRedirect, allScopes]
            var spotRequest = URLRequest(url: components!.url!)
            spotRequest.httpMethod = "GET"
            URLSession.shared.dataTask(with: spotRequest) { (data, response, error) in
                if error != nil {
                    DispatchQueue.main.async {completionHandler(nil, error)}
                    return
                }
                do {
                    DispatchQueue.main.async {completionHandler(response?.url!.absoluteString, nil)
                        
                    }}
                catch {
                    print("Request failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {completionHandler(nil, error)}
                }
            }
            .resume()
        }
    }
