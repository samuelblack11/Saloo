//
//  MenuView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import SwiftUI

struct MenuView: View {
    
    @State private var createNew = false
    @State private var showPrior = false
     
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle().fill(.blue)
                    Text("Create New Card").foregroundColor(.white).font(.headline)
                    }
                    .onTapGesture {createNew = true}
                    .frame(width: 200, height: 200)
                    .sheet(isPresented: $createNew) {OccassionsMenu()}
                    .padding(.top, 20)
                Spacer()
                ZStack {
                    Rectangle().fill(.blue)
                    Text("View Prior Cards").foregroundColor(.white).font(.headline)
                }
                .onTapGesture {showPrior = true}
                .frame(width: 200, height: 200)
                .sheet(isPresented: $showPrior) {ShowPriorCardsView()}
                .padding(.bottom, 20)
            }
        }
    }
}
