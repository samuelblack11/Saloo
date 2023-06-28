//
//  MusicMenu.swift
//  Saloo
//
//  Created by Sam Black on 2/4/23.
//

import Foundation
import SwiftUI
import UIKit
import CoreData
import MediaPlayer
import StoreKit
import WebKit
import Combine

struct PrefMenu: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @State private var appWentToBackground = false

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
    let appleBlack = Color(red: 11.0 / 255.0, green: 11.0 / 255.0, blue: 9.0 / 255.0)
    @State private var hasShownLaunchView: Bool = true

    var listItemHeight: CGFloat = 95
    init() {
        if defaults.object(forKey: "MusicSubType") != nil {_currentSubSelection = State(initialValue: (defaults.object(forKey: "MusicSubType") as? String)!)}
        else {_currentSubSelection = State(initialValue: "Neither")}
    }
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Do you subscribe to either of these services?").foregroundColor(colorScheme == .dark ? .white : .black)
                Text("This will optimize your experience").foregroundColor(colorScheme == .dark ? .white : .black)
                Text("Current Selection: \(currentSubSelection)").foregroundColor(colorScheme == .dark ? .white : .black)
                Text("If you don't select a service and authorize your account")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .textCase(.none)
                Text("you won't be able to include music in your cards")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .textCase(.none)
                ZStack {
                    //ScrollView {
                    VStack {
                        Divider()
                        VStack {
                            if colorScheme == .dark {
                                Image("AMBadge")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width)
                                    .clipped()
                            } else {
                                Image("AMLockupBlackType")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width)
                                    .clipped()
                            }
                        }
                        .background(colorScheme == .dark ? Color.black : Color.white) // Setting the background color
                        .onTapGesture {
                            musicColor = .pink
                            hideProgressView = false
                            apiManager.initializeAM() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){getAMUserTokenAndStoreFront{}}
                            }
                        }
                        Divider()
                        HStack{
                            Image("SpotifyLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width)
                                .clipped()
                        }
                        .frame(height: listItemHeight)
                        .onTapGesture {spotAuthLogic()}
                        Divider()
                        Text("I don't subscribe to either")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(height: listItemHeight)
                            .onTapGesture {appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType"); appState.currentScreen = .startMenu}
                        Divider()
                        Spacer()
                        HStack {
                            Button(action: {
                                openAppOrAppStore(scheme: "music://", appStore: "https://apps.apple.com/app/spotify-music-and-podcasts/id324684580")
                            }) {Text("Visit the Music App")}
                            Spacer()
                            Button(action: {
                                openAppOrAppStore(scheme: "spotify://", appStore: "https://apps.apple.com/app/spotify-music-and-podcasts/id324684580")
                            }) {Text("Visit the Spotify App")}
                        }
                    }
               // }
                    VStack {
                        Spacer()
                        ProgressView()
                            .hidden(hideProgressView)
                            .tint(musicColor)
                            .scaleEffect(3)
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                        .frame(height: UIScreen.screenHeight/5)
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
                
            }
            .navigationBarItems(leading:Button {appState.currentScreen = .startMenu} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
        }
        .onDisappear {
            UserDefaults.standard.set(false, forKey: "FirstLaunch")
            if appDelegate.musicSub.type == .Spotify {spotifyManager.instantiateAppRemote()}
        }
        .onAppear {
            if defaults.object(forKey: "MusicSubType") != nil {currentSubSelection = (defaults.object(forKey: "MusicSubType") as? String)!}
            else {currentSubSelection = "Neither"; appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType")}
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {
            hideProgressView = true}))
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
                                spotifyManager.verifySubType { isPremium in
                                    if isPremium {
                                        currentSubSelection = "Spotify"
                                        appDelegate.musicSub.type = .Spotify
                                        defaults.set("Spotify", forKey: "MusicSubType")
                                        spotifyManager.instantiateAppRemote()
                                        alertVars.alertType = .musicAuthSuccessful
                                        alertVars.activateAlert = true
                                        appState.currentScreen = .startMenu
                                    }
                                    else {
                                        currentSubSelection = "Neither"
                                        appDelegate.musicSub.type = .Neither
                                        defaults.set("Neither", forKey: "MusicSubType")
                                        alertVars.alertType = .spotNeedPremium
                                        alertVars.activateAlert = true
                                    }
                                    hideProgressView = true
                                }
                            
                            }
                        }
                    }
                }
        }
    }
}

extension PrefMenu {
    
    
    
    //func resetSpotCredentials(completion: @escaping () -> Void) {
    //    spotifyManager.auth_code =  ""
    //    spotifyManager.refresh_token =  ""
    //    spotifyManager.access_token =  ""
    //    spotifyManager.authForRedirect =  ""
    //    spotifyManager.accessExpiresAt = Date()
    //    self.defaults.set("", forKey: "SpotifyAccessToken")
   //     self.defaults.set("", forKey: "SpotifyAccessTokenExpirationDate")
    //    self.defaults.set("", forKey: "SpotifyRefreshToken")
   //     self.defaults.set("", forKey: "SpotifyAuthCode")
   //     self.defaults.set("Neither", forKey: "MusicSubType")
   //     print("_-------")
   //     print(spotifyManager.authForRedirect)
    //    completion()
   // }
    
    
    func spotAuthLogic() {
        musicColor = .green
        hideProgressView = false
        apiManager.initializeSpotifyManager {
            if spotifyManager.auth_code == "AuthFailed" {spotifyManager.auth_code = ""}
            counter = 0; tokenCounter = 0
            //showWebView = false
            refreshAccessToken = false
            spotifyManager.updateCredentialsIfNeeded{success in
                if success {
                    spotifyManager.verifySubType { isPremium in
                        if isPremium {
                            print("isPremium...\(isPremium)")
                            currentSubSelection = "Spotify"
                            appDelegate.musicSub.type = .Spotify
                            defaults.set("Spotify", forKey: "MusicSubType")
                            hideProgressView = true
                            alertVars.alertType = .musicAuthSuccessful
                            alertVars.activateAlert = true
                            appState.currentScreen = .startMenu
                        }
                        else { //if not premium
                            currentSubSelection = "Neither"
                            appDelegate.musicSub.type = .Neither
                            defaults.set("Neither", forKey: "MusicSubType")
                            alertVars.alertType = .spotNeedPremium
                            alertVars.activateAlert = true
                            hideProgressView = true
                        }
                    }
                }
                else {
                    alertVars.alertType = .spotAuthFailed
                    alertVars.activateAlert = true
                    currentSubSelection = "Neither"
                    appDelegate.musicSub.type = .Neither
                    hideProgressView = true
                    spotifyManager.noInternet = {
                        alertVars.alertType = .failedConnection
                        alertVars.activateAlert = true
                    }
                    spotifyManager.noInternet?()
                }
            }
        }
    }
    
    
    
    
    
    
    func openAppOrAppStore(scheme: String, appStore: String) {
        if let url = URL(string: scheme) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                print(success)
                if !success {
                    if let appStoreURL = URL(string: appStore) {
                        UIApplication.shared.open(appStoreURL)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if spotifyManager.gotToAppInAppStore == true {
                    if let url = URL(string: appStore) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    spotifyManager.gotToAppInAppStore = false
                }
            }
        }
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
                    if response == nil {
                        hideProgressView = true
                        alertVars.alertType = .amAuthFailed
                        alertVars.activateAlert = true
                    }
                    
                    
                    
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
