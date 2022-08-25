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
    @State private var frequency: String = "One Time Only"
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
            addEventToCore(eventName: eventName, eventDate: eventDate)
            addEventFrequency(frequency: frequency)
            //eventsFromCore = loadCoreDataEvents()
            presentationMode.wrappedValue.dismiss()
            }
    }
}

extension AddEventToCalendarForm {
    
    
    func addEventFrequency(frequency: String) {
        
        if frequency != "One Time Only" {
        let dateForConversion = formatDate(eventDate: self.eventDate)
        var dateComps = DateComponents()
        do {
            dateComps = try DateComponents(from: dateForConversion as! Decoder)
        }
        catch {
            print("Couldn't convert date into components")
        }
        let originalEventDay = dateComps.day!
        let orignalEventMonth = dateComps.month!
        let originalEventYear = dateComps.year!
        var month: Int = orignalEventMonth
        var monthCount = 1
        
        if frequency == "Monthly" {
            month += 1
            if month == 13 {
                month = 1
            }
            while monthCount < 12 {
                var recurringDateComps = DateComponents()
                recurringDateComps.day = originalEventDay
                recurringDateComps.month = month
                if month == 1 {
                    recurringDateComps.year = Int(originalEventYear + 1)
                }
                let date = Calendar.current.date(from: recurringDateComps)!
                let dateFormatter = DateFormatter()
                addEventToCore(eventName: eventName, eventDate: dateFormatter.string(from: date))
                monthCount += 1
            }
        }
        
        var year: Int = originalEventYear
        var yearCount = 1
        if frequency == "Annual" {
            year += 1
            while yearCount < 10 {
                var recurringDateComps = DateComponents()
                recurringDateComps.day = originalEventDay
                recurringDateComps.month = orignalEventMonth
                recurringDateComps.year = year
                let date = Calendar.current.date(from: recurringDateComps)!
                let dateFormatter = DateFormatter()
                addEventToCore(eventName: eventName, eventDate: dateFormatter.string(from: date))
                yearCount += 1
            }
        }
        }
    }
    
    func addEventToCore(eventName: String, eventDate: String) {
        let formattedEventDate = formatDate(eventDate: eventDate)
        let event = CalendarDate(context: CoreDataStack.shared.context)
        event.eventNameCore = eventName + " \(emoji)"
        event.eventDateCore = formattedEventDate
        self.saveContext()
    }
    
    func formatDate(eventDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedEventDate = dateFormatter.date(from: eventDate)!
        return formattedEventDate
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
