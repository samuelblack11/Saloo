//
//  WebVC.swift
//  Saloo
//
//  Created by Sam Black on 2/11/23.
//

import Foundation
import WebKit
import UIKit
import Foundation
import StoreKit
import SwiftUI

class WebVC: UIViewController, WKNavigationDelegate {
    
    func sendDataToFirstViewController(strCode: String?) {}
    let defaults = UserDefaults.standard
    var webView: WKWebView!
    var authURL: String?
    var delegate: MyDataSendingDelegateProtocol? = nil
    @ObservedObject var sceneDelegate = SceneDelegate()

    init(authURL: String) {
        self.authURL = authURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (defaults.object(forKey: "SpotifyAuthCode") as? String) == "AuthFailed" {
            self.defaults.set("AuthFailed", forKey: "SpotifyAuthCode")
            self.delegate?.sendDataToFirstViewController(strCode: "AuthFailed")
        }
        else if (defaults.object(forKey: "SpotifyAuthCode") as? String) == "password-reset" {
            self.defaults.set("password-reset", forKey: "SpotifyAuthCode")
            self.delegate?.sendDataToFirstViewController(strCode: "password-reset")
        }
        else if (defaults.object(forKey: "SpotifyAuthCode") as? String) == "signup" {
            self.defaults.set("signup", forKey: "SpotifyAuthCode")
            self.delegate?.sendDataToFirstViewController(strCode: "signup")
        }
    }
    
    override func viewDidLoad() {
        let url = URL(string: authURL!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        super.viewDidLoad()
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            let key_string = "\(key)"
            if key_string.contains("password-reset") {
                self.delegate?.sendDataToFirstViewController(strCode: "password-reset")
                self.defaults.set("password-reset", forKey: "SpotifyAuthCode")
                webView.removeObserver(self, forKeyPath: "URL")
            }
            else if key_string.contains("signup") {
                self.delegate?.sendDataToFirstViewController(strCode: "signup")
                self.defaults.set("signup", forKey: "SpotifyAuthCode")
                webView.removeObserver(self, forKeyPath: "URL")
            }
            else if key_string.contains("code=") {
                DispatchQueue.main.async {
                    let redirectURL = self.webView.url!.absoluteString
                    let splitRedirectURL = redirectURL.components(separatedBy: "code=")
                    let authCode = splitRedirectURL[1]
                    self.defaults.set(authCode, forKey: "SpotifyAuthCode")
                    self.delegate?.sendDataToFirstViewController(strCode: authCode)
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if (defaults.object(forKey: "SpotifyAuthCode") as? String) != "password-reset" && (defaults.object(forKey: "SpotifyAuthCode") as? String) != "signup"  {
            self.dismiss(animated: true)
        }
        else {
            
        }
    }
}


struct WebVCView: UIViewControllerRepresentable {
    typealias UIViewControllerType = WebVC
    @State var authURLForView: String
    @Binding var authCode: String?
    
    class Coordinator: NSObject, MyDataSendingDelegateProtocol {
        var parent: WebVCView
        init(_ parent: WebVCView) {self.parent = parent}
        
        
        func sendDataToFirstViewController(strCode: String?) {
            self.parent.authCode = strCode
        }
    }
    
    func makeUIViewController(context: Context) -> WebVC {
        
        let vc = WebVC(authURL: authURLForView)
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: WebVC, context: Context) {
        //Updates the state of the specified view controller with new information from SwiftUI.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

protocol MyDataSendingDelegateProtocol {
    func sendDataToFirstViewController(strCode: String?)
}
