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
                CustomNavigationBar(onBackButtonTap: {cardProgress.currentStep = 1; appState.currentScreen = .buildCard([.unsplashCollectionView])}, titleContent: .text("Confirm Photo"))
                ProgressBar().frame(height: 20)
                ZStack {
                    VStack {
                        Image(uiImage: UIImage(data: chosenObject.coverImage)!)
                            .resizable()
                            .frame(width: 250, height: 250)
                            .padding(.top, 50)
                        VStack(spacing: 0) {
                            Text("Photo By ").font(Font.custom("Papyrus", size: 16))
                            Link(String(chosenObject.coverImagePhotographer), destination: URL(string: "https://unsplash.com/@\(chosenObject.coverImageUserName)")!).font(Font.custom("Papyrus", size: 16))
                            Text(" On ").font(Font.custom("Papyrus", size: 16))
                            Link("Unsplash", destination: URL(string: "https://unsplash.com")!).font(Font.custom("Papyrus", size: 16))
                        }
                        Spacer()
                        

                        Button(action: {
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
                        }) {
                            Text("Confirm Image")
                                .font(Font.custom("Papyrus", size: 16))
                        }.padding(.bottom, 10)
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
            }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
        }
    }
    
    
}
