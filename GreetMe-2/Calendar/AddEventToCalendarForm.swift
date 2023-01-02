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
        print("trying formatDate......")
        let dateForConversion = formatDate(eventDate: self.eventDate)
        let dateComps = dateForConversion.get(.day, .month, .year)
        print("formatDate success")
        if let originalEventDay = dateComps.day, let orignalEventMonth = dateComps.month, let originalEventYear = dateComps.year {
            
            print("day: \(originalEventDay), month: \(orignalEventMonth), year: \(originalEventYear)")
            
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
                    else {
                        recurringDateComps.year = originalEventYear
                    }
                    let date = Calendar.current.date(from: recurringDateComps)!
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    addEventToCore(eventName: eventName, eventDate: dateFormatter.string(from: date))
                    month+=1
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
                    recurringDateComps.month = month
                    recurringDateComps.year = year

                    let date = Calendar.current.date(from: recurringDateComps)!
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    addEventToCore(eventName: eventName, eventDate: dateFormatter.string(from: date))
                    year+=1
                    yearCount += 1
                }
            }
            }
        }
        print("addEventFreq Success!!")
    }
    
    func addEventToCore(eventName: String, eventDate: String) {
        let formattedEventDate = formatDate(eventDate: eventDate)
        let event = CalendarDate(context: CoreDataStack.shared.context)
        event.eventNameCore = eventName + " \(emoji)"
        event.eventDateCore = formattedEventDate
        print("Event Added For: ")
        print(eventName)
        print(eventDate)
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

// https://stackoverflow.com/questions/53356392/how-to-get-day-and-month-from-date-type-swift-4
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }

    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
    
}
