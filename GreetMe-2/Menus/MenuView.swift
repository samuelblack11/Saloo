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
import CoreData


public class ShowDetailView: ObservableObject {
    @Published public var showDetailView: Bool = false
}

struct MenuView: View {
    
    @State private var createNew = false
    @State private var showSent = false
    @State private var showReceived = false
    @State var cards = [Card]()
    @State var searchObject: SearchParameter!
    @State var searchType: String!
    @State var noneSearch: String!
    @ObservedObject var calViewModel: CalViewModel
    @ObservedObject var showDetailView: ShowDetailView
    @State var addEventToCalendarSheet = false
    @State var eventsFromCore: [CalendarDate]!
    
    var body: some View {
            VStack {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 36))
                    .padding(.top, 30)
            HStack {
                Spacer()
                Button{addEventToCalendarSheet = true} label: {
                    Text("Add Event")
                        .foregroundColor(.blue)
                        .font(.system(size: 18))
                    }
                }
                Spacer()
                CalendarView(calendar: calViewModel.calendar, isCalendarExpanded: $calViewModel.isCalendarExpanded, showDetailView: $calViewModel.showDetailView).onAppear{self.eventsFromCore = loadCoreDataEvents()}
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
                    .sheet(isPresented: $calViewModel.showDetailView.showDetailView) {DateDetailView(eventsForShow: calViewModel.eventsForShow)
                            //.presentationDetents([.medium])
                    }
                    .sheet(isPresented: $addEventToCalendarSheet) {AddEventToCalendarForm()}
            }
        }
    }

extension MenuView {
    func loadCoreDataEvents() -> [CalendarDate] {
        let request = CalendarDate.createFetchRequest()
        print(request)
        print("^^^^")
        let sort = NSSortDescriptor(key: "eventDateCore", ascending: false)
        request.sortDescriptors = [sort]
        var events: [CalendarDate] = []
        do {
            events = try CoreDataStack.shared.context.fetch(request)
            print("Got \(events.count) Events")
            print("loadCoreDataEvents Called....")
            print(events)
        }
        catch {
            print("Fetch failed")
        }
        return events
    }
}
