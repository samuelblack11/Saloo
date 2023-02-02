//
//  SceneDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/4/23.
//

import Foundation
import UIKit
import CloudKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate {
    var window: UIWindow?
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
    
    lazy var spotConfig = SpotifyAPI().configuration
    let SpotifyClientID = "88ea858e07c54fadb97418c1c8554e11"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    static private let auth_token = "BQDvrd0To-_y1Ih4wN18hRQ3JjTSrj9FpRPDTOYe9DvI9WAJV-vXgYvtKt_LMdhbYASe_4PV3sJPJM1vEnKrc36wkeuAqSf9n_DQevVRv3Fo_nz4eyVs1TtI_vukzp0iXv5Pomr4ba2heRTTBMksqXHlpjmz2Nvj-sl5RzsBEG_QeEUk1T7VWSy-ne1w1398ioiO"
    var playURI = ""
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: spotConfig, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
      appRemote.delegate = self
      return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: auth_token) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.auth_token)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let parameters = appRemote.authorizationParameters(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("!!!!!!!!")
            //playerViewController.showError(errorDescription)
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        connect();
    }

    func sceneWillResignActive(_ scene: UIScene) {
        playerViewController.appRemoteDisconnect()
        appRemote.disconnect()
    }

    func connect() {
        playerViewController.appRemoteConnecting()
        appRemote.connect()
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        playerViewController.appRemoteConnected()
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnectionAttemptWithError")
        playerViewController.appRemoteDisconnect()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("didDisconnectWithError")
        playerViewController.appRemoteDisconnect()
    }
    
    var playerViewController: SpotPlayer {
        get {
            let navController = self.window?.rootViewController?.children[0] as! UINavigationController
            return navController.topViewController as! SpotPlayer
        }
    }
    
    
    
    
    
    
    
}
