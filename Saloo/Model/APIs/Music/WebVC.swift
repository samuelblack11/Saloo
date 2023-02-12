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
    var webView: WKWebView!
    var authURL: String?
    @State var redirectedURL = String()
    
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
    
    override func viewDidLoad() {
        print("%%%")
        print(authURL)
        let url = URL(string: authURL!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        self.dismiss(animated: true, completion: nil)
        super.viewDidLoad()
    }
    

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("redirect received")
    }
    
}


struct WebVCView: UIViewControllerRepresentable {
    typealias UIViewControllerType = WebVC
    @State var authURLForView: String
    @State var redirectedURL = String()
    @EnvironmentObject var spotifyAuth: SpotifyAuth
    func makeUIViewController(context: Context) -> WebVC {
        //Return SpotAppRemoteVC Instance
        print("#$#$")
        print(spotifyAuth.authForRedirect)
        print(authURLForView)
        let vc = WebVC(authURL: authURLForView)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: WebVC, context: Context) {
        //Updates the state of the specified view controller with new information from SwiftUI.
    }
    

}

