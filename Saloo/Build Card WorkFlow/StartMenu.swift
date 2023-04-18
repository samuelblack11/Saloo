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
    @EnvironmentObject var calViewModel: CalViewModel
    @EnvironmentObject var showDetailView: ShowDetailView
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    @State private var showOccassions = false
    @State private var showInbox = false
    @State private var showOutbox = false
    @State private var showCalendar = false
    @State private var showPref = false
    @State private var showEnlargeECard = false
    @State var showPrefMenu = false
    @State var appRemote2: SPTAppRemote?
    @State var whichBoxForCKAccept: InOut.SendReceive?
    @State var userID = String()
    
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
                List {
                    Text(buildCardWorkFlow)
                        //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showOccassions = true}
                        .fullScreenCover(isPresented: $showOccassions){OccassionsMenu()}
                    Text("Inbox 📥")
                        //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showInbox = true}
                        .fullScreenCover(isPresented: $showInbox) {GridofCards(cardsForDisplay: loadCoreCards(), whichBoxVal: .inbox)}
                    Text("Outbox 📥")
                        //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showOutbox = true}
                        .fullScreenCover(isPresented: $showOutbox) {GridofCards(cardsForDisplay: loadCoreCards(), whichBoxVal: .outbox)}
                    Text("Calendar 🗓")
                        //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showCalendar = true}
                        .fullScreenCover(isPresented: $showCalendar) {CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)}
                    Text("Preferences 📱")
                        //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showPref = true}
                        .fullScreenCover(isPresented: $showPref) {PrefMenu()}
                }
                //.listRowBackground(appDelegate.appColor)
                ProgressView()
                    .hidden(appDelegate.showProgViewOnAcceptShare)
                    .tint(.blue)
                    .scaleEffect(5)
                    .progressViewStyle(CircularProgressViewStyle())
        }
        //.background(appDelegate.appColor)
        .onAppear {
            print("Opened App...")
            print(appDelegate.showProgViewOnAcceptShare)
            appDelegate.startMenuAppeared = true
            print((defaults.object(forKey: "MusicSubType") as? String))
            if (defaults.object(forKey: "MusicSubType") as? String) != nil  {
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
            }
            else{showPrefMenu = true }
        }
        .fullScreenCover(isPresented: $showPrefMenu) {PrefMenu()}
    }
    
}

extension StartMenu {

    func loadCoreCards() -> [CoreCard] {
        let request = CoreCard.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        var cardsFromCore: [CoreCard] = []
        do {
            cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)
            print("Got \(cardsFromCore.count) Cards From Core")
        }
        catch {print("Fetch failed")}
        return cardsFromCore
    }
    
    
    func getCurrentUserID() {
        PersistenceController.shared.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            self.userID = (ckRecordID?.recordName)!
            //print("Current User ID: \((ckRecordID?.recordName)!)")
        }
        
    }
}
