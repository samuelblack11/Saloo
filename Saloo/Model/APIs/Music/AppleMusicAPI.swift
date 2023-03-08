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
//https://www.appcoda.com/musickit-music-api/
class AppleMusicAPI {
    var taskToken: String?
    var storeFrontID: String?
    let devToken = "eyJhbGciOiJFUzI1NiIsImtpZCI6Ik5KN0MzVzgzTFoiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJCU00zWVpGVVQyIiwiZXhwIjoxNjg5MjQzOTI3LCJpYXQiOjE2NzM0Nzk1Mjd9.28_a1GIJEEKWzvJgmdM9lAmvB4ilY5pFx6TF0Q4uhIIKu8FR0fOaXd2-3xVHPWANA8tqbLurVE5yE8wEZEqR8g"
    
    
    
    func fetchUserStorefront(userToken: String, completionHandler: @escaping (AMStoreFrontResponse?,Error?) -> Void) -> String{
        print("User Token...\(userToken)")
        let userStoreFront = String()
        let musicURL = URL(string: "https://api.music.apple.com/v1/me/storefront")!
        var musicRequest = URLRequest(url: musicURL)
        musicRequest.httpMethod = "GET"
        musicRequest.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
        musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
        let lock = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in

            guard error == nil else { return }
                let jsonString = String(data: data!, encoding: String.Encoding.utf8)!
                print("UserStoreFront....***")
                print(jsonString)
            do {
                let response = try JSONDecoder().decode(AMStoreFrontResponse.self, from: data!)
                print(";;;\(response)")
                DispatchQueue.main.async {completionHandler(response, nil)}
                }
            catch {
                print("Invalid Response")
                print("Request failed: \(error)")
                DispatchQueue.main.async {completionHandler(nil, error)}
                }
                lock.signal()
        }
        .resume()
        lock.wait()
        return userStoreFront
    }
    
    func getUserToken2() -> String {
        var taskToken = String()
        //let lock = DispatchSemaphore(value: 1)
        SKCloudServiceController().requestUserToken(forDeveloperToken: devToken) {(receivedToken, error) in
            guard error == nil else { return }
            if let token = receivedToken {
                taskToken = token;
                //lock.signal()
            }
        }
        //lock.wait()
        print("getUserToken.....\(taskToken)")
        return taskToken
    }
    
    func getUserToken() {
        let lock = DispatchSemaphore(value: 1)
        SKCloudServiceController().requestUserToken(forDeveloperToken: devToken) {(receivedToken, error) in
            guard error == nil else { return }
                print("receivedToken....\(receivedToken!)")
                self.taskToken = receivedToken!
                lock.signal()
        }
        lock.wait()
        //print("getUserToken.....\(self.taskToken!)")
    }
    
    
    
    func searchAppleMusic(_ searchTerm: String!, storeFrontID: String, userToken: String, completionHandler: @escaping ([Song]?,Error?) -> Void) -> [SongForList] {
            let lock = DispatchSemaphore(value: 1)
            let songs = [SongForList]()
            let musicURL = URL(string: "https://api.music.apple.com/v1/catalog/\(storeFrontID)/search?term=\(searchTerm.replacingOccurrences(of: " ", with: "+"))&types=songs&limit=25")
            var musicRequest = URLRequest(url: musicURL!)
            musicRequest.httpMethod = "GET"
            musicRequest.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            musicRequest.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else {return}
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    print("&&&")
                    print(jsonObj)
                }
                    do {
                    let songResponse = try JSONDecoder().decode(SongsReponse.self, from: data!)
                    DispatchQueue.main.async {completionHandler(songResponse.results.songs.data, nil)}
                    }
                catch {
                    print("Invalid Response")
                    print("Request failed: \(error)")
                    DispatchQueue.main.async {completionHandler(nil, error)}
                    }
                    lock.signal()
            }.resume()
        
        lock.wait()
        return songs
    }

}

extension String {
    //https://stackoverflow.com/questions/31725424/swift-get-string-between-2-strings-in-a-string
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    //https://stackoverflow.com/questions/32851720/how-to-remove-special-characters-from-string-in-swift-2
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
}
