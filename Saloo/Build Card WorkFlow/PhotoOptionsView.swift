//
//  PhotoOptionsView.swift
//  Saloo
//
//  Created by Sam Black on 6/27/23.
//

import Foundation
import SwiftUI
import UIKit
import FSCalendar
import CoreData


struct PhotoOptionsView: View {
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var collageImage: CollageImage
    @State private var showImagePicker = false
    @State private var transitionVariable = false
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var alertVars = AlertVars.shared
    @State private var hasShownLaunchView: Bool = true
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            VStack {
                Text("Your card can include up to 5 photos")
                    .multilineTextAlignment(.center)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 5)
                Text("One of these can be a photo occasion specific photo curated by Saloo").multilineTextAlignment(.center).foregroundColor(colorScheme == .dark ? .white : .black)
                Text("This photo will take up about 1/4 of the screen").multilineTextAlignment(.center).foregroundColor(colorScheme == .dark ? .white : .black)
                Text("Do you want to include one of these photos, or use only personal photos?").multilineTextAlignment(.center).foregroundColor(colorScheme == .dark ? .white : .black)

                RadioButtonGroup(items: ["Yes", "No"], selectedId: $chosenObject.frontCoverIsPersonalPhoto)
                Spacer()
                Text("You'll also make a collage as part of your card\nWhich of the below options would you like to use?")
                    .multilineTextAlignment(.center)

                MiniCollageMenu()
                    .padding(.bottom, 5)
                Button(action: {appState.currentScreen = .buildCard([.occasionsMenu])
                    
                }) {
                Text("Confirm Selection")
                    .frame(height: 24)
                    .padding(.top, 15)
                }
                
            }
            LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
        .environmentObject(collageImage)
    }
}








struct RadioButtonGroup: View {
    let items: [String]
    @Binding var selectedId: Int

    var body: some View {
        VStack {
            ForEach(0..<items.count) { index in
                HStack {
                    Text(items[index])
                    RadioButton(id: index, selectedId: $selectedId)
                }
                .contentShape(Rectangle())
                .onTapGesture {selectedId = index}
            }
        }
    }
}

struct RadioButton: View {
    let id: Int
    @Binding var selectedId: Int

    var body: some View {
        Circle()
            .fill(id == selectedId ? Color.blue : Color.clear)
            .frame(width: 20, height: 20)
            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
    }
}
