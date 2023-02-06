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


class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    var musicSubTimeToAddMusic: Bool = false
    var musicSubType: MusicSubscriptionOptions = .Neither
    @EnvironmentObject var appDelegate: AppDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
    // tells the delegate about the addition of a scene to the app
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let spotView = SpotPlayer()
        //appDelegate.musicSub
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: spotView)
            self.window = window
            window.makeKeyAndVisible()
        }
        appRemote.connect()
        appRemote.authorizeAndPlayURI("")
   }

    
    static private let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string:"comspotifytestsdk://")!
    let clientIdentifier = "d15f76f932ce4a7c94c2ecb0dfb69f4b"
    let secretKey = "2dba2becb9d34ed9858e5ea116754f5b"
    let SpotifyRedirectURL = URL(string: "https://www.google.com")!
    
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
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
            print("****")
            print(errorDescription)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        connect()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if self.appRemote.isConnected {
          self.appRemote.disconnect()
        }
      }

    func connect() {
        playerViewController.appRemoteConnecting()
        appRemote.connect()
    }

    // MARK: AppRemoteDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Track name: %@", playerState.track.name)
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
