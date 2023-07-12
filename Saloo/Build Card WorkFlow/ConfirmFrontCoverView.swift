//
//  ConfirmFrontCoverView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//
// 

import Foundation
import SwiftUI

struct ConfirmFrontCoverView: View {
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var chosenOccassion: Occassion
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var appState: AppState
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State private var hasShownLaunchView: Bool = true
    @EnvironmentObject var cardProgress: CardProgress



    var body: some View {
        NavigationView {
            VStack {
                ProgressBar().frame(height: 20)
                ZStack {
                    VStack {
                        Image(uiImage: UIImage(data: chosenObject.coverImage)!)
                            .resizable()
                            .frame(width: 250, height: 250)
                            .padding(.top, 50)
                        VStack(spacing: 0) {
                            Text("Photo By ")
                            Link(String(chosenObject.coverImagePhotographer), destination: URL(string: "https://unsplash.com/@\(chosenObject.coverImageUserName)")!)
                            Text(" On ")
                            Link("Unsplash", destination: URL(string: "https://unsplash.com")!)
                        }
                        Spacer()
                        Button("Confirm Image") {
                            cardProgress.currentStep = 2
                            appState.currentScreen = .buildCard([.collageBuilder])
                            PhotoAPI.pingDownloadURL(downloadLocation: chosenObject.downloadLocation, completionHandler: { (response, error) in
                                if response != nil {
                                    //debugPrint("Ping Success!.......")
                                    //debugPrint(response)
                                }
                                if response == nil {
                                    //debugPrint("Ping Failed!.......")
                                    
                                }})
                        }.padding(.bottom, 10)
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
            }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
        .navigationBarItems(leading:
            Button {
                print("Back button tapped")
                cardProgress.currentStep = 1
                appState.currentScreen = .buildCard([.unsplashCollectionView])
            } label: {
                Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")
            }.disabled(gettingRecord.isShowingActivityIndicator))
        }
    }
    
    
}
