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
            if let error = error {
                print("\(#function): Failed to accept share invitations: \(error)")
            }
        }
    }

}
