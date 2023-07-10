//
//  SceneDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/4/23.
//

import Foundation
import UIKit
import CloudKit
import SwiftUI
import os.log


class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?
    @State var userID = String()
    var acceptedShare: CKShare?
    let coreCard = CoreCard(context: PersistenceController.shared.persistentContainer.newTaskContext())
    var whichBoxForCKAccept: InOut.SendReceive?
    var gotRecord = false
    var connectToScene = true
    var checkIfRecordAddedToStore = true
    var waitingToAcceptRecord = false
    @ObservedObject var appDelegate = AppDelegate()
    @ObservedObject var networkMonitor = NetworkMonitor()
    //var hideProgViewOnAcceptShare: Bool = true
    let defaults = UserDefaults.standard
    var counter = 0
    var launchedURL: URL?
    var spotifyManager: SpotifyManager?
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let path = components.path else {
            return
        }
        print("$$$$$$$$$$")
        print(userActivity.webpageURL)

        // Handle the universal link URL
        // Use the path to present appropriate content in your app
    }
    
    func fetchAllCoreCards(completion: @escaping ([CKRecord]?, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        //operation.desiredKeys = ["recordID", "CD_spotID", "CD_songID", "CD_songName"] // add all the keys you want to fetch
        operation.resultsLimit = 50 // Adjust this as needed
        
        var newRecords = [CKRecord]()
        
        // This block will be called for every record fetched
        operation.recordFetchedBlock = { record in
            newRecords.append(record)
        }
        
        // This block will be called when the operation is completed
        operation.queryCompletionBlock = { (cursor, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch records: \(error)")
                    completion(nil, error)
                } else {
                    print("Successfully fetched records")
                    completion(newRecords, nil)
                }
            }
        }
        
        let publicDatabase = PersistenceController.shared.cloudKitContainer.publicCloudDatabase
        publicDatabase.add(operation)
    }

    
    

    

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Handle the URL if one was stored when the app was launched
        if let url = launchedURL, let windowScene = scene as? UIWindowScene {
            print("Set scene in SceneDidBecomeActive")
            //self.displayCard(windowScene: windowScene)
            launchedURL = nil // Clear the stored URL
        }
    }

    
    func updateMusicSubType() {
        if (defaults.object(forKey: "MusicSubType") as? String) != nil  {
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("called* openURLContexts")
        guard let url = URLContexts.first?.url else { return }
        if url.absoluteString == "spotify://" {
            print("goToSpotInAppStore about to change")
            SpotifyManager.shared.gotToAppInAppStore = true
            return
        }
        else if url.scheme == "saloo" {
                let uniqueName = url.absoluteString.replacingOccurrences(of: "saloo://", with: "")
                if !uniqueName.isEmpty {
                    // handle uniqueName here
                    // use uniqueName to fetch the required information or do necessary action
                    print("***\(uniqueName)")
                    fetchRecord(withUniqueName: uniqueName)
                    //fetchAllCoreCards { (records, error) in
                     //   if let error = error {
                    //        // Handle error
                    //        print("&&&")
                    //        print(error.localizedDescription)
                     //   } else if let records = records {
                    //        for record in records {
                     //           print("%%%%")
                    //            print(record)
                     //       }
                     //   }
                    //}

                }
                return
            }


        let container = CKContainer.default()
        container.fetchShareMetadata(with: url) { metadata, error in
            guard error == nil, let metadata = metadata else {
                print("-----")
                print("An error occurred: \(error?.localizedDescription ?? "unknown error")")
                return
            }
        }
    }
    
    
    func fetchRecord(withUniqueName uniqueName: String) {
        print("called fetch")
        let predicate = NSPredicate(format: "CD_uniqueName == %@", uniqueName)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        let publicDatabase = PersistenceController.shared.cloudKitContainer.publicCloudDatabase
        print("pre-perform")
        publicDatabase.perform(query, inZoneWith: nil) { results, error in
            if let error = error {
                // Handle the error here
                print("An error occurred: \(error.localizedDescription)")
            } else {
                if let results = results, !results.isEmpty {
                    // Process your results here
                    for result in results {
                        // Do something with each result
                        print("THE RESULT")
                        print(result)
                    }
                } else {
                    print("No matching record found.")
                }
            }
        }
    }



    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("called* willConnectTo")
    }
}

extension Notification.Name {
    static let didAcceptShare = Notification.Name("didAcceptShare")
}
