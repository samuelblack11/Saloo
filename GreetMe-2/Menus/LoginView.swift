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
    @State var chosenObject: CoverImageObject!
    @State var collageImage: CollageImage!
    @State var noteField: NoteField!
    
    
    
    var body: some View {
        //NavigationView {
        ZStack {
            Image("hamid-roshaan-BQrzI0vi9x0-unsplash").resizable()
            VStack {
                HStack {
                    Text("GreetMe ")
                        .padding(.top, 50)
                        .foregroundColor(.white)
                        .font(.system(size: 48))
                        .font(.headline)
                    Image(systemName: "greetingcard.fill")
                        .padding(.top, 50)
                        .foregroundColor(.white)
                        .font(.system(size: 48))
                    }
                Spacer()
                // https://swifttom.com/2020/09/28/how-to-add-sign-in-with-apple-to-a-swiftui-project/
                SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success (let authenticationResults):
                                signInSuccess = true
                                print("Authorization successful! :\(authenticationResults)")
                            case .failure(let error):
                                signInFailure = true
                                print("Authorization failed: " + error.localizedDescription)
                            }
                        }
                    )
                    .frame(height: 55, alignment: .center)
                    .padding(.bottom, 35)
                    .padding(.leading, 35)
                    .padding(.trailing, 35)
                }
            }
        //}
        .sheet(isPresented: $signInSuccess) {MenuView(searchObject: nil, calViewModel: CalViewModel())}
        .alert(isPresented: $signInFailure) {
            Alert(title: Text("Login Failed"), message: Text("Please Try Again"), dismissButton: .default(Text("Dismiss")))
            }
    }
}
