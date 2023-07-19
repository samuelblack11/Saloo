
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
    let coreCardB = CoreCard(context: PersistenceController.shared.persistentContainer.viewContext)
    @State var musicSub = MusicSubscription()
    @Published var deferToPreview = false
    @State var gotRecord = false
    @Published var showGrid = false
    //@Published var chosenGridCard: CoreCard? = nil
    @Published var showProgViewOnAcceptShare = false
    @Published var chosenGridCardType: String?
    var songFilterForSearchRegex = ["\\(live\\)", "\\[live\\]", "live at", "live in", "live from", "\\(mixed\\)", "\\[mixed\\]"]
    var songFilterForMatchRegex = ["\\(live\\)", "\\[live\\]", "live at", "live in", "live from", "\\(mixed\\)", "\\[mixed\\]", "- single", "\\(deluxe\\)", "\\(deluxe edition\\)", "\\(remastered\\)", "- .*Remastered",  "- .*remastered", "\\- EP", "\\- ep"]

    var waitingToAcceptRecord = false
    var counter = 0
    var checkIfRecordAddedToStore = true
    @State var userID = String()
    var whichBoxForCKAccept: InOut.SendReceive?

    let appColor = Color("SalooTheme")
    @Published var isLaunchingFromClosed = true
    @Published var isPlayerCreated = false

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let path = components.path else {
            return false
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            print("didFinishLaunchingWithOptions called...")
           // Check if the app is launching from a terminated state
           if let launchOptions = launchOptions, launchOptions[UIApplication.LaunchOptionsKey.annotation] == nil {
               print("isLaunchingFromClosed")
               //GettingRecord.shared.isLoadingAlert = true
               isLaunchingFromClosed = true
           } else {isLaunchingFromClosed = false}
           
           return true
       }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession:   UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        print("connecting scene session....")
        return configuration
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
