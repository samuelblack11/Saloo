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

    @State private var showOccassions = false
    @State private var showGridOfCards = false
    @State private var showCalendar = false
    @State var showMusicMenu = false
    @State var counter = 0
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
                Text("View Inbox 📥").onTapGesture {self.showGridOfCards = true}
                    .fullScreenCover(isPresented: $showGridOfCards) {GridofCards(cardsForDisplay: loadCoreCards(), whichBoxVal: .inbox)}
                Text("View Outbox 📤").onTapGesture {self.showGridOfCards = true}
                    .fullScreenCover(isPresented: $showGridOfCards) {GridofCards(cardsForDisplay: loadCoreCards(), whichBoxVal: .outbox)}
                Text("View Calendar 🗓").onTapGesture {self.showCalendar = true}
                    .fullScreenCover(isPresented: $showCalendar) {CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)}
                Text("More Info 📱")
            }
        }
        //.environmentObject(appDelegate)
        .environmentObject(musicSub)
        .onAppear {
            appDelegate.startMenuAppeared = true
            if defaults.bool(forKey: "First Launch") == true && counter == 0 {showMusicMenu = true}
        }
        
        .fullScreenCover(isPresented: $showMusicMenu) {MusicMenu().environmentObject(musicSub)}
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
