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
                        self.parseRecord(record: result)
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
    
    private func displayCard(windowScene: UIWindowScene) {
        print("called* displayCard")
        guard self.gotRecord && self.connectToScene else { return }
        if self.appDelegate.musicSub.type == .Neither {self.updateMusicSubType()}
        //AppState.shared.currentScreen = .startMenu
        CardsForDisplay.shared.addCoreCard(card: self.coreCard, box: self.whichBoxForCKAccept!)
        AppState.shared.cardFromShare = self.coreCard
        self.gotRecord = false
    }
    
    
    
    func parseRecord(record: CKRecord?) {
        print("Parsing Record....")
        print(record)
        print("--------")
        DispatchQueue.main.async() {
            
            print("^^^^")
            print(record?.object(forKey: "CD_collage") as? Data)
            self.getCurrentUserID()
            self.coreCard.occassion = record?.object(forKey: "CD_occassion") as! String
            self.coreCard.recipient = record?.object(forKey: "CD_recipient") as! String
            self.coreCard.sender = record?.object(forKey: "CD_sender") as? String
            self.coreCard.an1 = record?.object(forKey: "CD_an1") as! String
            self.coreCard.an2 = record?.object(forKey: "CD_an2") as! String
            self.coreCard.an2URL = record?.object(forKey: "CD_an2URL") as! String
            self.coreCard.an3 = record?.object(forKey: "CD_an3") as! String
            self.coreCard.an4 = record?.object(forKey: "CD_an4") as! String
            self.coreCard.collage = record?.object(forKey: "CD_collage") as? Data
            self.coreCard.coverImage = record?.object(forKey: "CD_coverImage") as? Data
            self.coreCard.date = record?.object(forKey: "CD_date") as! Date
            self.coreCard.font = record?.object(forKey: "CD_font") as! String
            self.coreCard.message = record?.object(forKey: "CD_message") as! String
            self.coreCard.songID = record?.object(forKey: "CD_songID") as? String
            self.coreCard.spotID = record?.object(forKey: "CD_spotID") as? String
            self.coreCard.songName = record?.object(forKey: "CD_songName") as? String
            self.coreCard.spotName = record?.object(forKey: "CD_spotName") as? String
            self.coreCard.songArtistName = record?.object(forKey: "CD_songArtistName") as? String
            self.coreCard.spotArtistName = record?.object(forKey: "CD_spotArtistName") as? String
            self.coreCard.songArtImageData = record?.object(forKey: "CD_songArtImageData") as? Data
            self.coreCard.songPreviewURL = record?.object(forKey: "CD_songPreviewURL") as? String
            self.coreCard.songDuration = record?.object(forKey: "CD_songDuration") as? String
            self.coreCard.inclMusic = record?.object(forKey: "CD_inclMusic") as! Bool
            self.coreCard.spotImageData = record?.object(forKey: "CD_spotImageData") as? Data
            self.coreCard.spotSongDuration = record?.object(forKey: "CD_spotSongDuration") as? String
            self.coreCard.spotPreviewURL = record?.object(forKey: "CD_spotPreviewURL") as? String
            self.coreCard.songAlbumName = record?.object(forKey: "CD_songAlbumName") as? String
            self.coreCard.spotAlbumArtist = record?.object(forKey: "CD_spotAlbumArtist") as? String
            self.coreCard.appleAlbumArtist = record?.object(forKey: "CD_appleAlbumArtist") as? String
            self.coreCard.creator = record?.object(forKey: "CD_creator") as? String
            self.coreCard.songAddedUsing = record?.object(forKey: "CD_songAddedUsing") as? String
            self.coreCard.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCard.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCard.cardType = record?.object(forKey: "CD_cardType") as! String
            self.coreCard.appleSongURL = record?.object(forKey: "CD_appleSongURL") as! String
            self.coreCard.spotSongURL = record?.object(forKey: "CD_spotSongURL") as! String
            self.coreCard.uniqueName = record?.object(forKey: "CD_uniqueName") as! String
            self.appDelegate.chosenGridCard = self.coreCard
            self.determineWhichBox {}
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.gotRecord = true
                self.checkIfRecordAddedToStore = true
                print("getRecord complete...")
                // Try to get the window scene from the shared application instance.
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    print("Trying to handle Display after parseRecord...")
                    self.displayCard(windowScene: windowScene)
                }
            }
        }
}
    
    func getCurrentUserID() {
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            self.userID = (ckRecordID?.recordName)!
        }
    }
    func determineWhichBox(completion: @escaping () -> Void) {
        let thisUsersID = self.defaults.object(forKey: "SalooUserID") as? String
        let controller = PersistenceController.shared
        let ckContainer = PersistenceController.shared.cloudKitContainer
        if self.coreCard.creator == thisUsersID {
            print("Creator = recordname")
            self.whichBoxForCKAccept = .outbox
            completion()
        }
        else {
            print("Creator != recordname")
            self.whichBoxForCKAccept = .inbox
            completion()
        }

        
        
        
          
      }
}

extension Notification.Name {
    static let didAcceptShare = Notification.Name("didAcceptShare")
}
