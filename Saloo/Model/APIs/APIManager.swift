//
//  APIManager.swift
//  Saloo
//
//  Created by Sam Black on 12/16/23.
//

import Foundation
import UIKit
import SwiftUI
import CloudKit
import Network
import Security
import MessageUI
import MSAL
class APIManager: ObservableObject {
    static let shared = APIManager()
    @Published var unsplashAPIKey = String()
    var unsplashSecretKey = String()
    var spotSecretKey = String()
    var spotClientIdentifier = String()
    var appleMusicDevToken = String()
    var keys: [String: String] = [:]
    var httpAuthToken: String?

    init() {
        DispatchQueue.global(qos: .background).async {
            self.getSecret(keyName: "unsplashAPIKey", forceGetFromAzure: nil) { keyval in
                DispatchQueue.main.async {
                    self.unsplashAPIKey = keyval ?? ""
                    CollectionManager.shared.createOccassionsFromUserCollections()
                }
            }
        }
    }

    func getSecret(keyName: String, forceGetFromAzure: Bool?, completion: @escaping (String?) -> Void) {
        let fullURL = Config.shared.keysURL + "?keyName=\(keyName)"
        guard let url = URL(string: fullURL) else {
            fatalError("Invalid URL")
        }

        // First, try to get the key from the keychain
        if let storedKey = loadFromKeychain(key: keyName), forceGetFromAzure != true {
            print("Key found in Keychain for \(keyName). Verifying...")
            verifyAPIKey(keyName: keyName, apiKey: storedKey) { isValid in
                if isValid {
                    print("Keychain key for \(keyName) is valid.")
                    completion(storedKey)
                } else {
                    print("Keychain key for \(keyName) is invalid. Fetching from Azure...")
                    self.fetchAndUpdateKeyFromAzure(url: url, keyName: keyName, completion: completion)
                }
            }
        } else {
            // If the key is not in the keychain or forceGetFromAzure is true, fetch it from Azure
            print("Key not found in Keychain for \(keyName) or forceGetFromAzure is true. Fetching from Azure...")
            self.fetchAndUpdateKeyFromAzure(url: url, keyName: keyName, completion: completion)
        }
    }

    func fetchAndUpdateKeyFromAzure(url: URL, keyName: String, completion: @escaping (String?) -> Void) {
        self.fetchSecretFromURL(url: url) { value in
            if let value = value {
                self.saveToKeychain(key: keyName, value: value)
                completion(value)
            } else {
                completion(nil)
            }
        }
    }

    func verifyAPIKey(keyName: String, apiKey: String, completion: @escaping (Bool) -> Void) {
        switch keyName {
        case "appleMusicDevToken":
            verifyAppleMusicDevToken(apiKey: apiKey, completion: completion)
        case "unsplashAPIKey":
            verifyUnsplashAPIKey(apiKey: apiKey, completion: completion)
        case "spotClientIdentifier":
            // Fetch the other key (spotSecretKey) from the keychain or wherever it's stored
            if let clientSecret = loadFromKeychain(key: "spotSecretKey") {
                verifySpotifyKey(clientId: apiKey, clientSecret: clientSecret, completion: completion)
            } else {
                completion(false)
            }
        case "spotSecretKey":
            // If verifying the secret key, you need the client identifier
            if let clientId = loadFromKeychain(key: "spotClientIdentifier") {
                verifySpotifyKey(clientId: clientId, clientSecret: apiKey, completion: completion)
            } else {
                completion(false)
            }
        default:
            completion(false)
        }
    }
    
    func fetchSecretFromURL(url: URL, completion: @escaping (String?) -> Void) {
        var request = URLRequest(url: url)
        // Encoding username and password for Basic Auth
        let loginString = String(format: "%@:%@", Config.shared.basicAuthUser, Config.shared.basicAuthPassword)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        // Adding Basic Auth to request header
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Perform the network request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            // Attempt to decode the JSON response
            do {
                let json = try JSONDecoder().decode([String: String].self, from: data)
                if let value = json["value"] {
                    completion(value)
                } else {
                    print("No value found in response")
                    completion(nil)
                }
            } catch {
                print("JSON decoding error: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }


    func saveToKeychain(key: String, value: String) {
        let keyData = key.data(using: .utf8)!
        let valueData = value.data(using: .utf8)!
        
        // First delete any existing items with the same key
        let deleteQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                          kSecAttrAccount as String: keyData]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Then add the new item
        let addQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: keyData,
                                       kSecValueData as String: valueData]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save data to Keychain")
            return
        }
    }


