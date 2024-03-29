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
    let coreCard = CoreCard(context: PersistenceController.shared.persistentContainer.viewContext)
    var whichBoxForCKAccept: InOut.SendReceive?
    var gotRecord = false
    var connectToScene = true
    var checkIfRecordAddedToStore = true
    var waitingToAcceptRecord = false
    @ObservedObject var appDelegate = AppDelegate()
    @ObservedObject var networkMonitor = NetworkMonitor()
    let defaults = UserDefaults.standard
    var counter = 0
    var launchedURL: URL?
    var spotifyManager: SpotifyManager?
    var isColdStart = true
    var pendingURL: URL?

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let path = components.path else {
            return
        }
        // Additional logic to handle the uniqueName parameter
        if let queryItems = components.queryItems,
           let uniqueNameItem = queryItems.first(where: { $0.name == "uniqueName" }),
           let uniqueName = uniqueNameItem.value {
            print("FetchRecord in continue called")
            fetchRecord(withUniqueName: uniqueName)
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("called willconnectto")
        // Check if the app launched from an inactive state with a URL
        if let urlContext = connectionOptions.urlContexts.first {
            if urlContext.url.scheme == "saloo" {
                let uniqueName = urlContext.url.absoluteString.replacingOccurrences(of: "saloo://", with: "")
                if !uniqueName.isEmpty {self.pendingURL = urlContext.url}
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if url.absoluteString == "spotify://" {
                SpotifyManager.shared.gotToAppInAppStore = true
                return
            }
            else if url.scheme == "saloo" && !url.absoluteString.contains("spotify") {
                self.pendingURL = url
                return
            }
            let container = CKContainer.default()
            container.fetchShareMetadata(with: url) { metadata, error in
                guard error == nil, let metadata = metadata else {
                    print("An error occurred: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
            }
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Handle the URL if one was stored when the app was launched
        if let url = launchedURL, let windowScene = scene as? UIWindowScene {
            launchedURL = nil
        }
        if let url = pendingURL {
            self.handleIncomingURL(url)
            pendingURL = nil
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "saloo",
              let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }

        if let uniqueNameItem = queryItems.first(where: { $0.name == "uniqueName" }),
           let uniqueName = uniqueNameItem.value {
            print("FETCHRECORD in handleIncomingURL Called")
            self.fetchRecord(withUniqueName: uniqueName)
        }
    }
    
    
    func fetchAllCoreCards(completion: @escaping ([CKRecord]?, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 50
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

    
    func updateMusicSubType() {
        if (defaults.object(forKey: "MusicSubType") as? String) != nil  {
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
            if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
        }
    }
    
    func fetchRecord(withUniqueName uniqueName: String) {
        DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = true}
        let predicate = NSPredicate(format: "CD_uniqueName == %@", uniqueName)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        let publicDatabase = PersistenceController.shared.cloudKitContainer.publicCloudDatabase
        publicDatabase.perform(query, inZoneWith: nil) { results, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
            } else {
                if let results = results, !results.isEmpty {
                    for result in results {
                        self.parseRecord(record: result)
                    }}
                else {print("No matching record found.")
                    DispatchQueue.main.async{
                        GettingRecord.shared.isLoadingAlert = false
                        AlertVars.shared.alertType = .cardDoesntExist
                        AlertVars.shared.activateAlert = true
                    }
                    
                }
            }
        }
    }
    
    private func displayCard(windowScene: UIWindowScene, record: CKRecord, uniqueName: String) {
        guard self.gotRecord && self.connectToScene else { return }
        if self.appDelegate.musicSub.type == .Neither {self.updateMusicSubType()}
        CardsForDisplay.shared.addCoreCard(card: self.coreCard, box: self.whichBoxForCKAccept!, record: record)
        DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = false}
        AppState.shared.cardFromShare = self.coreCard
        self.gotRecord = false
    }
    
    func parseRecord(record: CKRecord?) {
        DispatchQueue.main.async() {
            self.getCurrentUserID()
            self.coreCard.occassion = record?.object(forKey: "CD_occassion") as! String
            self.coreCard.recipient = record?.object(forKey: "CD_recipient") as! String
            self.coreCard.sender = record?.object(forKey: "CD_sender") as? String
            self.coreCard.an1 = record?.object(forKey: "CD_an1") as! String
            self.coreCard.an2 = record?.object(forKey: "CD_an2") as! String
            self.coreCard.an2URL = record?.object(forKey: "CD_an2URL") as! String
            self.coreCard.an3 = record?.object(forKey: "CD_an3") as! String
            self.coreCard.an4 = record?.object(forKey: "CD_an4") as! String
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
            self.coreCard.salooUserID = record?.object(forKey: "CD_salooUserID") as! String
            self.coreCard.coverSizeDetails = record?.object(forKey: "CD_coverSizeDetails") as! String
            self.coreCard.unsplashImageURL = record?.object(forKey: "CD_unsplashImageURL") as! String
            CloudRecord.shared.theRecord = record
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            if let asset = record?["CD_collageAsset"] as? CKAsset {
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let collageData = try Data(contentsOf: asset.fileURL!)
                        DispatchQueue.main.async {
                            self.coreCard.collage = collageData
                            // Leave the group after the data is loaded
                            dispatchGroup.leave()
                        }
                    }
                    catch {
                        print("Failed to read data from CKAsset: \(error)")
                        // Be sure to leave the group even if an error occurs,
                        // otherwise app could hang indefinitely
                        dispatchGroup.leave()
                    }
                }
            }
            if self.coreCard.unsplashImageURL == "https://apps.apple.com/us/app/saloo-greetings/id6476240440" {
                dispatchGroup.enter()
                if let asset = record?["CD_coverImageAsset"] as? CKAsset {
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            let coverImageData = try Data(contentsOf: asset.fileURL!)
                            DispatchQueue.main.async {
                                self.coreCard.coverImage = coverImageData
                                self.determineWhichBox {}
                                // Leave the group after the data is loaded
                                dispatchGroup.leave()
                            }
                        }
                        catch {
                            print("Failed to read data from CKAsset: \(error)")
                            self.determineWhichBox {}
                            // Be sure to leave the group even if an error occurs,
                            // otherwise app could hang indefinitely
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            else {
                // Also enter the group before loading the image
                dispatchGroup.enter()
                
                ImageLoader.shared.loadImage(from: self.coreCard.unsplashImageURL!) { data in
                    DispatchQueue.main.async {
                        self.coreCard.coverImage = data
                        self.determineWhichBox {}
                        // Leave the group after the image is loaded
                        dispatchGroup.leave()
                    }
                }
            }

            // Use the notify method to schedule the displayCard method
            // to run after the data loading tasks are complete
            dispatchGroup.notify(queue: .main) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.gotRecord = true
                    self.checkIfRecordAddedToStore = true
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        self.displayCard(windowScene: windowScene, record: record!, uniqueName: self.coreCard.uniqueName)
                    }
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
        if self.coreCard.creator == thisUsersID {
            self.whichBoxForCKAccept = .outbox
            completion()
        }
        else {
            self.whichBoxForCKAccept = .inbox
            completion()
        }
      }
}

extension Notification.Name {
    static let didAcceptShare = Notification.Name("didAcceptShare")
}
