//
//  StartMenu.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/9/23.
//

import Foundation
import SwiftUI
import UIKit
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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var cardProgress: CardProgress

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
                VStack {
                    CustomNavigationBar(titleContent: .image("logo1024-noBackground"), showBackButton: false)
                    Text("Welcome To Saloo")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(Font.custom("Papyrus", size: 32))
                        .padding(.top, 10)
                    Text("🎈🎂🥳❤️🥂💍🎓")
                    Text("")
                    Text("Connect with loved ones, share memories")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(Font.custom("Papyrus", size: 16))
                        .textCase(.none)
                        .multilineTextAlignment(.center)
                    Text("and celebrate holidays and special occassions")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(Font.custom("Papyrus", size: 16))
                        .textCase(.none)
                        .multilineTextAlignment(.center)
                    List {
                        Button(action: {appState.currentScreen = .buildCard([.photoOptionsView])}) {
                            VStack(alignment: .leading) {
                                Text("Build a Card")
                                    .font(Font.custom("Papyrus", size: 18))
                                    .foregroundColor(.primary)
                                Text("Combine photos, a personal message, and music to create a unique greeting card experience")
                                    .font(Font.custom("Papyrus", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button(action: {screenManager.advance(); appState.currentScreen = .inbox}) {
                            VStack(alignment: .leading) {
                                Text("Cards from Others")
                                    .font(Font.custom("Papyrus", size: 18))
                                    .foregroundColor(.primary)
                                Text("View cards you've received")
                                    .font(Font.custom("Papyrus", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button(action: {screenManager.advance(); appState.currentScreen = .outbox}) {
                            VStack(alignment: .leading) {
                                Text("Cards from Me")
                                    .font(Font.custom("Papyrus", size: 18))
                                    .foregroundColor(.primary)
                                Text("View cards you've created")
                                    .font(Font.custom("Papyrus", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button(action: {appState.currentScreen = .preferences}) {
                            VStack(alignment: .leading) {
                                Text("Settings")
                                    .font(Font.custom("Papyrus", size: 18))
                                    .foregroundColor(.primary)
                                Text("Update music preferences and more")
                                    .font(Font.custom("Papyrus", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }


                }
                LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
            }
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, goToSettings: {DispatchQueue.main.async{AppState.shared.currentScreen = .preferences}}, updateMusicLaterPrompt: {DispatchQueue.main.async{alertVars.alertType = .updateMusicSubAnyTime; alertVars.activateAlert = true}}))
            .onAppear {
                cardProgress.currentStep = 1
                cardProgress.maxStep = 1
                if (defaults.object(forKey: "MusicSubType") as? String) != nil {
                    if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
                    if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
                    if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
                }
                else{appState.currentScreen = .startMenu}
            }
        }
    }

extension StartMenu {
    func getCurrentUserID() {
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            self.userID = (ckRecordID?.recordName)!
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

