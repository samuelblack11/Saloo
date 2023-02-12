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
    
    var webView: WKWebView!
    var authURL: String?
    //var del: MyDataSendingDelegateProtocol
    @Published var authCode = ""
    //let spotAuth = SpotifyAuth()
    var delegate: MyDataSendingDelegateProtocol? = nil
    
    init(authURL: String) {
        self.authURL = authURL
        //self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        print("%%%")
        print(authURL)
        let url = URL(string: authURL!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        super.viewDidLoad()
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            print("observeValue \(key)")
            let key_string = "\(key)"
            if key_string.contains("code=") {
                DispatchQueue.main.async {
                    let redirectURL = self.webView.url!.absoluteString
                    let splitRedirectURL = redirectURL.components(separatedBy: "code=")
                    self.authCode = splitRedirectURL[1]
                    print("<<<<")
                    print(self.authCode)
                    self.delegate?.sendDataToFirstViewController(strCode: self.authCode)
                    //self.spotAuth.auth_code = splitRedirectURL[1]
                    self.dismiss(animated: true)
                }
            }
            //self.dismiss(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("redirect received. The accounts.spotify url was the input, and it converted to the redirectURI after Spotify Login")
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
            //guard let provider = strCode else {return}
            self.parent.authCode = strCode
        }
        
    }
    
    func makeUIViewController(context: Context) -> WebVC {
        //Return SpotAppRemoteVC Instance
        print("#$#$")
        print(authURLForView)
        
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


