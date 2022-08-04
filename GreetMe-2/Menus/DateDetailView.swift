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
    var selectedDate: Date
    @State var eventsForShow = [CalendarDate]()
    let columns = [GridItem(.fixed(140))]

    
    init(_ selectedDate: Date, _ eventsForShow: [CalendarDate] ) {
        self.selectedDate = selectedDate
        self.eventsForShow = eventsForShow
    }
    
    var body: some View {
        NavigationView {
            ForEach(eventsForShow, id: \.self) {event in
                Text(event.eventNameCore!)
                    }
                }
            }
    }
