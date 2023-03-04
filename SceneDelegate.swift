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
    //@State var coreCard: CoreCard?
    @State var ckShare: CKShare?
    @State var userID = String()
    @EnvironmentObject var appDelegate: AppDelegate
    @State var acceptedShare: CKShare?
    @State var coreCard: CoreCard?
    //var musicSubTimeToAddMusic: Bool = false
    //var musicSubType: MusicSubscriptionOptions = .Neither
    //@EnvironmentObject var appDelegate: AppDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        
        
        
        //self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        // Create the SwiftUI view that provides the window contents.

        // Use a UIHostingController as window root view controller.
        //if let windowScene = scene as? UIWindowScene {
        //    let contentView = EnlargeECardView(chosenCard: coreCard!, share: $ckShare, cardsForDisplay: [], whichBoxVal: .inbox)
        //    print("called willConnectTo")
        //    let window = UIWindow(windowScene: windowScene)
         ///   window.rootViewController = UIHostingController(rootView: contentView)
         //   self.window = window
         //   window.makeKeyAndVisible()
        
        
        
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
        let ckContainer = persistenceController.cloudKitContainer
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore) { [self] (_, error) in
            if let error = error {print("\(#function): Failed to accept share invitations: \(error)")}
            else {
                print("CKShareMetaData Code...")
                print(cloudKitShareMetadata.share)
                print("----")
                print(cloudKitShareMetadata.share.recordID)
                print("***")
                print(cloudKitShareMetadata.share.recordID.zoneID)
                print("[[[[")
                print(cloudKitShareMetadata.share.recordID.zoneID.zoneName)
                
                let pred = NSPredicate(value: true)
                let query = CKQuery(recordType: "CD_CoreCard", predicate: pred)
                let op3 = CKQueryOperation(query: query)
                op3.zoneID = cloudKitShareMetadata.share.recordID.zoneID//.zoneName
                op3.recordMatchedBlock = {recordID, result in
                    print("Got Record...")
                    print(recordID)
                }
                op3.queryResultBlock = {result in
                    
                    print(result)

                    
                    print("queryResultBlock Called")
                    
                }
                ckContainer.sharedCloudDatabase.add(op3)
                print("Query Complete...")
            }
        }
    }
    
    
    
    
    
    
    
    func acceptShare(metadata: CKShare.Metadata,
        completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        
        // Create a reference to the share's container so the operation
        // executes in the correct context.
        let container = CKContainer(identifier: metadata.containerIdentifier)
        
        // Create the operation using the metadata the caller provides.
        let operation = CKAcceptSharesOperation(shareMetadatas: [metadata])
            
        var rootRecordID: CKRecord.ID!
        // If CloudKit accepts the share, cache the root record's ID.
        // The completion closure handles any errors.
        operation.perShareCompletionBlock = { metadata, share, error in
            if let _ = share, error == nil {
                rootRecordID = metadata.hierarchicalRootRecordID
            }
        }

        // If the operation fails, return the error to the caller.
        // Otherwise, return the record ID of the share's root record.
        operation.acceptSharesCompletionBlock = { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(rootRecordID))
            }
        }

        // Set an appropriate QoS and add the operation to the
        // container's queue to execute it.
        operation.qualityOfService = .utility
        container.add(operation)
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    func fetchShare(_ metadata: CKShare.Metadata) {
        print("333")
        
        print(metadata)
        
        metadata.rootRecord?.object(forKey: "cardName") as! String
        print(metadata.rootRecord)
        //metadata.share.owner
        print("4444")
        //print(metadata.hierarchicalRootRecordID!)
        print("555")
        //op3.zoneID = acceptedShare?.recordID.zoneID
        DispatchQueue.main.async() {
            self.coreCard?.cardName = metadata.rootRecord?.object(forKey: "cardName") as! String
            self.coreCard?.occassion = metadata.rootRecord?.object(forKey: "occassion") as! String
            self.coreCard?.recipient = metadata.rootRecord?.object(forKey: "recipient") as! String
            self.coreCard?.sender = metadata.rootRecord?.object(forKey: "sender") as? String
            self.coreCard?.an1 = metadata.rootRecord?.object(forKey: "an1") as! String
            self.coreCard?.an2 = metadata.rootRecord?.object(forKey: "an2") as! String
            self.coreCard?.an2URL = metadata.rootRecord?.object(forKey: "an2URL") as! String
            self.coreCard?.an3 = metadata.rootRecord?.object(forKey: "an3") as! String
            self.coreCard?.an4 = metadata.rootRecord?.object(forKey: "an4") as! String
            self.coreCard?.collage = metadata.rootRecord?.object(forKey: "collage") as? Data
            self.coreCard?.coverImage = metadata.rootRecord?.object(forKey: "coverImage") as? Data
            self.coreCard?.date = metadata.rootRecord?.object(forKey: "date") as! Date
            self.coreCard?.font = metadata.rootRecord?.object(forKey: "font") as! String
            self.coreCard?.message = metadata.rootRecord?.object(forKey: "message") as! String
            self.coreCard?.songID = metadata.rootRecord?.object(forKey: "songID") as? String
            self.coreCard?.spotID = metadata.rootRecord?.object(forKey: "spotID") as? String
            self.coreCard?.songName = metadata.rootRecord?.object(forKey: "songName") as? String
            self.coreCard?.songArtistName = metadata.rootRecord?.object(forKey: "songArtistName") as? String
            self.coreCard?.songArtImageData = metadata.rootRecord?.object(forKey: "songArtImageData") as? Data
            self.coreCard?.songPreviewURL = metadata.rootRecord?.object(forKey: "songPreviewURL") as? String
            self.coreCard?.songDuration = metadata.rootRecord?.object(forKey: "songDuration") as? String
            self.coreCard?.inclMusic = metadata.rootRecord?.object(forKey: "inclMusic") as! Bool
            self.coreCard?.spotImageData = metadata.rootRecord?.object(forKey: "spotImageData") as? Data
            self.coreCard?.spotSongDuration = metadata.rootRecord?.object(forKey: "spotSongDuration") as? String
            self.coreCard?.spotPreviewURL = metadata.rootRecord?.object(forKey: "spotPreviewURL") as? String
        }
        
    }
    
    func shareStatus(card: CoreCard) -> (Bool, Bool) {
        var isCardShared: Bool?
        var hasAnyShare: Bool?
        isCardShared = (PersistenceController.shared.existingShare(coreCard: card) != nil)
        hasAnyShare = PersistenceController.shared.shareTitles().isEmpty ? false : true
        
        return (isCardShared!, hasAnyShare!)
    }
}
