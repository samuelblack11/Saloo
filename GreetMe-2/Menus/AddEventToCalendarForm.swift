//
//  AddEventToCalendarForm.swift
//  GreetMe-2
//
//  Created by Sam Black on 8/6/22.
//

import Foundation
import Foundation
import SwiftUI
import FSCalendar
import CoreData


struct AddEventToCalendarForm: View {
    @State private var eventName: String = ""
    @State private var eventDate: String = ""
    @State private var emoji: String = ""
    @State private var frequency: String = ""
    var eventsFromCore = [CalendarDate]()
    @Environment(\.presentationMode) var presentationMode

    

    
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
        TextField("Event Name", text: $eventName)
            .padding(.leading, 5)
            .frame(height:35)
        TextField("Date (MM/DD/YYYY)", text: $eventDate)
            .padding(.leading, 5)
            .frame(height:35)
        TextField("Emoji for Calendar Display", text: $emoji)
            .padding(.leading, 5)
            .frame(height:35)
        TextField("Frequency", text: $frequency)
        
        Button("Add Event") {
            addEventToCore()
            //eventsFromCore = loadCoreDataEvents()
            presentationMode.wrappedValue.dismiss()
            }
    }
}

extension AddEventToCalendarForm {
    
    func addEventToCore() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedEventDate = dateFormatter.date(from: eventDate)
        print("*7*7")
        print(formattedEventDate)
        
        let event = CalendarDate(context: CoreDataStack.shared.context)
        event.eventNameCore = eventName + " \(emoji)"
        event.eventDateCore = formattedEventDate
        self.saveContext()
    }
    
    
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