    func loadFromKeychain(key: String) -> String? {
        let keyData = key.data(using: .utf8)!
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: keyData,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Failed to load data from Keychain")
            return nil
        }
        
        let valueData = item as! Data
        return String(data: valueData, encoding: .utf8)
    }
    
    func initializeAM(completion: @escaping () -> Void) {
        self.getSecret(keyName: "appleMusicDevToken", forceGetFromAzure: false) { keyval in
            if let keyValue = keyval {
                print("Received key from initial getSecret call.")
                DispatchQueue.main.async {
                    self.appleMusicDevToken = keyValue
                    completion()
                }
            } else {
                print("Initial getSecret call failed. Trying with forceGetFromAzure.")
                self.getSecret(keyName: "appleMusicDevToken", forceGetFromAzure: true) { keyval2 in
                    DispatchQueue.main.async {
                        self.appleMusicDevToken = keyval2 ?? ""
                        completion()
                    }
                }
            }
        }
    }
    
    func initializeSpotifyManager(completion: @escaping () -> Void) {
        // Here, you're getting the keys for Spotify API
        DispatchQueue.global(qos: .background).async {
            self.getSecret(keyName: "spotClientIdentifier", forceGetFromAzure: false) { keyval in
                DispatchQueue.main.async {
                self.spotClientIdentifier = keyval!
                    self.getSecret(keyName: "spotSecretKey", forceGetFromAzure: false){keyval in
                        self.spotSecretKey = keyval!
                        SpotifyManager.shared.initializeConfiguration()
                        completion()
                    }
                }
            }
        }
    }
    
    func verifyAppleMusicDevToken(apiKey: String, completion: @escaping (Bool) -> Void) {
        let testURL = URL(string: "https://api.music.apple.com/v1/catalog/us/songs/203709340")!

        var request = URLRequest(url: testURL)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }
        task.resume()
    }

    func verifyUnsplashAPIKey(apiKey: String, completion: @escaping (Bool) -> Void) {
        let testURL = URL(string: Config.shared.unsplashAuthURL)!

        var request = URLRequest(url: testURL)
        request.addValue("Client-ID \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }
        task.resume()
    }

    func verifySpotifyKey(clientId: String, clientSecret: String, completion: @escaping (Bool) -> Void) {
        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
        let credentials = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    func checkUserBanned(userId: String, completion: @escaping (Bool, Error?) -> Void) {

        let urlString = "\(Config.shared.userStatusURL)/is_banned?user_id=\(userId)"
          guard let url = URL(string: urlString) else {
              print("Invalid URL")
              completion(false, nil)
              return
          }

          var request = URLRequest(url: url)

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    // Handle error
                    completion(false, error)
                    return
                }
                
                if let data = data {
                    do {
                        if let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let value: Optional<Any> = responseDict["is_banned"]
                            if let stringValue = value as? String {
                                let stringValue2 = stringValue.lowercased()
                                if let isBanned = Bool(stringValue2) {
                                    completion(isBanned, nil)
                                    return
                                }
                            }
                        }
                    }
                    catch {
                        // Handle JSON parsing error
                        completion(false, error)
                        return
                    }
                }
                
                // Invalid response or data
                completion(false, nil)
            }
            task.resume()
        }
    
    func createUser(userID: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "\(Config.shared.userStatusURL)/create_user"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["user_id": userID]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("JSON serialization error: \(error)")
            completion(false, error)
            return
        }

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    // Handle network error
                    print("Network error: \(error)")
                    completion(false, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    // Handle invalid response
                    print("Invalid response")
                    completion(false, nil)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    // User created successfully
                    print("User Created Successfully")
                    completion(true, nil)
                } else {
                    // Handle non-200 status code
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                    completion(false, error)
                }
            }
            
            task.resume()
        }
}


struct ContentModerator {
    
    static let endpoint = Config.shared.contentModEndpoint
    static let uriBase = endpoint + Config.shared.contentModURIBase
    
    static func checkImageForExplicitContent(imageBase64: String, completion: @escaping (Bool?, Error?) -> Void) {
        guard let url = URL(string: uriBase) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        guard let imageData = Data(base64Encoded: imageBase64) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert base64 string to Data"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = imageData
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.addValue(Config.shared.contentModSubKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let isImageAdultClassified = json["AdultClassificationScore"] as? Double,
                   let isImageRacyClassified = json["RacyClassificationScore"] as? Double {
                    let isExplicitContent = isImageAdultClassified > 0.98 || isImageRacyClassified > 0.99
                    completion(isExplicitContent, nil)
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
                    completion(nil, error)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
