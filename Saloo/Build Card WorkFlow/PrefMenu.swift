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
    @EnvironmentObject var apiManager: APIManager

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
                            .frame(height: 44)
                            .onTapGesture {
                                musicColor = .pink
                                hideProgressView = false
                                apiManager.initializeAM() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){getAMUserTokenAndStoreFront{}}
                                }
                            }
                        HStack{
                            Image("spotLogoLight")
                                .resizable()
                                .aspectRatio(contentMode: .fit) // Keep aspect ratio
                                .frame(height: 44)
                            }
                            .onTapGesture {
                                musicColor = .green
                                hideProgressView = false
                                apiManager.initializeSpotifyManager {
                                    if spotifyManager.auth_code == "AuthFailed" {spotifyManager.auth_code = ""}
                                    counter = 0; tokenCounter = 0
                                    //showWebView = false
                                    refreshAccessToken = false
                                    spotifyManager.updateCredentialsIfNeeded{success in
                                        print("updateCredentials success \(success)")
                                        if success {
                                            spotifyManager.onTokenUpdate = {
                                                currentSubSelection = "Spotify"
                                                appDelegate.musicSub.type = .Spotify
                                                defaults.set("Spotify", forKey: "MusicSubType")
                                                hideProgressView = true
                                                appState.currentScreen = .startMenu
                                            }
                                            spotifyManager.noNewTokenNeeded = {
                                                print("No New Token Needed...")
                                                hideProgressView = true
                                                alertVars.alertType = .musicAuthSuccessful
                                                alertVars.activateAlert = true
                                            }
                                        }
                                        else {
                                            spotifyManager.onTokenUpdate = {
                                                alertVars.alertType = .spotAuthFailed
                                                alertVars.activateAlert = true
                                                currentSubSelection = "Neither"
                                                appDelegate.musicSub.type = .Neither
                                                hideProgressView = true
                                            }
                                            spotifyManager.noInternet = {
                                                alertVars.alertType = .failedConnection
                                                alertVars.activateAlert = true
                                            }
                                        }
                                    }
                                }
                            }
                        Text("I don't subscribe to either")
                            .frame(height: 44)
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
        .sheet(isPresented: $spotifyManager.showWebView) {
            WebVCView(authURLForView: spotifyManager.authForRedirect, authCode: $authCode)
                .onReceive(Just(authCode)) { newAuthCode in
                    if let unwrappedAuthCode = newAuthCode, !unwrappedAuthCode.isEmpty  {
                        spotifyManager.auth_code = newAuthCode!
                        spotifyManager.getSpotToken { success in
                            if newAuthCode == "AuthFailed" {
                                currentSubSelection = "Neither"
                                appDelegate.musicSub.type = .Neither
                                alertVars.alertType = .spotAuthFailed
                                alertVars.activateAlert = true
                            }
                            else {
                                print("getSpotToken completion called...")
                                print(success)
                                currentSubSelection = "Spotify"
                                appDelegate.musicSub.type = .Spotify
                                defaults.set("Spotify", forKey: "MusicSubType")
                                spotifyManager.instantiateAppRemote()
                                hideProgressView = true
                                alertVars.alertType = .musicAuthSuccessful
                                alertVars.activateAlert = true
                                appState.currentScreen = .startMenu
                            }
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
                    alertVars.alertType = .musicAuthSuccessful
                    alertVars.activateAlert = true
                    appState.currentScreen = .startMenu
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
    
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


}
extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
