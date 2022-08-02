//
//  DateDetailView.swift
//  GreetMe-2
//
//  Created by Sam Black on 8/1/22.
//

import Foundation
import CoreData
import SwiftUI



struct DateDetailView: View {
    var name = "dateTestText"
    var selectedDate: Date
    var eventsFromCore: [CalendarDate]
    @State var eventsForShow = [CalendarDate]()
    
    func determineEventsForShow(date: Date) {
        for event in eventsFromCore {
            if date == event.eventDateCore! {
                self.eventsForShow = [event]
            }
        }
    }
    
    var body: some View {
        List(content: eventsForShow)
            .onAppear{self.determineEventsForShow(date: selectedDate)}
    }
}
