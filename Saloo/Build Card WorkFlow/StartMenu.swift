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
    @State private var showDraftBox = false
    @State private var showCalendar = false
    @State private var showPref = false
    @State private var showEnlargeECard = false
    @State var showPrefMenu = false
    @State var appRemote2: SPTAppRemote?
    @State var whichBoxForCKAccept: InOut.SendReceive?
    @State var userID = String()
    @ObservedObject var gettingRecord = GettingRecord.shared

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
                    Text(buildCardWorkFlow)
                    //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showOccassions = true}
                        .fullScreenCover(isPresented: $showOccassions){OccassionsMenu()}
                    Text("Drafts 📓")
                    //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showDraftBox = true}
                        .fullScreenCover(isPresented: $showDraftBox) {GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .draftbox)}
                    Text("Inbox 📥")
                    //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showInbox = true}
                        .fullScreenCover(isPresented: $showInbox) {GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .inbox)}
                    Text("Outbox 📥")
                    //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showOutbox = true}
                        .fullScreenCover(isPresented: $showOutbox) {GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .outbox)}
                    //Text("Calendar 🗓")
                    //.listRowBackground(appDelegate.appColor)
                    //.onTapGesture {self.showCalendar = true}
                    //.fullScreenCover(isPresented: $showCalendar) {CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)}
                    Text("Preferences 📱")
                    //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showPref = true}
                        .fullScreenCover(isPresented: $showPref) {PrefMenu()}
                }
                //.listRowBackground(appDelegate.appColor)
                ProgressView()
                    .hidden(gettingRecord.hideProgViewOnAcceptShare)
                    //.tint(.blue)
                    .scaleEffect(7)
                    .progressViewStyle(CircularProgressViewStyle())
            }
            .overlay(
                Group {
                if gettingRecord.hideProgViewOnAcceptShare == false {
                    CountdownView(startTime: 60) // Countdown from 60 seconds
                        .padding()
                        .background(Color.white.opacity(1.0))
                        .cornerRadius(15)
                }}, alignment: .center)
        }
        //.background(appDelegate.appColor)
        .onAppear {
            print("Start Menu Opened...")
            timerVar()
            //print(sceneDelegate.hideProgViewOnAcceptShare)
            //print(appDelegate.showProgViewOnAcceptShare)
            appDelegate.startMenuAppeared = true
            //print((defaults.object(forKey: "MusicSubType") as? String))
            if (defaults.object(forKey: "MusicSubType") as? String) != nil  && appDelegate.isLaunchingFromClosed {
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
            }
            else{showPrefMenu = true }
        }
        .fullScreenCover(isPresented: $showPrefMenu) {PrefMenu()}
    }
    
}

struct CountdownView: View {
    @State private var remainingTime: Int
    init(startTime: Int) { _remainingTime = State(initialValue: startTime)}
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var backgroundTime = Date()

    var body: some View {
        VStack {
            Text("We're Still Saving Your Card to the Cloud. It'll be ready in just a minute 😊")
                .font(.system(size: 20))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            Text("Time Remaining: \(remainingTime)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            ProgressView()
            //.tint(.blue)
                .scaleEffect(2)
                .progressViewStyle(CircularProgressViewStyle())
        }
            .onReceive(timer) { _ in if remainingTime > 0 {remainingTime -= 1}}
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                backgroundTime = Date()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                let elapsedSeconds = Int(Date().timeIntervalSince(backgroundTime))
                remainingTime = max(remainingTime - elapsedSeconds, 0)
            }
    }
}


extension StartMenu {


    func timerVar() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            print("TimeVar Should Hide Prog View? \(GettingRecord.shared.hideProgViewOnAcceptShare )")
        }
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
}
