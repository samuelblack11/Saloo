//
//  AppDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/1/22.
//

import Foundation
import SwiftUI
import CloudKit


class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting
        connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let ownerOpeningOwnShare = true

        // Create a scene configuration object for the
        // specified session role.
        let config = UISceneConfiguration(name: nil,
            sessionRole: connectingSceneSession.role)

        // Set the configuration's delegate class to the
        // scene delegate that implements the share
        // acceptance method.
        config.delegateClass = SceneDelegate.self
        
        return config
    }
    
    
    
    
    
    
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    @State var ownerOpeningOwnShare = false
    
    func windowScene(_ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        let stack = CoreDataStack.shared
        let store = stack.sharedPersistentStore
        let container = stack.persistentContainer
        
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: store) { _, error in
                if let error = error {
                    print("acceptShareInvitation error :\(error)")
                }
            }
        // if participant is owner
        if cloudKitShareMetadata.participantRole.rawValue == 1 {
            print("Owner Is Trying To Accept Share....")
            let recordName = cloudKitShareMetadata.share.self.value(forKey: "cloudkit.type")! as? String
            let recordIdName = CKRecord.ID(recordName: recordName!)
            CoreDataStack.shared.ckContainer.privateCloudDatabase.fetch(withRecordID: recordIdName) { [self] record, error in
                if let error = error {
                    DispatchQueue.main.async {
                        // meaningful error message here!
                        print("!!!!!")
                        print(error.localizedDescription)
                    }
                }
                else {
                    // https://medium.com/macoclock/how-to-fetch-image-assets-from-cloudkit-to-swiftui-app-74ad6d23821e
                    let asset = record!.object(forKey: "card")! as? CKAsset
                    let assetData = NSData(contentsOf: (asset?.fileURL)!)
                    //let assetData = NSData(contentsOf: cloudKitShareMetadata.share.url!)
                    UserDefaults.standard.set(assetData, forKey: "ownerCardImage")
                    ownerOpeningOwnShare = true

                }
            }
        }
    }
}
