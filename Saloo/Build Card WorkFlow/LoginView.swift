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
                    Spacer()
                    Image("logo180").frame(maxWidth: UIScreen.screenWidth/2,maxHeight: UIScreen.screenHeight/3, alignment: .center)
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
                                        createUser(userID: userId) { (createdUser, error) in
                                            print("CreateUser completion  called...")
                                            print(createdUser)
                                        }
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

extension LoginView {
    func createUser(userID: String, completion: @escaping (Bool, Error?) -> Void) {

        guard let url = URL(string: "https://saloouserstatus.azurewebsites.net/create_user") else {
            // Handle invalid URL error
            print("Invalid URL")
            completion(false, nil)
            return
        }
        
        let parameters: [String: Any] = [
            "user_id": userID,
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            print("Trying do")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            // Handle JSON serialization error
            print("JSON serialization error: \(error)")
            completion(false, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // Handle network error
                print("Network error: \(error)")
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                // Handle invalid response
                print("Invalid response")
                completion(false, nil)
                return
            }
            
            if httpResponse.statusCode == 200 {
                // User created successfully
                completion(true, nil)
            } else {
                // Handle non-200 status code
                let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                completion(false, error)
            }
        }
        
        task.resume()
    }

}
