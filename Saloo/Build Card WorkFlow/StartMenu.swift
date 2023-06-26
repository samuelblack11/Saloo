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
    @EnvironmentObject var screenManager: ScreenManager
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var alertVars = AlertVars.shared
    @State var whichBoxForCKAccept: InOut.SendReceive?
    @State var userID = String()
    @State private var isBanned = false
    @State private var hasShownLaunchView: Bool = true

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate2
    // @State var salooUserID: String = (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!
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
                    Text("Build a Card").onTapGesture {appState.currentScreen = .buildCard([.occasionsMenu])}
                    Text("Drafts 📓").onTapGesture {screenManager.advance(); appState.currentScreen = .draft}
                    Text("Inbox 📥").onTapGesture {screenManager.advance(); appState.currentScreen = .inbox}
                    Text("Outbox 📥") .onTapGesture {screenManager.advance(); appState.currentScreen = .outbox}
                    Text("Music Preferences 📱").onTapGesture {appState.currentScreen = .preferences}
                }
                LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)

            }
        }
            .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
            .onAppear {
                //deleteAllCoreCards()
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

