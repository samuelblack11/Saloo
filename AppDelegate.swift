//
//  AppDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/1/22.
//

import Foundation
import SwiftUI
import CloudKit

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    @Published var oo2 = OwnerOpeningShare()
    @Published var oo3 = false
    
    func application(_ application: UIApplication, configurationForConnecting
        connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
       //let ownerOpeningOwnShare = true

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

class OwnerOpeningShare: ObservableObject {
    @Published var owner: Bool = false
    @EnvironmentObject var sceneDelegate: SceneDelegate
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    func windowScene(_ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        //@EnvironmentObject var togg = false
        let stack = CoreDataStack.shared
        let store = stack.sharedPersistentStore
        let container = stack.persistentContainer
        
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: store) { _, error in
                if let error = error {
                    print("acceptShareInvitation error :\(error)")
                }
            }
        // if participant is owner
        if ifShareOwner(cloudKitShareMetadata: cloudKitShareMetadata) {
            print("?????")
            appDelegate.oo2.owner.toggle()
            appDelegate.oo3.toggle()
            print(appDelegate.oo2.owner)
            print("---")
            print(appDelegate.oo3)
            //UserDefaults.standard.set(true, forKey: "ownerOpenedOwnShare")
            //print(UserDefaults.standard.object(forKey: "ownerOpenedOwnShare") as? Bool)
        }
    }
    
    func ifShareOwner(cloudKitShareMetadata: CKShare.Metadata) -> Bool {

        if cloudKitShareMetadata.participantRole.rawValue == 1 {
            print("Owner Is Trying To Accept Share....")
            let recordName = cloudKitShareMetadata.share.self.value(forKey: "cloudkit.type")! as? String
            let recordIdName = CKRecord.ID(recordName: recordName!)
            CoreDataStack.shared.ckContainer.privateCloudDatabase.fetch(withRecordID: recordIdName) { [self] record, error in
                if let error = error {
                    DispatchQueue.main.async {
                        // meaningful error message here!
                        print(error.localizedDescription)
                    }
                }
                else {
                    // https://medium.com/macoclock/how-to-fetch-image-assets-from-cloudkit-to-swiftui-app-74ad6d23821e
                    let asset = record!.object(forKey: "card")! as? CKAsset
                    let assetData = NSData(contentsOf: (asset?.fileURL)!)
                    UserDefaults.standard.set(assetData, forKey: "ownerCardImage")
                }
            }
        }
        //DispatchQueue.main.async {
            //let assetData = NSData(contentsOf: cloudKitShareMetadata.share.url!)
            //UserDefaults.standard.set(assetData, forKey: "ownerCardImage")
            //ownerBool.toggle()
       //}
        
        if cloudKitShareMetadata.participantRole.rawValue == 1 {
            return true
        }
        else {
            return false
        }
    }
}
