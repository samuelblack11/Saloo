//
//  MenuView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//
// Create Calendar App
//https://www.youtube.com/watch?v=5Jwlet8L84w
//https://cocoapods.org/pods/CalendarKit
// https://developer.apple.com/documentation/eventkit/retrieving_events_and_reminders

import Foundation
import SwiftUI

struct MenuView: View {
    
    @State private var createNew = false
    @State private var showPrior = false
    @State var searchObject: SearchParameter!
    @State var searchType: String!
    @State var noneSearch: String!
     
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    
                    FSCalendar
                    
                    
                    
                    
                    
                    }
                    .frame(width: (UIScreen.screenWidth/1), height: (UIScreen.screenHeight/1.15))
                HStack {
                    Image(uiImage: UIImage(systemName: "tray.and.arrow.up.fill")!)
                    Image(uiImage: UIImage(systemName: "plus")!)
                    Image(uiImage: UIImage(systemName: "tray.and.arrow.down.fill")!)
                    }
                    .frame(width: (UIScreen.screenWidth/1), height: (UIScreen.screenHeight/8))
            }
        }
    }
}



//ZStack {
//    Rectangle().fill(.blue)
 //   Text("Create New Card").foregroundColor(.white).font(.headline)
 //   }
 //   .onTapGesture {createNew = true}
 //   .frame(width: 200, height: 200)
 //   .sheet(isPresented: $createNew) {OccassionsMenu(searchType: $searchType, searchObject: searchObject, noneSearch: $noneSearch)}
  //  .padding(.top, 20)
//Spacer()
//ZStack {
 //   Rectangle().fill(.blue)
 //   Text("View Prior Cards").foregroundColor(.white).font(.headline)
//}
//.onTapGesture {showPrior = true}
//.frame(width: 200, height: 200)
//.sheet(isPresented: $showPrior) {ShowPriorCardsView()}
//.padding(.bottom, 20)
