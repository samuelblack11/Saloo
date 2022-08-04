//
//  CalendarView.swift
//  GreetMe-2
//
//  Created by Sam Black on 8/1/22.
//

// https://www.hackingwithswift.com/quick-start/swiftui/displaying-a-detail-screen-with-navigationlink

import Foundation
import CoreData
import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable, View {
    var calendar: FSCalendar
    @Binding var isCalendarExpanded: Bool
    //var eventsFromCore: [CalendarDate]
    
    func makeUIView(context: Context) -> some UIView {
        calendar
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //let scope: FSCalendarScope = isCalendarExpanded ? .month : .week
        //uiView.setScope(scope, animated: false)
    }
}

extension CalendarView {
    
}

class CalViewModel: NSObject, ObservableObject {
    @Published var calendar = FSCalendar()
    @Published var isCalendarExpanded: Bool = true
    var eventsFromCore = [CalendarDate]()
    @Published var selectedDateOld: String = ""
    @State var selectedDate: Date!
    @State var eventsForShow = [CalendarDate]()
    @State var showDetailView: Bool = false
    
    override init() {
        super.init()
        addStandardEventsToCalendar()
        loadCoreDataEvents(eventsFromCore: eventsFromCore)
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = isCalendarExpanded ? .month : .week
        calendar.firstWeekday = 2
    }
}

extension CalViewModel: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func determineEventsForShow(date: Date) {
        for event in eventsFromCore {
            if date == event.eventDateCore! {
                self.eventsForShow = [event]
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        dateSelected(date)
        determineEventsForShow(date: date)
        showDetailView = true
        selectedDate = date
        
    }
        
    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {
        numberOfEvent(for: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
           return .white
        }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        return .systemPink
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        var matchingEventName: String!
        //if date in eventList values, take last character of corresponding eventList key and make that the title for the date
        for event in eventsFromCore {
            print("&%")
            print(event)
            if date == event.eventDateCore! {
                matchingEventName = String(event.eventNameCore!.last!)
            }
        }
        return matchingEventName
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        var fillColor: UIColor!
        if date < Date() {
            fillColor = .darkGray
        }
        else {
            fillColor = .black
        }
        return fillColor
    }
}

private extension CalViewModel {

    func numberOfEvent(for date: Date) -> Int {
        /// some logic here
        var matchingCount = 0
        for event in eventsFromCore {
            if date == event.eventDateCore {
                matchingCount += 1
            }
        }
        return matchingCount
    }

    func dateSelected(_ date: Date) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.selectedDateOld = date.description
        }
    }
}

extension CalViewModel {
    func deleteAllForEntity() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CalendarDate")
   
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try CoreDataStack.shared.context.execute(batchDeleteRequest)
        }
        catch {
            print("error")
            }
    }
    
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
        deleteAllForEntity()
        let eventList3 = [String : Date]()
        let events = PreSetCalendarDates(eventList: eventList3)
        print(events)
        for (eventName, eventDate) in events.eventList {
            let event = CalendarDate(context: CoreDataStack.shared.context)
            event.eventNameCore = eventName
            event.eventDateCore = eventDate
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
    
    func loadCoreDataEvents(eventsFromCore: [CalendarDate]) {
        let request = CalendarDate.createFetchRequest()
        print(request)
        print("^^^^")
        let sort = NSSortDescriptor(key: "eventDateCore", ascending: false)
        request.sortDescriptors = [sort]
        do {
            self.eventsFromCore = try CoreDataStack.shared.context.fetch(request)
            print("Got \(eventsFromCore.count) Events")
            print(eventsFromCore)
        }
        catch {
            print("Fetch failed")
        }
    }
}
