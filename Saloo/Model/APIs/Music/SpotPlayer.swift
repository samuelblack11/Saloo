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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
        print("Begin Authorize....")
        appRemote?.authorizeAndPlayURI("")
        
    }
    
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        
    }
    

    
    var defaultCallback: SPTAppRemoteCallback {
        get {return {[weak self] _, error in if let error = error {print("***");print(error)}}}
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
    @EnvironmentObject var sceneDelegate: SceneDelegate
    typealias UIViewControllerType = SpotPlayerVC

    func makeUIViewController(context: Context) -> SpotPlayerVC {
        //Return SpotAppRemoteVC Instance
        let vc = SpotPlayerVC()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SpotPlayerVC, context: Context) {
        //Updates the state of the specified view controller with new information from SwiftUI.
    }
}
