//
//  PhotoAPI.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import UIKit
import SwiftUI


class PhotoAPI {
    enum Endpoints {
        case collection(apiKey: String, page_num: Int, collectionID: String)
        case pingDownloadForTrigger(apiKey: String, downloadLocation: String)
        case user(apiKey: String, user: String)
        case collectionPhotos(apiKey: String, collectionID: String, page_num: Int)
        var URLString: String {
            switch self {
            case .pingDownloadForTrigger(let apiKey, let downloadLocation):
                return downloadLocation + "&client_id=\(apiKey)"
            case .collection(let apiKey, let page_num, let collectionID):
                return "https://api.unsplash.com/search/photos?id=\(collectionID)&page=\(page_num)&per_page=50&client_id=\(apiKey)"
            case .user(let apiKey, let user):
                return "https://api.unsplash.com/users/\(user)/collections?client_id=\(apiKey)"
            case .collectionPhotos(let apiKey, let collectionID, let page_num):
                return "https://api.unsplash.com/collections/\(collectionID)/photos?page=\(page_num)&per_page=100&client_id=\(apiKey)"
            }
        }
        var url: URL{ return URL(string: URLString)!}
    }
    class func getUserCollections(username: String, completionHandler: @escaping ([PhotoCollection]?,Error?) -> Void) {
        let url = Endpoints.user(apiKey: APIManager.shared.unsplashAPIKey, user: username).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {completionHandler(nil, error)}
                return
            }
            do {
                let collections = try JSONDecoder().decode([PhotoCollection].self, from: data!)
                DispatchQueue.main.async {completionHandler(collections, nil)}
                }
            catch {
                print("Request failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {completionHandler(nil, error)}
                }
            }
        )
        task.resume()
    }
    
    class func getPhotosFromCollection(collectionID: String, page_num: Int, completionHandler: @escaping ([ResultDetails]?,Error?) -> Void) {
        let url = Endpoints.collectionPhotos(apiKey: APIManager.shared.unsplashAPIKey, collectionID: collectionID, page_num: page_num).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {completionHandler(nil, error)}
                return
            }
            do {
                let pics = try JSONDecoder().decode([ResultDetails].self, from: data!)
                DispatchQueue.main.async {completionHandler(pics, nil)}
                }
            catch {
                print("Request failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {completionHandler(nil, error)}
                }
            }
        )
        task.resume()
    }
    
    //Must make this a class func in order to call the function properly in ImportPhotoViewController
    class func getCollection(pageNum: Int, collectionID: String, completionHandler: @escaping ([ResultDetails]?,Error?) -> Void) {
        let pageNumber = pageNum
        //let url = URL(string: "https://api.unsplash.com/search/photos?query=\(user_search)/?client_id=\(apiKey)")!
        let url = Endpoints.collection(apiKey: APIManager.shared.unsplashAPIKey, page_num: pageNumber, collectionID: collectionID).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        // URLSession is the manager of the requests the app will perform
        // Create a dataTask, accepting 2 parameters: a URL and a completion Handler
        // The completion handler (a closure) is executed when the data task completes
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error)
            // Completion Handler is Below
             in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            do {
                // Create JSONDecoder instance and invoke decode function, passing in type of value to decode from the supplied JSON object and the JSON object to decode
                let pics = try JSONDecoder().decode(PicResponse.self, from: data!)
                if pics.results.count == 0 {}
                    DispatchQueue.main.async {
                        completionHandler(pics.results, nil)
                   }
                }
                catch {
                    print("Request failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
            }
        })
       task.resume()
}
    
    class func pingDownloadURL(downloadLocation: String, completionHandler: @escaping (PingDownloadResponse?,Error?) -> Void) {
        
        let urlString = Endpoints.pingDownloadForTrigger(apiKey: APIManager.shared.unsplashAPIKey, downloadLocation: downloadLocation)
        let url = urlString.url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error)
            // Completion Handler is Below
            in
            if error != nil {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            do {
                // Create JSONDecoder instance and invoke decode function, passing in type of value to decode from the supplied JSON object and the JSON object to decode
                let pingStatus = try JSONDecoder().decode(PingDownloadResponse.self, from: data!)
                    DispatchQueue.main.async {
                        completionHandler(pingStatus, nil)
                   }
                }
                catch {
                    print("Request failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
            }
        })
       task.resume()
    }

}
