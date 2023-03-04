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
    @State var gotRecord = false
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
                    ckContainer.sharedCloudDatabase.fetch(withRecordID: recordID){ record, error in
                        print("***")
                        print(record?.object(forKey: "CD_songArtistName") as! String)
                        getRecord(record: record)
                    }

                }
                
                
                op3.queryResultBlock = {result in
                    print("queryResultBlock Called")
                    switch result {
                    case .success(let win): print("This was a success")
                    case .failure(let _): print("This faield")
                    }

                    
                    print("queryResultBlock Complete")
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

    
    
    
    
    
    
    
    
    
    
    
    
    
    func getRecord(record: CKRecord?) {

        DispatchQueue.main.async() {
            self.coreCard?.cardName = record?.object(forKey: "CD_cardName") as! String
            self.coreCard?.occassion = record?.object(forKey: "CD_occassion") as! String
            self.coreCard?.recipient = record?.object(forKey: "CD_recipient") as! String
            self.coreCard?.sender = record?.object(forKey: "CD_sender") as? String
            self.coreCard?.an1 = record?.object(forKey: "CD_an1") as! String
            self.coreCard?.an2 = record?.object(forKey: "CD_an2") as! String
            self.coreCard?.an2URL = record?.object(forKey: "CD_an2URL") as! String
            self.coreCard?.an3 = record?.object(forKey: "CD_an3") as! String
            self.coreCard?.an4 = record?.object(forKey: "CD_an4") as! String
            self.coreCard?.collage = record?.object(forKey: "CD_collage") as? Data
            self.coreCard?.coverImage = record?.object(forKey: "CD_coverImage") as? Data
            self.coreCard?.date = record?.object(forKey: "CD_date") as! Date
            self.coreCard?.font = record?.object(forKey: "CD_font") as! String
            self.coreCard?.message = record?.object(forKey: "CD_message") as! String
            self.coreCard?.songID = record?.object(forKey: "CD_songID") as? String
            self.coreCard?.spotID = record?.object(forKey: "CD_spotID") as? String
            self.coreCard?.songName = record?.object(forKey: "CD_songName") as? String
            self.coreCard?.songArtistName = record?.object(forKey: "CD_songArtistName") as? String
            self.coreCard?.songArtImageData = record?.object(forKey: "CD_songArtImageData") as? Data
            self.coreCard?.songPreviewURL = record?.object(forKey: "CD_songPreviewURL") as? String
            self.coreCard?.songDuration = record?.object(forKey: "CD_songDuration") as? String
            self.coreCard?.inclMusic = record?.object(forKey: "CD_inclMusic") as! Bool
            self.coreCard?.spotImageData = record?.object(forKey: "CD_spotImageData") as? Data
            self.coreCard?.spotSongDuration = record?.object(forKey: "CD_spotSongDuration") as? String
            self.coreCard?.spotPreviewURL = record?.object(forKey: "CD_spotPreviewURL") as? String
            self.gotRecord = true
            print("getRecord complete...")
            print(record?.object(forKey: "CD_spotPreviewURL") as? String)
            //print(self.coreCard!)
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
