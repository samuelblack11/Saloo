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

struct StartMenu: View {
    @EnvironmentObject var musicSub: MusicSubscription
    @EnvironmentObject var calViewModel: CalViewModel
    @EnvironmentObject var showDetailView: ShowDetailView
    @EnvironmentObject var appDelegate: AppDelegate
    //@EnvironmentObject var sceneDelegate: SceneDelegate
    @State var whichBoxVal: InOut.SendReceive?
    @State private var showOccassions = false
    @State private var showInbox = false
    @State private var showOutbox = false

    @State private var showCalendar = false
    @State private var showPref = false
    @State var showPrefMenu = false
    @State var appRemote2: SPTAppRemote?
    var possibleSubscriptionValues = ["Apple Music", "Spotify", "Neither"]
    let defaults = UserDefaults.standard
    let buildCardWorkFlow = """
    Build a Card
        Choose an Occassion 🎉
        Choose a Cover Photo 📸
        Make your Collage 🤳
        Write your Message 📝
        Add Music 🎶 (optional)
        Add a gift card 🎁 (optional)
        Finalize ✅
"""
    
    
    var body: some View {
        NavigationView {
            List {
                Text(buildCardWorkFlow).onTapGesture {self.showOccassions = true}
                    .fullScreenCover(isPresented: $showOccassions){OccassionsMenu()}
                Text("Inbox 📥").onTapGesture {self.showInbox = true}
                    .fullScreenCover(isPresented: $showInbox) {GridofCards(cardsForDisplay: loadCoreCards(), whichBoxVal: .inbox)}
                Text("Outbox 📥").onTapGesture {self.showOutbox = true}
                    .fullScreenCover(isPresented: $showOutbox) {GridofCards(cardsForDisplay: loadCoreCards(), whichBoxVal: .outbox)}
                Text("Calendar 🗓").onTapGesture {self.showCalendar = true}
                    .fullScreenCover(isPresented: $showCalendar) {CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)}
                Text("Preferences 📱").onTapGesture {self.showPref = true}
                    .fullScreenCover(isPresented: $showPref) {PrefMenu()}
            }
        }
        //.environmentObject(appDelegate)
        .environmentObject(musicSub)
        .onAppear {
            appDelegate.startMenuAppeared = true
            if (defaults.object(forKey: "MusicSubType") as? String) != nil && possibleSubscriptionValues.contains((defaults.object(forKey: "MusicSubType") as? String)!) {
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
            }
            else{showPrefMenu = true }
        }
        
        .fullScreenCover(isPresented: $showPrefMenu) {PrefMenu().environmentObject(musicSub)}
    }}

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
}
