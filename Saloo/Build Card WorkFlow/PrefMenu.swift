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
import CloudKit

struct PrefMenu: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @State private var appWentToBackground = false
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
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
    @State var hasResetPassword = false
    @EnvironmentObject var userSession: UserSession
    var divideByVal = 1.2
    var listItemHeight: CGFloat = 95
    init() {
        if defaults.object(forKey: "MusicSubType") != nil {_currentSubSelection = State(initialValue: (defaults.object(forKey: "MusicSubType") as? String)!)}
        else {_currentSubSelection = State(initialValue: "Neither")}
    }
    
    
    private var settingsList: some View {
        List {
            subscriptionSection
            musicPreferenceSection
            privacySection
            accountSection
            musicServiceLinksSection
        }
    }

    private var subscriptionSection: some View {
        VStack {
            Text("Do you subscribe to either of these services?")
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .font(Font.custom("Papyrus", size: 16))
                .textCase(.none)
                .multilineTextAlignment(.center)
            Text("If you don't select a service and authorize your account you won't be able to include music in your cards")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .textCase(.none)
            }
        }

    private var musicPreferenceSection: some View {
        VStack {
                VStack {
                    if colorScheme == .dark {
                        Image("AMBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width/divideByVal, height: listItemHeight)
                            .clipped()
                    } else {
                        Image("AMLockupBlackType")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width/divideByVal, height: listItemHeight)
                            .clipped()
                    }
                }
                .background(colorScheme == .dark ? Color.black : Color.white)
                .onTapGesture {
                    musicColor = .pink
                    hideProgressView = false
                    apiManager.initializeAM() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){getAMUserTokenAndStoreFront{}}
                    }
                }
                //Divider()
                //HStack{
                //    Image("SpotifyLogo")
                //        .resizable()
                //        .scaledToFit()
                //        .frame(width: UIScreen.main.bounds.width/divideByVal, height: listItemHeight)
                //        .clipped()
                //}
                //.frame(height: listItemHeight)
                //.onTapGesture {spotAuthLogic()}
                Divider()
                Text("None")
                    .font(Font.custom("Papyrus", size: 24))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(height: listItemHeight)
                    .onTapGesture {appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType"); appState.currentScreen = .startMenu}
            }
    }

    private var privacySection: some View {
        VStack(alignment: .leading) {
            Button(action: {
                if let url = URL(string: "https://www.salooapp.com/terms-license") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Terms of Use & License Agreement")
                    .foregroundColor(Color.blue)
            }
            Divider()
            Button(action: {
                if let url = URL(string: "https://www.salooapp.com/privacy-policy") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Privacy Policy")
                    .foregroundColor(Color.blue)
            }
        }
    }


    private var accountSection: some View {
        VStack(alignment: .leading) {
            Button(action: {
                alertVars.alertType = .deleteAccount
                alertVars.activateAlert = true
            })
            {Text("Delete My Account").foregroundColor(Color.red)}
        }
    }

    private var musicServiceLinksSection: some View {
        VStack(alignment: .leading) {
            Button(action: {
                openAppOrAppStore(scheme: "music://", appStore: "https://apps.apple.com/app/spotify-music-and-podcasts/id324684580")
            }) {Text("Visit the Music App")}
            //Divider()
            //Button(action: {
            //    openAppOrAppStore(scheme: "spotify://", appStore: "https://apps.apple.com/app/spotify-music-and-podcasts/id324684580")
            //}) {Text("Visit the Spotify App")}
        }
    }

    private var spotifyAuthView: some View {
        WebVCView(authURLForView: spotifyManager.authForRedirect, authCode: $authCode)
            .onReceive(Just(authCode)) { newAuthCode in
                if let unwrappedAuthCode = newAuthCode, !unwrappedAuthCode.isEmpty {
                    spotifyManager.auth_code = newAuthCode!
                    print(newAuthCode!)
                        spotifyManager.getSpotToken { success in
                            if newAuthCode == "AuthFailed" {
                                currentSubSelection = "Neither"
                                appDelegate.musicSub.type = .Neither
                                alertVars.alertType = .spotAuthFailed
                                alertVars.activateAlert = true
                            }
                            else {
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
                    //}
                }
                else {hideProgressView = true}
            }    }
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .startMenu}, titleContent: .text("Settings"))
                    .frame(height: 60)                
                ZStack {
                    List {
                        Section(header: VStack(alignment: .leading) {
                            Text("Music Preferences").font(.system(size: 20))
                            Text("Current Selection: \(currentSubSelection == "Neither" ? "None" : currentSubSelection)")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(Font.custom("Papyrus", size: 16))
                            .textCase(.none) })
                        {musicPreferenceSection}
                        Section(header: Text("Policies & Agreements").font(.system(size: 20))) {privacySection}
                        Section(header: Text("Account").font(.system(size: 20))) {accountSection}
                        Section(header: Text("Music Service Links").font(.system(size: 20))) {musicServiceLinksSection}
                    }
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
        }
        .onDisappear {
            UserDefaults.standard.set(false, forKey: "FirstLaunch")
            if appDelegate.musicSub.type == .Spotify {spotifyManager.instantiateAppRemote()}
        }
        .onAppear {
            if defaults.object(forKey: "MusicSubType") != nil {currentSubSelection = (defaults.object(forKey: "MusicSubType") as? String)!}
            else {currentSubSelection = "Neither"; appDelegate.musicSub.type = .Neither; defaults.set("Neither", forKey: "MusicSubType")}
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType,
                  alertDismissAction: {hideProgressView = true},
                  deleteAccountAction:{deleteAccount()},
                  switchSpotAccounts: {self.resetSpotCredentials{self.spotAuthLogic()}},
                  keepSpotAccount: {}))
        .sheet(isPresented: $spotifyManager.showWebView) {spotifyAuthView}
    }
}

