//
//  LoginView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//
import Foundation
import SwiftUI
import AuthenticationServices

struct LoginView: View {

    @State private var signInSuccess = false
    @State private var signInFailure = false
    @EnvironmentObject var appDelegate: AppDelegate
    let defaults = UserDefaults.standard

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Image("logo180").frame(maxWidth: UIScreen.screenWidth/2,maxHeight: UIScreen.screenHeight/3)
                    HStack {
                        Text("Saloo")
                            .padding(.top, 50)
                            .foregroundColor(.white)
                            .font(.system(size: 48))
                            .font(.headline)
                    }
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
                                        print("User id is \(userId)")
                                        self.defaults.set(userId, forKey: "SalooUserID")
                                        print(self.defaults.object(forKey: "SalooUserID"))
                                        signInSuccess = true
                                    default:
                                        break
                                    }
                                case .failure(let error):
                                    // Handle error.
                                    print("Authorization failed: " + error.localizedDescription)
                                    signInFailure = true
                                }
                        })
                        .frame(height: 55, alignment: .center)
                        .padding(.bottom, 35)
                        .padding(.leading, 35)
                        .padding(.trailing, 35)
                    
                    // Navigation to StartMenu on successful login
                    NavigationLink(destination: StartMenu(), isActive: $signInSuccess) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .background(appDelegate.appColor)
            .modifier(GettingRecordAlert())
        }
        .alert(isPresented: $signInFailure) {
            Alert(title: Text("Login Failed"), message: Text("Please Try Again"), dismissButton: .default(Text("Dismiss")))
        }
    }
}
