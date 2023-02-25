//
//  MusicMenu.swift
//  Saloo
//
//  Created by Sam Black on 2/4/23.
//

import Foundation
import SwiftUI
import UIKit
import FSCalendar
import CoreData


struct PrefMenu: View {
    @EnvironmentObject var musicSub: MusicSubscription
    @State private var showStart = false
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let defaults = UserDefaults.standard
    @State var currentSubSelection: String
    

    init() {
        if defaults.object(forKey: "MusicSubType") != nil {_currentSubSelection = State(initialValue: (defaults.object(forKey: "MusicSubType") as? String)!)}
        else {_currentSubSelection = State(initialValue: "None")}
    }
    
    
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Do you subscribe to either of these services?")
                Text("This will help optimize your experience")
                Text("Current Selection: \(currentSubSelection)")
                List {
                    Text("Apple Music")
                        .onTapGesture {appDelegate.musicSub.type = .Apple; defaults.set("Apple Music", forKey: "MusicSubType"); showStart = true}
                    Text("Spotify")
                        .onTapGesture {appDelegate.musicSub.type = .Spotify; defaults.set("Spotify", forKey: "MusicSubType"); showStart = true}
                    Text("I don't subscribe to either")
                        .onTapGesture {appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType"); showStart = true}
                }
            }
            .navigationBarItems(leading:Button {showStart.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
        }
        .onAppear {
            if defaults.object(forKey: "MusicSubType") != nil {currentSubSelection = (defaults.object(forKey: "MusicSubType") as? String)!}
            else { currentSubSelection = "None"}
        }
        //.environmentObject(appDelegate)
        .fullScreenCover(isPresented: $showStart) {StartMenu()}
    }
}
