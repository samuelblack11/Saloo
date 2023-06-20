//
//  AppState.swift
//  Saloo
//
//  Created by Sam Black on 6/13/23.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    enum Screen {
        case login
        case launch
        case startMenu
        case buildCard([BuildCardSteps]) // BuildCardSteps is an enum representing each step of the workflow
        case draft
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
    @EnvironmentObject var screenManager: ScreenManager
    @State private var hasShownLaunchView = false
    @State private var offsetLaunchView = CGFloat.zero
    // An array of IDs to cycle through
    private let ids = Array(1...5)
    // The current index in the ID array
    @State private var currentIndex = 0
    @State var falseBool = false

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
                        GridofCards(whichBoxVal: .draftbox)
                            .id(screenManager.currentId)
                    case .inbox:
                        GridofCards(whichBoxVal: .inbox)
                            .id(screenManager.currentId)
                    case .outbox:
                        GridofCards(whichBoxVal: .outbox)
                            .id(screenManager.currentId)
                    case .preferences:
                        PrefMenu()
                    }

                    if !hasShownLaunchView {
                        LaunchView(isFirstLaunch: false, isPresentedFromECardView: $falseBool)
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
                } else {LaunchView(isFirstLaunch: true, isPresentedFromECardView: $falseBool)}
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

