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
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @State private var storeFrontID = "us"
    @State private var userToken = ""
    let defaults = UserDefaults.standard
    @State private var refresh_token: String? = ""
    @State var refreshAccessToken = false
    @State private var invalidAuthCode = false
    var amAPI = AppleMusicAPI()
    @State private var showWebView = false
    @State private var authCode: String? = ""
    @State private var ranAMStoreFront = false
    @State var spotifyAuth = SpotifyAuth()
    @State private var tokenCounter = 0
    @State private var instantiateAppRemoteCounter = 0
    let config = SPTConfiguration(clientID: "d15f76f932ce4a7c94c2ecb0dfb69f4b", redirectURL: URL(string: "saloo://")!)
    @State var counter = 0
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    var possibleSubscriptionValues = ["Apple Music", "Spotify", "Neither"]
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
        //.environmentObject(musicSub)
        //.onChange(of: appDelegate.acceptedShare!){acceptedECard in showEnlargeECard = true}
        //.onChange(of: sceneDelegate.gotRecord) {acceptedECard in
            
       //     if sceneDelegate.coreCard.creator! == self.userID { whichBoxForCKAccept = .outbox}
       //     else {whichBoxForCKAccept = .inbox}
       //     print("Calling...")
        //    print(sceneDelegate.coreCard)
        //    showEnlargeECard = true
        //}
        .onAppear {
            print("Opened App...")
            appDelegate.startMenuAppeared = true
            if (defaults.object(forKey: "MusicSubType") as? String) != nil && possibleSubscriptionValues.contains((defaults.object(forKey: "MusicSubType") as? String)!) {
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Apple Music" {appDelegate.musicSub.type = .Apple}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Spotify" {appDelegate.musicSub.type = .Spotify}
                if (defaults.object(forKey: "MusicSubType") as? String)! == "Neither" {appDelegate.musicSub.type = .Neither}
            }
            else{showPrefMenu = true }
        }
        //.fullScreenCover(isPresented: $showEnlargeECard){EnlargeECardView(chosenCard: sceneDelegate.coreCard!, share: appDelegate.acceptedShare, cardsForDisplay: loadCoreCards(), whichBoxVal: .inbox)}
        .fullScreenCover(isPresented: $showPrefMenu) {PrefMenu()}
    }}

extension StartMenu {
    
    func verifySpotSubscription() {
        if appDelegate.musicSub.type == .Spotify {
            print("Run1")
            if defaults.object(forKey: "SpotifyAuthCode") != nil && counter == 0 {
                print("Run2")
                refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
                refreshAccessToken = true
                // try runGetToken...if it fails....do what?
                runGetToken(authType: "refresh_token")
                counter += 1
            }
            else{
                print("Run3")
                // try requestSpotAuth...if it fails....do what?
                requestSpotAuth()
                runGetToken(authType: "code")
            }
            runInstantiateAppRemote()
            }
        }
        
    func verifyAMSubscription() {
        // try to get token...if it fails, do what?
        getAMUserToken()
        getAMStoreFront()
    }
    
    
    func getAMUserToken() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.taskToken == nil {
                SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {amAPI.getUserToken()} }
            }
        }
    }

    func getAMStoreFront() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.taskToken != nil && ranAMStoreFront == false {
                ranAMStoreFront = true
                SKCloudServiceController.requestAuthorization {(status) in if status == .authorized {
                    amAPI.storeFrontID = amAPI.fetchUserStorefront(userToken: amAPI.taskToken!, completionHandler: { ( response, error) in
                        amAPI.storeFrontID = response!.data[0].id
                    })}}}
            }
        }
    
    
    func requestSpotAuth() {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI().requestAuth(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("ccccccc")
                    print(response!)
                    if response!.contains("https://www.google.com/?code="){}
                    else{spotifyAuth.authForRedirect = response!; showWebView = true}
                    refreshAccessToken = true
                }}})
    }
    
    func getSpotToken() {
        print("called....requestSpotToken")
        tokenCounter = 1
        spotifyAuth.auth_code = authCode!
        SpotifyAPI().getToken(authCode: authCode!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    spotifyAuth.access_Token = response!.access_token
                    spotifyAuth.refresh_Token = response!.refresh_token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                    defaults.set(response!.refresh_token, forKey: "SpotifyRefreshToken")
                }
            }
            if error != nil {
                print("Error... \(error?.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
            }
        })
    }
    
    func getSpotTokenViaRefresh() {
        print("called....requestSpotTokenViaRefresh")
        tokenCounter = 1
        spotifyAuth.auth_code = authCode!
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI().getTokenViaRefresh(refresh_token: refresh_token!, completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    spotifyAuth.access_Token = response!.access_token
                    defaults.set(response!.access_token, forKey: "SpotifyAccessToken")
                }
            }
            if error != nil {
                print("Error... \(error?.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
            }
        })
    }
    
    func getAuthCodeAndTokenIfExpired() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if invalidAuthCode {requestSpotAuth()}
        }
    }

    func runGetToken(authType: String) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if tokenCounter == 0 && refreshAccessToken {
                if authType == "code" {if authCode != "" {getSpotToken()}}
                if authType == "refresh_token" {if refresh_token! != ""{getSpotTokenViaRefresh()}}
            }
        }
    }
    
    
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    func runInstantiateAppRemote() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if instantiateAppRemoteCounter == 0 {if spotifyAuth.access_Token != "" {instantiateAppRemote()}}
        }
    }
    
    func instantiateAppRemote() {
        print("called....instantiateAppRemote")
        print(spotifyAuth.access_Token)
        instantiateAppRemoteCounter = 1
        DispatchQueue.main.async {
            appRemote2 = SPTAppRemote(configuration: config, logLevel: .debug)
            appRemote2?.connectionParameters.accessToken = spotifyAuth.access_Token
        }
    }
    
    
    
    
    
    
    

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
