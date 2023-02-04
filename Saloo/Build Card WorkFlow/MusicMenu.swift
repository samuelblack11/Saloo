//
//  MusicMenu.swift
//  Saloo
//
//  Created by Sam Black on 2/4/23.
//

import Foundation
import SwiftUI
import UIKit
import FSCalendar
import CoreData


struct MusicMenu: View {
    @EnvironmentObject var musicSub: MusicSubscription
    @State private var showStart = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Do you subscribe to either of these services?")
                Text("This will help optimize your experience")
                List {
                    Text("Apple Music")
                        .onTapGesture {musicSub.type = .Apple; showStart = true}
                    Text("Spotify")
                        .onTapGesture {musicSub.type = .Spotify; showStart = true}
                    Text("I don't subscribe to either")
                        .onTapGesture {musicSub.type = .Neither; showStart = true}
                }
            }
        }
        .fullScreenCover(isPresented: $showStart) {StartMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView(), counter: 1)}
    }
}
