//
//  SpotPlayer.swift
//  Saloo
//
//  Created by Sam Black on 2/1/23.
//

import Foundation
import UIKit
import StoreKit
import SwiftUI

class SpotPlayer: UIViewController, SPTAppRemotePlayerStateDelegate {
    
    private let playURI = "spotify:album:"
    private let trackIdentifier = "spotify:track:"
    private let name = "Now Playing View"
    private var subscribedToPlayerState: Bool = false
    private var subscribedToCapabilities: Bool = false
    private var playerState: SPTAppRemotePlayerState?

    //private let playURI = "spotify:album:1htHMnxonxmyHdKE2uDFMR"
    //private let trackIdentifier = "spotify:track:32ftxJzxMPgUFCM6Km9WTS"
    //private let name = "Now Playing View"
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        updateViewWithPlayerState(playerState)
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {return {[weak self] _, error in if let error = error {print("$#$#$"); print(error)}}}
    }

    var appRemote: SPTAppRemote? {
        get {return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote}
    }
    
    private func playTrackWithIdentifier(_ identifier: String) {appRemote?.playerAPI?.play(identifier, callback: defaultCallback)}
    
    // MARK: - AppRemote
    func appRemoteConnecting() {}
    func appRemoteConnected() {subscribeToPlayerState(); getPlayerState()}
    func appRemoteDisconnect() {
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
    }
    
    private func getPlayerState() {
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }
            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
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
    
    private func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        //pass song id, name, artist, and album to view
        
        
    }
}
