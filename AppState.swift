//
//  AppState.swift
//  Saloo
//
//  Created by Sam Black on 6/13/23.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    enum Screen {
        case login
        case launch
        case startMenu
        case buildCard([BuildCardSteps]) // BuildCardSteps is an enum representing each step of the workflow
        case draft// parameters required for GridofCards
        case inbox
        case outbox
        case preferences
    }
    
    enum BuildCardSteps {
        case occasionsMenu
        case unsplashCollectionView
        case confirmFrontCoverView
        case collageStyleMenu
        case collageBuilder
        case writeNoteView
        case musicSearchView
        case finalizeCardView
        // any other steps you have
    }

    @Published var currentScreen: Screen = UserDefaults.standard.bool(forKey: "FirstLaunch") ? .preferences : .startMenu
}

struct ContentView: View {
    @EnvironmentObject var apiManager: APIManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cardsForDisplay: CardsForDisplay
    @EnvironmentObject var userSession: UserSession
    @State private var hasShownLaunchView = false
    @State private var offsetLaunchView = CGFloat.zero

    var body: some View {
        ZStack {
            Group {
                if userSession.isSignedIn {
                    switch appState.currentScreen {
                    case .login:
                        EmptyView()
                    case .launch:
                        EmptyView()
                    case .startMenu:
                        StartMenu()
                    case .buildCard(let steps):
                        BuildCardView(steps: steps)
                    case .draft:
                        GridofCards(cardsForDisplay: cardsForDisplay.cardsForDisplay, whichBoxVal: .draftbox)
                    case .inbox:
                        GridofCards(cardsForDisplay: cardsForDisplay.cardsForDisplay, whichBoxVal: .inbox)
                    case .outbox:
                        GridofCards(cardsForDisplay: cardsForDisplay.cardsForDisplay, whichBoxVal: .outbox)
                    case .preferences:
                        PrefMenu()
                    }

                    if !hasShownLaunchView {
                        LaunchView(isFirstLaunch: false)
                            .offset(x: offsetLaunchView, y: 0)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {offsetLaunchView = -UIScreen.main.bounds.width}
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        hasShownLaunchView = true
                                        appState.currentScreen = UserDefaults.standard.bool(forKey: "FirstLaunch") ? .preferences : .startMenu
                                    }
                                }
                            }
                    }
                } else {LaunchView(isFirstLaunch: true)}
            }
        }
    }
}




struct BuildCardView: View {
    let steps: [AppState.BuildCardSteps]

    var body: some View {
        ForEach(steps, id: \.self) { step in
            switch step {
            case .occasionsMenu:
                OccassionsMenu()
            case .unsplashCollectionView:
                UnsplashCollectionView()
            case .confirmFrontCoverView:
                ConfirmFrontCoverView()
            case .collageStyleMenu:
                CollageStyleMenu()
            case .collageBuilder:
                CollageBuilder(showImagePicker: false)//.environmentObject(collageImage)
            case .writeNoteView:
                WriteNoteView()
            case .musicSearchView:
                MusicSearchView()//.environmentObject(appDelegate)
            case .finalizeCardView:
                FinalizeCardView(cardType: CardPrep.shared.cardType)
            }
        }
    }
}

