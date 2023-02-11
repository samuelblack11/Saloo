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


class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject, SPTAppRemoteDelegate {
    
    //var musicSubTimeToAddMusic: Bool = false
    //var musicSubType: MusicSubscriptionOptions = .Neither
    //@EnvironmentObject var appDelegate: AppDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    static let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string: "saloo://")!
    let clientIdentifier = "d15f76f932ce4a7c94c2ecb0dfb69f4b"

    var window: UIWindow?
    
    lazy var appRemote: SPTAppRemote = {
        print("instantiated appRemote...")
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        print("check1")
        print(self.accessToken)
        print(appRemote.connectionParameters.accessToken)
        print(appRemote.connectionParameters.authenticationMethods)
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            print("check1.5")
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
            print("check2")
            print(accessToken)
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = MusicSearchView()
        print("called willConnectTo")

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        
        
       // let url = connectionOptions.urlContexts.first?.url
        //self.scene(scene, openURLContexts: url)

      
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("called openurlcontexts")
        guard let url = URLContexts.first?.url else {
            return
        }
        
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let code = parameters?["code"] {
            UserDefaults.standard.set(code, forKey: "access-token-key")
            print("^^^^")
            print(code)
        }
            
            //let baseURL = "https://accounts.spotify.com/api/token"
            
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
            print("check3")
            print(self.accessToken)
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("There is an error.....")
            print(errorDescription)
            playerViewController.showError(errorDescription)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("scene is now active!")
        connect()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("scene is now inactive!")
        //playerViewController.appRemoteDisconnect()
        //appRemote.disconnect()
      }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("scene is now in the background!")
    }

    func connect() {
        playerViewController.appRemoteConnecting()
        appRemote.connect()
        //if it failed, aka we dont have a valid access token
        if (!appRemote.isConnected) {//ultimately access token issues aren't the only thing that will cause this the connection to fail
            //make spotify authorize and create an access token for us
            appRemote.authorizeAndPlayURI("")
        }
        
        //self.appRemote.authorizeAndPlayURI("spotify:track:20I6sIOMTCkB6w7ryavxtO")
    }

    // MARK: AppRemoteDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Track name: %@", playerState.track.name)
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        print("++++")
        print(accessToken)
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
    
    var playerViewController: SpotPlayerVC {
        get {
            let navController = self.window?.rootViewController?.children[0] as! UINavigationController
            return navController.topViewController as! SpotPlayerVC
        }
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
