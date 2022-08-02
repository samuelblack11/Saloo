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
// https://github.com/dmi3j/calendar-demo

import Foundation
import SwiftUI
import FSCalendar

struct MenuView: View {
    
    @State private var createNew = false
    @State private var showSent = false
    @State private var showReceived = false
    @State var cards = [Card]()

    @State var searchObject: SearchParameter!
    @State var searchType: String!
    @State var noneSearch: String!
    @ObservedObject var calViewModel: CalViewModel

    func addStandardEventsToCalendar() {
        //let defaults = UserDefaults.standard
        // if first logon
        //if defaults.bool(forKey: "First Launch") == true {
            
       //     }
       // else {
        //    let eventList3 = [String : Date]()
        //    let events = PreSetCalendarDates(eventList: eventList3)
        //    for (eventName, eventDate) in events.eventList {
        //        let event = CalendarDate(context: CoreDataStack.shared.context)
         //       event.eventNameCore = eventName
         //       event.eventDateCore = eventDate
         //       self.saveContext()
            //}
          //  defaults.set(true, forKey: "First Launch")
        //}
        //deleteAllForEntity()
        let eventList3 = [String : Date]()
        let events = PreSetCalendarDates(eventList: eventList3)
        for (eventName, eventDate) in events.eventList {
            let event = CalendarDate(context: CoreDataStack.shared.context)
            event.eventNameCore = eventName
            event.eventDateCore = eventDate
            print(eventName)
            self.saveContext()
        }
    }
    
    func saveContext() {
        if CoreDataStack.shared.context.hasChanges {
            do {
                try CoreDataStack.shared.context.save()
                }
            catch {
                print("An error occurred while saving: \(error)")
                }
            }
        }
    var body: some View {
        //NavigationView {
            VStack {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 36))
                    .padding(.top, 30)
                Spacer()
                CalendarView(calendar: calViewModel.calendar, isCalendarExpanded: $calViewModel.isCalendarExpanded)
                Spacer()
                HStack {
                    Button{showSent = true} label: {
                        Image(systemName: "tray.and.arrow.up.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                        }
                    Spacer()
                    Button{createNew = true} label: {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))

                        }
                    Spacer()
                    Button{showReceived = true} label: {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                        }
                    }
                    .padding(.bottom, 30)
                    .sheet(isPresented: $createNew) {OccassionsMenu(searchType: $searchType, noneSearch: $noneSearch)}
                    .sheet(isPresented: $showSent) {ShowPriorCardsView()}
                    //.sheet(isPresented: $showReceived) {}
            }.onAppear{self.addStandardEventsToCalendar()}
        //}
        
    }
}
