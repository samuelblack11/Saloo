//
//  StartMenu.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/9/23.
//

import Foundation
import SwiftUI
import UIKit
import FSCalendar
import CoreData
import CloudKit
import MediaPlayer
import StoreKit
import WebKit

struct StartMenu: View {
    let defaults = UserDefaults.standard
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cardsForDisplay: CardsForDisplay
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var alertVars = AlertVars.shared
    @State var whichBoxForCKAccept: InOut.SendReceive?
    @State var userID = String()
    @State private var isBanned = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate2
    // @State var salooUserID: String = (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!
    //@StateObject var audioManager = AudioSessionManager()
    var possibleSubscriptionValues = ["Apple Music", "Spotify", "Neither"]
    let buildCardWorkFlow = """
    Build a Card
        Choose an Occassion 🎉
        Choose a Cover Photo 📸
        Make your Collage 🤳
        Write your Message 📝
        Add Music 🎶
        Finalize ✅
"""
    
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Text(buildCardWorkFlow).onTapGesture {appState.currentScreen = .buildCard([.occasionsMenu])}
                    Text("Drafts 📓").onTapGesture {appState.currentScreen = .draft}
                    Text("Inbox 📥").onTapGesture {appState.currentScreen = .inbox}
                    Text("Outbox 📥") .onTapGesture {appState.currentScreen = .outbox}
                    Text("Preferences 📱").onTapGesture {appState.currentScreen = .preferences}
                }
                LoadingOverlay()
            }
        }
            .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
            .onAppear {
                //deleteAllCoreCards()
                cardsForDisplay.cardsForDisplay = cardsForDisplay.loadCoreCards()
                var salooUserID = (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!
                checkUserBanned(userId: salooUserID) { (isBanned, error) in
                    if isBanned == true {alertVars.alertType = .userBanned; alertVars.activateAlert = true}
                    //print("isBanned = \(isBanned) & error = \(error)")
                }
                if (defaults.object(forKey: "MusicSubType") as? String) != nil {
                    if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
                    if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
                    if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
                }
                else{appState.currentScreen = .preferences}
            }
        }
    }

extension StartMenu {
    
    func checkUserBanned(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "https://saloouserstatus.azurewebsites.net/is_banned?user_id=\(userId)") else {
            // Handle invalid URL error
            print("Invalid URL")
            completion(false, nil)
            return
        }

        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Handle error
                completion(false, error)
                return
            }

            if let data = data {
                do {
                    if let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let value: Optional<Any> = responseDict["is_banned"]
                        if let stringValue = value as? String {
                            let stringValue2 = stringValue.lowercased()
                            if let isBanned = Bool(stringValue2) {
                                completion(isBanned, nil)
                                return
                            }
                        }
                    }
                }
                catch {
                    // Handle JSON parsing error
                    completion(false, error)
                    return
                }
            }

            // Invalid response or data
            completion(false, nil)
        }

        task.resume()
    }

    
    func createNewShare(coreCard: CoreCard) {
       print("CreateNewShare called")
       if PersistenceController.shared.privatePersistentStore.contains(manageObject: coreCard) {
           print("privateStoreDoesContainObject")
           PersistenceController.shared.presentCloudSharingController(coreCard: coreCard)
       }
   }
    
    
    func getCurrentUserID() {
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            self.userID = (ckRecordID?.recordName)!
            //print("Current User ID: \((ckRecordID?.recordName)!)")
        }
        
    }
    
    
    func deleteCoreCard(coreCard: CoreCard) {
        do {PersistenceController.shared.persistentContainer.viewContext.delete(coreCard);try PersistenceController.shared.persistentContainer.viewContext.save()}
        catch {}
    }
    
    func deleteAllCoreCards() {
        let request = CoreCard.createFetchRequest()
        var cardsFromCore: [CoreCard] = []
        do {cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request); for card in cardsFromCore {deleteCoreCard(coreCard: card)}}
        catch{}
    }
}

