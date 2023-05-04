
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
    @Published var deferToPreview = false
    @State var startMenuAppeared = false
    @State var gotRecord = false
    @Published var showGrid = false
    @Published var chosenGridCard: CoreCard? = nil
    @Published var showProgViewOnAcceptShare = false
    @Published var chosenGridCardType: String?
    var songFilterForSearch = ["(live)","[live]","live at","live in","live from", "(mixed)", "[mixed]"]
    var songFilterForMatch = ["(live)","[live]","live at","live in","live from", "(mixed)", "[mixed]", "- single","(deluxe)","(deluxe edition)"]

    let appColor = Color("SalooTheme")
    @Published var isLaunchingFromClosed = true
    @Published var isPlayerCreated = false
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let isOpened = openMyApp(from: url)
        return isOpened
    }
    
    //func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
     //   print("didFinishLaunchingWithOptions")
    //    return true
   // }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           // Check if the app is launching from a terminated state
           if let launchOptions = launchOptions, launchOptions[UIApplication.LaunchOptionsKey.annotation] == nil {
               isLaunchingFromClosed = true
           } else {
               isLaunchingFromClosed = false
           }
           
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
    
    func openMyApp(from url: URL) -> Bool {
        let scheme = "saloo" // Replace this with your app's custom URL scheme
        
        // Check if the URL contains your app's custom URL scheme
        if url.scheme == scheme {
            // Attempt to open the app
            if let appURL = URL(string: "\(scheme)://") {
                if UIApplication.shared.canOpenURL(appURL) {
                    UIApplication.shared.open(appURL)
                    return true
                }
            }
        }
        
        // If the URL does not contain your app's custom URL scheme or the app cannot be opened, return false
        return false
    }
    
    
    
    
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
