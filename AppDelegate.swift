//
//  AppDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/1/22.
//

import Foundation
import SwiftUI
import CloudKit

class OwnerOpeningShare: ObservableObject {
    static let shared = OwnerOpeningShare()
    @Published var owner: Bool?
}

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    @ObservedObject var oo1 = OwnerOpeningShare.shared

    func application(_ application: UIApplication, configurationForConnecting
        connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        // Create a scene configuration object for the specified session role.
        let config = UISceneConfiguration(name: nil,
            sessionRole: connectingSceneSession.role)

        // Set the configuration's delegate class to the scene delegate that implements the share acceptance method.
        config.delegateClass = SceneDelegate.self
        
        return config
    }
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
        if cloudKitShareMetadata.participantRole.rawValue == 1 {
            //let assetData = NSData(contentsOf: cloudKitShareMetadata.share.url!)
            //UserDefaults.standard.set(assetData, forKey: "ownerCardImage")
            print("++++++")
            print(appDelegate.oo1.owner)
            appDelegate.oo1.owner = true
            print(appDelegate.oo1.owner)
            print("++++++")

        }
    }
            //DispatchQueue.main.async {
            //let assetData = NSData(contentsOf: cloudKitShareMetadata.share.url!)
            //UserDefaults.standard.set(assetData, forKey: "ownerCardImage")
            //ownerBool.toggle()
       //}
}
