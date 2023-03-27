
//
//  AppDelegate.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/1/22.
//
import Foundation
import SwiftUI
import CloudKit
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    @State var acceptedShare: CKShare?
    @State var coreCard: CoreCard?
    @State var musicSub = MusicSubscription()
    @State var startMenuAppeared = false
    @State var gotRecord = false
    @Published var showGrid = false
    @Published var chosenGridCard: CoreCard? = nil
    @Published var showProgViewOnAcceptShare = false
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Called Open from AppDelegate....")
        print(url)
        print("----")
        print(options)
        return true
    }
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("didFinishLaunchingWithOptions")
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession:   UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        print("connecting scene session....")
        return configuration
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        print("Accepted ckShare via AppDelegate")
        print(cloudKitShareMetadata)
    }
    
    
}
