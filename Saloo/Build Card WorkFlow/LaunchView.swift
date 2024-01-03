//
//  LoginView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//
import Foundation
import SwiftUI
import AuthenticationServices
import Security

struct LaunchView: View {
    @State var isFirstLaunch: Bool
    @State private var signInSuccess = false
    @State private var signInFailure = false
    @EnvironmentObject var appDelegate: AppDelegate
    let defaults = UserDefaults.standard
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var cardsForDisplay: CardsForDisplay
    @Binding var isPresentedFromECardView: Bool
    @Binding var cardFromShare: CoreCard?
    @State private var hasShownLaunchView: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                appDelegate.appColor.ignoresSafeArea()
                Image("logo1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.screenWidth/2, maxHeight: UIScreen.screenHeight/3, alignment: .center)
                if isFirstLaunch{
                    SignInButtonView(isPresentedFromECardView: $isPresentedFromECardView, cardFromShare: $cardFromShare)
                        .onAppear{cardsForDisplay.fetchFromCloudKit()}
                }
                LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
            }
            .background(appDelegate.appColor)
            .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType,
                                   goToSettings: {DispatchQueue.main.async{AppState.shared.currentScreen = .preferences}},
                                   updateMusicLaterPrompt: {alertVars.alertType = .updateMusicSubAnyTime}
                                  
                    ))
        }
    }
}

struct SignInButtonView: View {
    @State private var signInSuccess = false
    @EnvironmentObject var appState: AppState
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var cardsForDisplay: CardsForDisplay
    let defaults = UserDefaults.standard
    @Binding var isPresentedFromECardView: Bool
    @Binding var cardFromShare: CoreCard?
    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            // Successful authorization
                            switch authResults.credential {
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                let userId = appleIDCredential.user
                                self.defaults.set(userId, forKey: "SalooUserID")
                                APIManager.shared.createUser(userID: userId) { (createdUser, error) in
                                    cardsForDisplay.userID = userId
                                    userSession.salooID = userId
                                }
                                signInSuccess = true
                                UserSession.shared.updateLoginStatus()
                                UserDefaults.standard.register(defaults: ["FirstLaunch": true])
                                //AppState.shared.currentScreen = .preferences
                                AppState.shared.currentScreen = .startMenu
                                isPresentedFromECardView = false
                                cardFromShare = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                                    alertVars.alertType = .addMusicSubOnFirstLogin
                                    alertVars.activateAlert = true
                                }
                            default:
                                break
                            }
                        case .failure(let error):
                            // Handle error.
                            print("Authorization failed: " + error.localizedDescription)
                            alertVars.alertType = .signInFailure
                            alertVars.activateAlert = true
                        }
                })
                .frame(height: 60, alignment: .center)
                .padding(.bottom, 25)
                Link("Terms of Use & License Agreement", destination: URL(string: "https://www.salooapp.com/terms-license")!)
                    .foregroundColor(Color.white)
                Link("Privacy Policy", destination: URL(string: "https://www.salooapp.com/privacy-policy")!)
                    .foregroundColor(Color.white)
                    .padding(.bottom, 15)
        }
        .padding(.leading, 35)
        .padding(.trailing, 35)
    }
}

extension SignInButtonView {


}
