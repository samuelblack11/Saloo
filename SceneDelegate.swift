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


class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?
    //var musicSubTimeToAddMusic: Bool = false
    //var musicSubType: MusicSubscriptionOptions = .Neither
    //@EnvironmentObject var appDelegate: AppDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        // Create the SwiftUI view that provides the window contents.
        //let contentView = MusicSearchView()
        //print("called willConnectTo")

        // Use a UIHostingController as window root view controller.
       // if let windowScene = scene as? UIWindowScene {
       //     let window = UIWindow(windowScene: windowScene)
       //     window.rootViewController = UIHostingController(rootView: contentView)
        //    self.window = window
       //     window.makeKeyAndVisible()
       //}
        
        
        
       // let url = connectionOptions.urlContexts.first?.url
        //self.scene(scene, openURLContexts: url)

      
    }
    
    /**
     To be able to accept a share, add a CKSharingSupported entry in the Info.plist file and set it to true.
     */
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let persistenceController = PersistenceController.shared
        let sharedStore = persistenceController.sharedPersistentStore
        let container = persistenceController.persistentContainer
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore) { (_, error) in
            if let error = error {print("\(#function): Failed to accept share invitations: \(error)")}
            else {
                //let viewController: UIViewController = self.window?.rootViewController as! UIViewController
                //viewController.fetchShare(cloudKitShareMetadata)

                let acceptedECardView = self.window?.rootViewController as! EnlargeECardView()
                EnlargeECardView.fetchShare(cloudKitShareMetadata)
                
                
                
                
                
                
                // add card to inbox
                // display card via -> Inbox -> EnlargeECardView -> eCardView
                print("------")
                print(cloudKitShareMetadata.rootRecord?.object(forKey: "songName"))
                //EnlargeECardView(chosenCard: , share: , cardsForDisplay: persistenceController., whichBoxVal: .inbox)
                //if owner of card, whichBoxVal: .outbox. Else, .inbox
            }
        }
    }
    
    
    func fetchShare(_ metadata: CKShare.Metadata) {

        let operation = CKFetchRecordsOperation(
            recordIDs: [metadata.rootRecordID])
        operation.perRecordCompletionBlock = { record, _, error in
            if error != nil { print(error?.localizedDescription)}

            if record != nil {
                DispatchQueue.main.async() {
                    self.associatedRecord = record
                    self.cardName = record?.object(forKey: "cardName") as? String
                    self.occassion = record?.object(forKey: "occassion") as? String
                    self.recipient = record?.object(forKey: "recipient") as? String
                    self.sender = record?.object(forKey: "sender") as? String
                    self.an1 = record?.object(forKey: "an1") as? String
                    self.an2 = record?.object(forKey: "an2") as? String
                    self.an2URL = record?.object(forKey: "an2URL") as? String
                    self.an3 = record?.object(forKey: "an3") as? String
                    self.an4 = record?.object(forKey: "an4") as? String
                    self.collage = record?.object(forKey: "collage") as? Data
                    self.coverImage = record?.object(forKey: "coverImage") as? Data
                    self.date = record?.object(forKey: "date") as? Date
                    self.font = record?.object(forKey: "font") as? String
                    self.message = record?.object(forKey: "message") as? String
                    self.chosenSong = record?.object(forKey: "chosenSong") as? Data
                    self.songID = record?.object(forKey: "songID") as? String
                    self.spotID = record?.object(forKey: "spotID") as? String
                    self.songName = record?.object(forKey: "songName") as? String
                    self.songArtistName = record?.object(forKey: "songArtistName") as? String
                    self.songArtImageData = record?.object(forKey: "songArtImageData") as? String
                    self.songPreviewURL = record?.object(forKey: "songPreviewURL") as? String
                    self.songDuration = record?.object(forKey: "songDuration") as? String
                    self.inclMusic = record?.object(forKey: "inclMusic") as? Bool
                    self.spotImageData = record?.object(forKey: "spotImageData") as? Data
                    self.spotSongDuration = record?.object(forKey: "spotSongDuration") as? String
                    self.spotPreviewURL = record?.object(forKey: "spotPreviewURL") as? String
                }
            }
        }

        operation.fetchRecordsCompletionBlock = { _, error in
            if error != nil { print(error?.localizedDescription)}
        }
        CKContainer.default().sharedCloudDatabase.add(operation)
    }

}
