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
    @State var coreCard: CoreCard?
    @State var ckShare: CKShare?
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
                
                
                
                
                ckContainer.fetchUserRecordID { ckRecordID, error in print("Current User ID: \((ckRecordID?.recordName)!)")}
                //the created_by value displayed in CloudKit -> "_b4f706f0a40fb208d7562813fa8f15da"
                print("Creator User ID.....\((cloudKitShareMetadata.ownerIdentity.userRecordID?.recordName)!)")
                //ckShare = cloudKitShareMetadata.share
                // add card to inbox
                // display card via -> Inbox -> EnlargeECardView -> eCardView
                // EnlargeECardView(chosenCard: , share: , cardsForDisplay: persistenceController., whichBoxVal: .inbox)
                // if owner of card, whichBoxVal: .outbox. Else, .inbox
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
        
        
        print(metadata.rootRecord)
        //metadata.share.owner
        print("4444")
        //print(metadata.hierarchicalRootRecordID!)
        print("555")
        //let op2 = CKFetchRecordsOperation(recordIDs: )
        let operation = CKFetchRecordsOperation(recordIDs: [metadata.share.recordID])
        operation.perRecordResultBlock! = { recordID, recordResult in
            switch recordResult {
            case .success(let ref):
                DispatchQueue.main.async() {
                    self.coreCard?.cardName = ref.object(forKey: "cardName") as! String
                    self.coreCard?.occassion = ref.object(forKey: "occassion") as! String
                    self.coreCard?.recipient = ref.object(forKey: "recipient") as! String
                    self.coreCard?.sender = ref.object(forKey: "sender") as? String
                    self.coreCard?.an1 = ref.object(forKey: "an1") as! String
                    self.coreCard?.an2 = ref.object(forKey: "an2") as! String
                    self.coreCard?.an2URL = ref.object(forKey: "an2URL") as! String
                    self.coreCard?.an3 = ref.object(forKey: "an3") as! String
                    self.coreCard?.an4 = ref.object(forKey: "an4") as! String
                    self.coreCard?.collage = ref.object(forKey: "collage") as? Data
                    self.coreCard?.coverImage = ref.object(forKey: "coverImage") as? Data
                    self.coreCard?.date = ref.object(forKey: "date") as! Date
                    self.coreCard?.font = ref.object(forKey: "font") as! String
                    self.coreCard?.message = ref.object(forKey: "message") as! String
                    self.coreCard?.songID = ref.object(forKey: "songID") as? String
                    self.coreCard?.spotID = ref.object(forKey: "spotID") as? String
                    self.coreCard?.songName = ref.object(forKey: "songName") as? String
                    self.coreCard?.songArtistName = ref.object(forKey: "songArtistName") as? String
                    self.coreCard?.songArtImageData = ref.object(forKey: "songArtImageData") as? Data
                    self.coreCard?.songPreviewURL = ref.object(forKey: "songPreviewURL") as? String
                    self.coreCard?.songDuration = ref.object(forKey: "songDuration") as? String
                    self.coreCard?.inclMusic = ref.object(forKey: "inclMusic") as! Bool
                    self.coreCard?.spotImageData = ref.object(forKey: "spotImageData") as? Data
                    self.coreCard?.spotSongDuration = ref.object(forKey: "spotSongDuration") as? String
                    self.coreCard?.spotPreviewURL = ref.object(forKey: "spotPreviewURL") as? String
                }
            case .failure:
                print("Record Result Returned Error")
            }
        }
        
        operation.fetchRecordsResultBlock = { result in
            switch result {
                case .success:
                    print("Disregard")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            CKContainer.default().sharedCloudDatabase.add(operation)
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
