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
    @State var whichBoxForCKAccept: InOut.SendReceive?
    @State var userID = String()
    @State private var isBanned = false

   // @State var salooUserID: String = (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!

    //@ObservedObject var gettingRecord = GettingRecord.shared

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
                        .onTapGesture {self.showDraftBox = true}
                        .fullScreenCover(isPresented: $showDraftBox) {GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .draftbox)}
                    Text("Inbox 📥")
                        .onTapGesture {self.showInbox = true}
                        .fullScreenCover(isPresented: $showInbox) {GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .inbox)}
                    Text("Outbox 📥")
                    //.listRowBackground(appDelegate.appColor)
                        .onTapGesture {self.showOutbox = true}
                        .fullScreenCover(isPresented: $showOutbox) {GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .outbox)}
                    //Text("Calendar 🗓")
                    //.onTapGesture {self.showCalendar = true}
                    //.fullScreenCover(isPresented: $showCalendar) {CalendarParent(calViewModel: calViewModel, showDetailView: showDetailView)}
                    Text("Preferences 📱")
                        .onTapGesture {print("showPref sets to true"); self.showPref = true}
                        .fullScreenCover(isPresented: $showPref) {PrefMenu()}
                }
                LoadingOverlay()
            }

        }
        .modifier(GettingRecordAlert())
        .alert(isPresented: $isBanned) {
            Alert(title: Text("User Banned"), message: Text("You have been banned from using this app."), dismissButton: .default(Text("OK"), action: {
                exit(0) // Terminate the app
            }))
        }
        //.background(appDelegate.appColor)
        .onAppear {
           // print("Start Menu Opened...")
            var salooUserID = (UserDefaults.standard.object(forKey: "SalooUserID") as? String)!
            checkUserBanned(userId: salooUserID) { (isBanned, error) in
                self.isBanned = isBanned
                print("isBanned = \(isBanned) & error = \(error)")
            }
            //timerVar()
            //print(sceneDelegate.hideProgViewOnAcceptShare)
            //print(appDelegate.showProgViewOnAcceptShare)
            appDelegate.startMenuAppeared = true
            //print((defaults.object(forKey: "MusicSubType") as? String))
            //if (defaults.object(forKey: "MusicSubType") as? String) != nil  && appDelegate.isLaunchingFromClosed {
            if (defaults.object(forKey: "MusicSubType") as? String) != nil {
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
}

