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
import MediaPlayer

struct SpotPlayer: View {
    
    var appRemote: SPTAppRemote? {
        get {return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote}
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[self] _, error in
                if let error = error {
                    print("***")
                    print(error)
                }
            }
        }
    }
    
    var body: some View {
        Text("")
    }

}
