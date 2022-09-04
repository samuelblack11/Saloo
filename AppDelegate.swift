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
    
    
    func windowScene(_ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        let stack = CoreDataStack.shared
        let store = stack.sharedPersistentStore
        let container = stack.persistentContainer
        
       container.acceptShareInvitations(from: [cloudKitShareMetadata],
                                        into: store) { _, error in
           if let error = error {
             print("acceptShareInvitation error :\(error)")
           }
         }
        
        print("Trying to Accept Share......")
        // if participant is owner
        if cloudKitShareMetadata.participantRole.rawValue == 1 {

        }

    }
}
