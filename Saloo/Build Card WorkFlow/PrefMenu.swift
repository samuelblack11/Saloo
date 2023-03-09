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
import MediaPlayer
import StoreKit
import WebKit

struct PrefMenu: View {
    @State private var showStart = false
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let defaults = UserDefaults.standard
    @State var currentSubSelection: String
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @State private var storeFrontID = "us"
    @State private var userToken = ""
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
    @State var appRemote2: SPTAppRemote?
    @State private var showSpotAuthFailedAlert = false
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
                        .onTapGesture {counter = 0; tokenCounter = 0; showWebView = false; verifySpotSubscription()}
                    Text("I don't subscribe to either")
                        .onTapGesture {appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType"); showStart = true}
                }
            }
            .navigationBarItems(leading:Button {showStart.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
        }
        .onAppear {
            //verifySpotSubscription()
            print("&&& \(defaults.object(forKey: "MusicSubType"))")
            if defaults.object(forKey: "MusicSubType") != nil {currentSubSelection = (defaults.object(forKey: "MusicSubType") as? String)!}
            else {currentSubSelection = "Neither"}
        }
        //.environmentObject(appDelegate)
        .alert("Spotify Authorization Failed. If you do have a Spotify Subscription, please try authorizing again", isPresented: $showSpotAuthFailedAlert){Button("Ok"){}}
        .sheet(isPresented: $showWebView){WebVCView(authURLForView: spotifyAuth.authForRedirect, authCode: $authCode)}
        .fullScreenCover(isPresented: $showStart) {StartMenu()}
    }
}

extension PrefMenu {
    func verifySpotSubscription() {
            print("Run1")
            if defaults.object(forKey: "SpotifyAuthCode") != nil && (defaults.object(forKey: "SpotifyAuthCode") as? String)! != "AuthFailed" && counter == 0 {
                print("Run2")
                refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
                refreshAccessToken = true
                runGetToken(authType: "refresh_token")
                counter += 1
            }
            else{
                print("Run3")
                requestSpotAuth()
                runGetToken(authType: "code")
            }
            runInstantiateAppRemote()
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
    
    func runGetToken(authType: String) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if tokenCounter == 0 && refreshAccessToken {
                if authType == "code" {if authCode != "" {getSpotToken();showStart = true}}
                if authType == "refresh_token" {if refresh_token! != ""{getSpotTokenViaRefresh();showStart = true}}
                if defaults.object(forKey: "SpotifyAuthCode") != nil {
                    if (defaults.object(forKey: "SpotifyAuthCode") as? String)! == "AuthFailed" {
                        print("Unable to authorize")
                        tokenCounter = 1
                        appDelegate.musicSub.type = .Neither
                        currentSubSelection = "Neither"
                        showSpotAuthFailedAlert = true
                        print("---")
                        print(showSpotAuthFailedAlert)
                    }
                }
                
            }
        }
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
                    appDelegate.musicSub.type = .Spotify
                    defaults.set("Spotify", forKey: "MusicSubType")
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
                    appDelegate.musicSub.type = .Spotify
                    defaults.set("Spotify", forKey: "MusicSubType")
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
    
    
}