extension PrefMenu {
    
    func deleteAccount() {
        gettingRecord.isLoadingAlert = true
        deleteAllCoreCards {
            deleteFromPrivate(database: PersistenceController.shared.cloudKitContainer.privateCloudDatabase) {
                deleteFromPublic(database: PersistenceController.shared.cloudKitContainer.publicCloudDatabase) {
                    clearUserDefaults()
                    DispatchQueue.main.async {
                        gettingRecord.isLoadingAlert = false
                        userSession.isSignedIn = false
                        hasShownLaunchView = false
                    }
                }
            }
            
        }

    }
    func deleteFromPrivate(database: CKDatabase, completion: @escaping () -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("CloudKit fetch error: \(error.localizedDescription)")
                return
            }
            guard let records = records else { return }
            for record in records {
                database.delete(withRecordID: record.recordID) { (recordID, error) in
                    if let error = error {
                        print("Failed to delete record: \(error.localizedDescription)")
                    } else if let recordID = recordID {
                        print("Deleted record: \(recordID.recordName)")
                    }
                }
            }
            completion()
        }
    }
    
    func deleteFromPublic(database: CKDatabase, completion: @escaping () -> Void) {
        let predicate = NSPredicate(format: "CD_salooUserID == %@", CardsForDisplay.shared.userID!)
        let query = CKQuery(recordType: "CD_CoreCard", predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("CloudKit fetch error: \(error.localizedDescription)")
                return
            }
            guard let records = records else { return }
            for record in records {
                database.delete(withRecordID: record.recordID) { (recordID, error) in
                    if let error = error {
                        print("Failed to delete record: \(error.localizedDescription)")
                    } else if let recordID = recordID {
                        print("Deleted record: \(recordID.recordName)")
                    }
                }
            }
            completion()
        }
    }


    
    func clearUserDefaults() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
        }
    }

    
    func deleteAllCoreCards(completion: @escaping () -> Void) {
        let request = CoreCard.createFetchRequest()
        var cardsFromCore: [CoreCard] = []
        do {cardsFromCore = try PersistenceController.shared.persistentContainer.viewContext.fetch(request); for card in cardsFromCore {deleteCoreCard(coreCard: card)}}
        catch{}
        completion()
    }
    
    func deleteCoreCard(coreCard: CoreCard) {
        do {PersistenceController.shared.persistentContainer.viewContext.delete(coreCard);try PersistenceController.shared.persistentContainer.viewContext.save()}
        catch {}
    }
    
    func resetSpotCredentials(completion: @escaping () -> Void) {
        spotifyManager.auth_code =  ""
        spotifyManager.refresh_token =  ""
        spotifyManager.access_token =  ""
        spotifyManager.authForRedirect =  ""
        spotifyManager.accessExpiresAt = Date()
        self.defaults.set("", forKey: "SpotifyAccessToken")
        self.defaults.set("", forKey: "SpotifyAccessTokenExpirationDate")
        self.defaults.set("", forKey: "SpotifyRefreshToken")
        self.defaults.set("", forKey: "SpotifyAuthCode")
        self.defaults.set("Neither", forKey: "MusicSubType")
        completion()
    }
    
    
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
        SKCloudServiceController.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Authorized")
                amAPI.getUserToken { response, error in
                    if let error = error {
                        print("Error getting user token: \(error.localizedDescription)")
                        // Handle the error appropriately
                        hideProgressView = true
                        alertVars.alertType = .amAuthFailed
                        alertVars.activateAlert = true
                    } else if let response = response {
                        //print("---RESPONSE: \(response)")
                        // Continue with processing the response
                    } else {
                        print("Response is nil and no error was provided")
                        hideProgressView = true
                        alertVars.alertType = .amAuthFailed
                        alertVars.activateAlert = true
                    }
                    completion()
                }
            case .notDetermined:
                print("Not Determined")
                fallthrough // To handle common behavior for non-authorized statuses
            case .denied, .restricted:
                print("Access Denied or Restricted")
                hideProgressView = true
                alertVars.alertType = .amAuthFailed
                alertVars.activateAlert = true
                completion()
            @unknown default:
                print("Unknown Status")
                hideProgressView = true
                alertVars.alertType = .amAuthFailed
                alertVars.activateAlert = true
                completion()
            }
        }
    }

    func getAMStoreFront(completion: @escaping () -> Void) {
        SKCloudServiceController.requestAuthorization { (status) in
            if status == .authorized {
                guard let userToken = amAPI.taskToken else {
                    print("Error: taskToken is nil")
                    return
                }
                amAPI.fetchUserStorefront(userToken: userToken) { response, error in
                    if let response = response {
                        amAPI.storeFrontID = response.data[0].id
                        currentSubSelection = "Apple Music"
                        appDelegate.musicSub.type = .Apple
                        defaults.set("Apple Music", forKey: "MusicSubType")
                        hideProgressView = true
                        alertVars.alertType = .musicAuthSuccessful
                        alertVars.activateAlert = true
                        appState.currentScreen = .startMenu
                    } else {
                        print("Error fetching user storefront: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    completion()
                }
            } else {
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
