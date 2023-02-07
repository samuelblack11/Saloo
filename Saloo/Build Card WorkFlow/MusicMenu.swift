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


struct MusicMenu: View {
    @EnvironmentObject var musicSub: MusicSubscription
    @State private var showStart = false
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some View {
        NavigationStack {
            VStack {
                Text("Do you subscribe to either of these services?")
                Text("This will help optimize your experience")
                List {
                    Text("Apple Music")
                        .onTapGesture {appDelegate.musicSub.type = .Apple; showStart = true}
                    Text("Spotify")
                        .onTapGesture {appDelegate.musicSub.type = .Spotify; showStart = true}
                    Text("I don't subscribe to either")
                        .onTapGesture {appDelegate.musicSub.type = .Neither; showStart = true}
                }
            }
        }
        //.environmentObject(appDelegate)
        .fullScreenCover(isPresented: $showStart) {StartMenu(counter: 1)}
    }
}
