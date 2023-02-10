//
//  SpotPlayer.swift
//  Saloo
//https://sarunw.com/posts/uiviewcontroller-in-swiftui/
//  Created by Sam Black on 2/1/23.
//https://swiftdoc.org/v5.1/type/unmanaged/

import Foundation
import UIKit
import StoreKit
import SwiftUI
import MediaPlayer

class SpotPlayerVC: UIViewController, SPTAppRemoteUserAPIDelegate, SPTAppRemotePlayerStateDelegate {
    @State private var subscribedToPlayerState: Bool = false
    @State private var subscribedToCapabilities: Bool = false
    @ObservedObject var sceneDelegate = SceneDelegate()
    var appRemote: SPTAppRemote? {get {return (sceneDelegate.appRemote)}}
    let defaults = UserDefaults.standard
    //var str: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
        print("Begin Authorize....")
        appRemote?.authorizeAndPlayURI("")
        appRemote?.playerAPI?.resume(defaultCallback)
        //appRemote?.playerAPI?.play("32ftxJzxMPgUFCM6Km9WTS", callback: defaultCallback)
        //str = defaults.object(forKey: SceneDelegate.kAccessTokenKey) as? String
        print("444")
        print(sceneDelegate.accessToken)
        print("Calling2....")
        print(appRemote?.isConnected)
    }
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
    }
    
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                print("defaultCallBack Running...")

                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    // MARK: - Error & Alert
    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - AppRemote
    func appRemoteConnecting() {
        //connectionIndicatorView.state = .connecting
    }

    func appRemoteConnected() {
        //connectionIndicatorView.state = .connected
        subscribeToPlayerState()
        subscribeToCapabilityChanges()
        getPlayerState()

        //enableInterface(true)
    }

    func appRemoteDisconnect() {
        //connectionIndicatorView.state = .disconnected
        subscribedToPlayerState = false
        subscribedToCapabilities = false
        //enableInterface(false)
    }
    
    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote?.playerAPI!.delegate = self
        appRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
            //self.updatePlayerStateSubscriptionButtonState()
        }
    }
    
    private func getPlayerState() {
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
            //self.updateViewWithPlayerState(playerState)
        }
    }
    
    private func subscribeToCapabilityChanges() {
        guard (!subscribedToCapabilities) else { return }
        appRemote?.userAPI?.delegate = self
        appRemote?.userAPI?.subscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            self.subscribedToCapabilities = true
            //self.updateCapabilitiesSubscriptionButtonState()
        })
    }
}

struct SpotPlayer: UIViewControllerRepresentable {
    //@EnvironmentObject var sceneDelegate: SceneDelegate
    typealias UIViewControllerType = SpotPlayerVC
    let defaults = UserDefaults.standard
    
    func makeUIViewController(context: Context) -> SpotPlayerVC {
        //Return SpotAppRemoteVC Instance
        let vc = SpotPlayerVC()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SpotPlayerVC, context: Context) {
        //Updates the state of the specified view controller with new information from SwiftUI.
        print("999999")
        print(defaults.object(forKey: "access-token-key"))
    }
}
