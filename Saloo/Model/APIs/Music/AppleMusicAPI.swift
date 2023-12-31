//
//  AppleMusicAPI.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/11/23.
//
// helps us access lots of built in methods that can communicate with Apple Music API
import StoreKit
import SwiftUI
import UIKit
import CoreData
class AppleMusicAPI {
    var taskToken: String?
    var tokenError: Bool = false
    var storeFrontID: String?
    @EnvironmentObject var appDelegate: AppDelegate
    let cleanMusicData = CleanMusicData()

    func fetchUserStorefront(userToken: String, completionHandler: @escaping (AMStoreFrontResponse?,Error?) -> Void) -> String{
        let userStoreFront = String()
        let musicURL = URL(string: "https://api.music.apple.com/v1/me/storefront")!
        var musicRequest = URLRequest(url: musicURL)
        musicRequest.httpMethod = "GET"
        musicRequest.addValue("Bearer \(APIManager.shared.appleMusicDevToken)", forHTTPHeaderField: "Authorization")
        musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        let lock = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in

            guard error == nil else { return }
                let jsonString = String(data: data!, encoding: String.Encoding.utf8)!
            do {
                let response = try JSONDecoder().decode(AMStoreFrontResponse.self, from: data!)
                DispatchQueue.main.async {completionHandler(response, nil)}
                }
            catch {
                print("Request failed: \(error)")
                DispatchQueue.main.async {completionHandler(nil, error)}
                }
                lock.signal()
        }
        .resume()
        lock.wait()
        return userStoreFront
    }
    
    func getUserToken(completionHandler: @escaping (String?, Error?) -> Void) {
        print(APIManager.shared.appleMusicDevToken)
        
        SKCloudServiceController().requestUserToken(forDeveloperToken: APIManager.shared.appleMusicDevToken) { (receivedToken, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error getting user token: \(error.localizedDescription)")
                    // Handle the error more appropriately here
                    completionHandler(nil, error)
                } else if let receivedToken = receivedToken {
                    print("else if receivedToken called")
                    self.taskToken = receivedToken
                    completionHandler(receivedToken, nil)
                } else {
                    let error = NSError(domain: "YourErrorDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                    completionHandler(nil, error)
                }
            }
        }
    }


    
    
    
    func searchAppleMusic(_ searchTerm: String!, storeFrontID: String, userToken: String, completionHandler: @escaping ([Song]?,Error?) -> Void) -> [SongForList] {
            let lock = DispatchSemaphore(value: 1)
            let songs = [SongForList]()
            let musicURL = URL(string: "https://api.music.apple.com/v1/catalog/\(storeFrontID)/search?term=\(searchTerm.replacingOccurrences(of: " ", with: "+"))&types=songs&limit=25")
            var musicRequest = URLRequest(url: musicURL!)
            musicRequest.httpMethod = "GET"
            musicRequest.addValue("Bearer \(APIManager.shared.appleMusicDevToken)", forHTTPHeaderField: "Authorization")
            musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else {return}
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                }
                    do {
                    let songResponse = try JSONDecoder().decode(SongsReponse.self, from: data!)
                    DispatchQueue.main.async {completionHandler(songResponse.results.songs.data, nil)}
                    }
                catch {
                    print("Request failed: \(error)")
                    DispatchQueue.main.async {completionHandler(nil, error)}
                    }
                    lock.signal()
            }.resume()
        
        lock.wait()
        return songs
    }
    

    
    
    func searchForAlbum(albumAndArtist: String, storeFrontID: String, offset: Int?,  userToken: String, completion: @escaping (AlbumResponse?, Error?) -> Void) {
        // Set up the search query
        let lock = DispatchSemaphore(value: 1)
        let searchURL = "https://api.music.apple.com/v1/catalog/\(storeFrontID)/search"
        var searchTerm = cleanMusicData.compileMusicString(songOrAlbum: albumAndArtist, artist: nil, removeList: AppDelegate().songFilterForMatchRegex).replacingOccurrences(of: " ", with: "%20")
        let searchType = "albums"
        var fullURL = "\(searchURL)?term=\(searchTerm)&types=\(searchType)&limit=25"
        if let offset = offset {
            fullURL += "&offset=\(offset)"
        }
        // Set up the request
        var request = URLRequest(url: URL(string: fullURL)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(APIManager.shared.appleMusicDevToken)", forHTTPHeaderField: "Authorization")
        request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        // Send the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            }
            do {
                let response = try JSONDecoder().decode(AlbumResponse.self, from: data!)
                //print("@@@")
                //print(response.results.albums.data)
                DispatchQueue.main.async {completion(response, nil)}
            }
             catch {
                DispatchQueue.main.async {completion(nil, error)}
            }
            lock.signal()
        }.resume()
    }
    
    
    
    func getAlbumTracks(albumId: String, storefrontId: String, userToken: String,completion: @escaping (TrackResponse?, Error?) -> Void) {
        let lock = DispatchSemaphore(value: 1)
        let baseUrl = "https://api.music.apple.com/v1/catalog/\(storefrontId)/albums/\(albumId)/tracks"
        var request = URLRequest(url: URL(string: baseUrl)!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(APIManager.shared.appleMusicDevToken)", forHTTPHeaderField: "Authorization")
        request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            }
            do {
                let response = try JSONDecoder().decode(TrackResponse.self, from: data!)
                DispatchQueue.main.async {completion(response, nil)}
            }
             catch {
                DispatchQueue.main.async {completion(nil, error)}
            }
            lock.signal()
        }.resume()
    }
}

extension String {

    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }

    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
}
