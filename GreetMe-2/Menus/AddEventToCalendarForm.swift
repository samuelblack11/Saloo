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

    let frequencies = ["One Time Only", "Monthly", "Annual"]

    
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
        HStack {
            Text("Select Event Frequency: ")
            Picker("Select Event Frequency", selection: $frequency) {
                ForEach(frequencies, id: \.self) {
                    Text($0)
                }
            }
            Spacer()
            }
        Button("Add Event") {
            addEventToCore()
            //eventsFromCore = loadCoreDataEvents()
            presentationMode.wrappedValue.dismiss()
            }
    }
}

extension AddEventToCalendarForm {
    
    
    func addEventFrequency(dateOfEvent: Date, frequency: String) {
        
        if frequency == "Monthly" {
            // Add
            var month = 0
            while month < 12 {
                //let components = DateComponents(year: dateOfEvent.year, month: month, day: dateOfEvent.day)
                //addEventToCore()
                month+=1
            }
            
            
            
        }
        
        if frequency == "Annual" {
            
        }
        
    }
    
    
    
    
    func addEventToCore() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedEventDate = dateFormatter.date(from: eventDate)
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
