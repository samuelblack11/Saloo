//
//  GreetMe_2App.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.

import SwiftUI
import CloudKit

@main
struct Saloo_App: App {
    @StateObject var musicSub = MusicSubscription()
    @StateObject var calViewModel = CalViewModel()
    @StateObject var showDetailView = ShowDetailView()
    let persistenceController = PersistenceController.shared
    @StateObject var appDelegate = AppDelegate()
    //@StateObject var sceneDelegate = SceneDelegate()

    //@Environment (\.scenePhase) private var scenePhase
    

    var body: some Scene {
        WindowGroup {
            StartMenu()
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
                //.environmentObject(sceneDelegate)
                .environmentObject(appDelegate)
                .environmentObject(musicSub)
                .environmentObject(calViewModel)
                .environmentObject(showDetailView)
        }
    }
}
