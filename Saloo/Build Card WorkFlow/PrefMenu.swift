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
import Combine

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
    //@State var spotifyAuth = SpotifyAuth()
    @EnvironmentObject var spotifyManager: SpotifyManager
    @State private var tokenCounter = 0
    let config = SPTConfiguration(clientID: APIManager.shared.spotClientIdentifier, redirectURL: URL(string: "saloo://")!)
    @State var counter = 0
    @State private var runGetAMToken = true
    @State private var hideProgressView = true
    @State private var runCheckAMTokenErrorIfNeeded = false
    @State private var musicColor: Color?
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State private var authType = ""
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var appState: AppState

    init() {
        if defaults.object(forKey: "MusicSubType") != nil {_currentSubSelection = State(initialValue: (defaults.object(forKey: "MusicSubType") as? String)!)}
        else {_currentSubSelection = State(initialValue: "Neither")}
    }
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Do you subscribe to either of these services?")
                Text("This will help optimize your experience")
                Text("Current Selection: \(currentSubSelection)")
                ZStack {
                    List {
                        Text("Apple Music")
                            .onTapGesture {
                                musicColor = .pink
                                hideProgressView = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){getAMUserTokenAndStoreFront{}}
                            }
                        Text("Spotify")
                            .onTapGesture {
                                musicColor = .green
                                hideProgressView = false
                                if spotifyManager.auth_code == "AuthFailed" {spotifyManager.auth_code = ""}
                                counter = 0; tokenCounter = 0; showWebView = false; refreshAccessToken = false; getSpotCredentials{_ in}
                                
                            }
                        Text("I don't subscribe to either")
                            .onTapGesture {appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType"); showStart = true}
                    }
                    ProgressView()
                        .hidden(hideProgressView)
                        .tint(musicColor)
                        .scaleEffect(5)
                        .progressViewStyle(CircularProgressViewStyle())
                    LoadingOverlay()
                }
            }
            .navigationBarItems(leading:Button {showStart.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
        }
        .onDisappear {
            UserDefaults.standard.set(false, forKey: "FirstLaunch")
            if appDelegate.musicSub.type == .Spotify {spotifyManager.instantiateAppRemote()}
        }
        .onAppear {
            //redirectToAppStore(musicvendor: "Spotify")
            if defaults.object(forKey: "MusicSubType") != nil {currentSubSelection = (defaults.object(forKey: "MusicSubType") as? String)!}
            else {currentSubSelection = "Neither"; appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType")}
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
        //.environmentObject(appDelegate)
        .sheet(isPresented: $showWebView) {
            WebVCView(authURLForView: spotifyManager.authForRedirect, authCode: $authCode)
                .onReceive(Just(authCode)) { newAuthCode in
                    if let authCode = newAuthCode, !authCode.isEmpty {
                        if authType == "code", !authCode.isEmpty {
                            getSpotToken { success in
                                print("Called getSpotToken from auth....")
                                print(authCode)
                                print(success)
                                counter += 1
                                currentSubSelection = "Spotify"
                                appDelegate.musicSub.type = .Spotify
                                defaults.set("Spotify", forKey: "MusicSubType")
                                hideProgressView = true
                                if appDelegate.musicSub.type == .Spotify {print("Called instan..."); spotifyManager.instantiateAppRemote()}
                                showStart = true
                                //completion(success)
                            }
                        } else if authType == "refresh_token", !refresh_token!.isEmpty {
                            getSpotTokenViaRefresh { success in
                                //completion(success)
                            }
                        } else if authCode == "AuthFailed" {
                            print("Unable to authorize")
                            currentSubSelection = "Neither"
                            appDelegate.musicSub.type = .Neither
                            alertVars.alertType = .spotAuthFailed
                            alertVars.activateAlert = true
                            //completion(false)
                        }
                    }
                }
        }

        .fullScreenCover(isPresented: $showStart) {StartMenu()}
    }
}

extension PrefMenu {
    
    //redirectToAppStore(musicVendor: currentSubSelection)
    
    func redirectToAppStore(musicvendor: String) {
        print("called redirectToAppStore...")
        
        
        print(UIApplication.shared.canOpenURL(URL(string: "spotify://")!))
        UIApplication.shared.open(URL(string: "spotify://")!)
        //if UIApplication.shared.canOpenURL(URL(string: "spotify://")!) {}
        //else{print("Can't open Spotify because it's not installed")}
    }
    

    
    func progView() -> some View {
        
        return
        ProgressView()
            .foregroundColor(.pink)
            .scaleEffect(5)
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    
    func getAMUserTokenAndStoreFront(completion: @escaping () -> Void) {
        if networkMonitor.isConnected {
            getAMUserToken { [self] in
                checkAMTokenError {
                    getAMStoreFront(completion: completion)
                }
            }
        }
        else{hideProgressView = true;
            alertVars.alertType = .failedConnection
            alertVars.activateAlert = true
        }
    }

    func getAMUserToken(completion: @escaping () -> Void) {
        SKCloudServiceController.requestAuthorization {(status) in
            if status == .authorized {
                amAPI.getUserToken { response, error in
                    print("Checking Token"); print(response); print("^^"); print(error)
                    completion()
                }
            }
        }
    }

    func getAMStoreFront(completion: @escaping () -> Void) {
        SKCloudServiceController.requestAuthorization {(status) in
            if status == .authorized {
                amAPI.fetchUserStorefront(userToken: amAPI.taskToken!) { response, error in
                    amAPI.storeFrontID = response!.data[0].id
                    currentSubSelection = "Apple Music"
                    appDelegate.musicSub.type = .Apple
                    defaults.set("Apple Music", forKey: "MusicSubType")
                    hideProgressView = true
                    showStart = true
                    completion()
                }
            }
            else {
                currentSubSelection = "Neither"
                appDelegate.musicSub.type = .Neither
                alertVars.alertType = .amAuthFailed
                alertVars.activateAlert = true
            }
        }
    }

    func checkAMTokenError(completion: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if amAPI.tokenError == true && runCheckAMTokenErrorIfNeeded {
                alertVars.alertType = .amAuthFailed
                alertVars.activateAlert = true
                runCheckAMTokenErrorIfNeeded = false
                timer.invalidate()
                completion()
            } else if amAPI.tokenError == false {
                timer.invalidate()
                completion()
            }
        }
    }

    func getSpotCredentials(completion: @escaping (Bool) -> Void) {
        print("Run1")
        if defaults.object(forKey: "SpotifyAuthCode") != nil && counter == 0 {
            print("Run2")
            refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
            refreshAccessToken = true
            if networkMonitor.isConnected {
                getSpotTokenViaRefresh { success in
                    if success {
                        counter += 1
                        currentSubSelection = "Spotify"
                        appDelegate.musicSub.type = .Spotify
                        defaults.set("Spotify", forKey: "MusicSubType")
                        hideProgressView = true
                        if appDelegate.musicSub.type == .Spotify {spotifyManager.instantiateAppRemote()}
                        showStart = true
                        completion(true)
                    } else {
                        alertVars.alertType = .spotAuthFailed
                        alertVars.activateAlert = true
                        //currentSubSelection = "Neither"
                        //appDelegate.musicSub.type = .Neither
                        hideProgressView = true
                        completion(false)
                    }
                }
            } else {
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
                //currentSubSelection = "Neither"
                //appDelegate.musicSub.type = .Neither
                hideProgressView = true
                completion(false)
            }
        } else {
            print("Run3")
            if networkMonitor.isConnected {
                authType = "code"
                requestAndRunToken(authType: authType) { success in
                    print("Checking...")
                    print(success)
                    if success {
                        currentSubSelection = "Spotify"
                        appDelegate.musicSub.type = .Spotify
                        defaults.set("Spotify", forKey: "MusicSubType")
                        hideProgressView = true
                        if appDelegate.musicSub.type == .Spotify {spotifyManager.instantiateAppRemote()}
                        showStart = true
                        completion(true)
                    } else {
                        alertVars.alertType = .spotAuthFailed
                        alertVars.activateAlert = true
                        //currentSubSelection = "Neither"
                        //appDelegate.musicSub.type = .Neither
                        hideProgressView = true
                        completion(false)
                    }
                }
            } else {
                alertVars.alertType = .failedConnection
                alertVars.activateAlert = true
                //currentSubSelection = "Neither"
                //appDelegate.musicSub.type = .Neither
                hideProgressView = true
                completion(false)
            }
        }
    }
    
    func requestAndRunToken(authType: String, completion: @escaping (Bool) -> Void) {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI.shared.requestAuth { response, error in
            guard let response = response else {
                // handle error
                print(error ?? "Unknown error")
                completion(false)
                return
            }
            
            DispatchQueue.main.async {
                print("ccccccc")
                print(response)
                print(authType)
                print(authCode)
                spotifyManager.authForRedirect = response
                showWebView = true
                refreshAccessToken = true
                if authType == "refresh_token", !refresh_token!.isEmpty {
                    getSpotTokenViaRefresh { success in
                        completion(success)
                    }
                } else if authCode == "AuthFailed" {
                    print("Unable to authorize")
                    currentSubSelection = "Neither"
                    appDelegate.musicSub.type = .Neither
                    alertVars.alertType = .spotAuthFailed
                    alertVars.activateAlert = true
                    completion(false)
                }
            }
        }
    }
    
    
    
    func requestSpotAuth() {
        print("called....requestSpotAuth")
        invalidAuthCode = false
        SpotifyAPI.shared.requestAuth(completionHandler: {(response, error) in
            if response != nil {
                DispatchQueue.main.async {
                    print("ccccccc")
                    print(response!)
                    if response!.contains("https://www.google.com/?code="){}
                    else{spotifyManager.authForRedirect = response!; showWebView = true}
                    refreshAccessToken = true
                }}})
    }
    

    
    func getSpotToken(completion: @escaping (Bool) -> Void) {
        print("called....requestSpotToken")
        tokenCounter = 1
        spotifyManager.auth_code = authCode!
        SpotifyAPI.shared.getToken(authCode: authCode!, completionHandler: {(response, error) in
            if let response = response {
                DispatchQueue.main.async {
                    spotifyManager.access_token = response.access_token
                    spotifyManager.appRemote?.connectionParameters.accessToken = spotifyManager.access_token
                    spotifyManager.refresh_token = response.refresh_token
                    print("Set Spot Access Token to: \(spotifyManager.access_token)")
                    print("Set Spot Refresh Token to: \(spotifyManager.refresh_token)")

                    defaults.set(response.access_token, forKey: "SpotifyAccessToken")
                    defaults.set(response.refresh_token, forKey: "SpotifyRefreshToken")
                    completion(true)
                }
            } else if let error = error {
                print("Error... \(error.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
                completion(false)
            }
        })
    }

    func getSpotTokenViaRefresh(completion: @escaping (Bool) -> Void) {
        print("called....requestSpotTokenViaRefresh")
        tokenCounter = 1
        spotifyManager.auth_code = authCode!
        refresh_token = (defaults.object(forKey: "SpotifyRefreshToken") as? String)!
        SpotifyAPI.shared.getTokenViaRefresh(refresh_token: refresh_token!, completionHandler: {(response, error) in
            if let response = response {
                DispatchQueue.main.async {
                    spotifyManager.access_token = response.access_token
                    spotifyManager.appRemote?.connectionParameters.accessToken = spotifyManager.access_token
                    defaults.set(response.access_token, forKey: "SpotifyAccessToken")
                    completion(true)
                }
            } else if let error = error {
                print("Error... \(error.localizedDescription)!")
                invalidAuthCode = true
                authCode = ""
                completion(false)
            }
        })
    }

    
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


}
extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
