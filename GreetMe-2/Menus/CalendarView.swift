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
    @Binding var showDetailView: ShowDetailView
    
    func makeUIView(context: Context) -> some UIView {
        calendar
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

extension CalendarView {
    
}

class CalViewModel: NSObject, ObservableObject {
    
    @Published var calendar = FSCalendar()
    @Published var isCalendarExpanded: Bool = true
    @Published var showDetailView = ShowDetailView()
    @Published var selectedDateOld: String = ""
    @Published var eventsFromCore = [CalendarDate]()
    @Published var selectedDate: Date!
    //@Published var eventsForShow: [String] = []
    @Published var eventsForShow: [CalendarDate] = []

    
    override init() {
        super.init()
        addStandardEventsToCalendar()
        eventsFromCore = loadCoreDataEvents()
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = isCalendarExpanded ? .month : .week
        calendar.firstWeekday = 2
    }
}

extension CalViewModel: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
    }
    
    func determineEventsForShow(date: Date, eventsFromCoreFunc: [CalendarDate]) -> [CalendarDate] {
        var events: [CalendarDate] = []
        for event in eventsFromCoreFunc {
            if date == event.eventDateCore! {
                print("-----")
                events.append(event)
            }
        }
        return events
    }
    
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        dateSelected(date)
        selectedDate = date
        eventsForShow = determineEventsForShow(date: date, eventsFromCoreFunc: eventsFromCore)
        showDetailView.showDetailView = true
        print("didSelect Worked!")
        print(eventsForShow)
    }
        
    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {
        numberOfEvent(for: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        var textColor: UIColor!
        
        if date < Date().startOfMonth() {
            textColor = .lightGray
        }
        
        else if date - 1 < Date() {
            textColor = .lightGray
        }
        else if date > Date()  && date < Date().endOfMonth() {
            textColor = .white
        }
        
        else {
            textColor = .lightGray
        }
        return textColor
        
        }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        return .systemPink
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        var matchingEventName: String!
        //if date in eventList values, take last character of corresponding eventList key and make that the title for the date
        eventsFromCore = loadCoreDataEvents()
        for event in eventsFromCore {
            print("&%")
            print(event.eventNameCore!)
            if date == event.eventDateCore! {
                matchingEventName = String(event.eventNameCore!.last!)
            }
        }
        return matchingEventName
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        var fillColor: UIColor!
        
        if date < Date().startOfMonth() {
            fillColor = .lightGray
        }
        
        else if date < Date() + 1 {
            fillColor = .darkGray
        }
        else if date > Date()  && date < Date().endOfMonth() {
            fillColor = .black
        }
        
        else {
            fillColor = .lightGray
        }
        
        fillColor = .black
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
            self.selectedDate = date
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
        let defaults = UserDefaults.standard
         //if first logon
        if defaults.bool(forKey: "First Launch") == true {
            print("Not First Launch")
            }
        else {
            print("First Launch")
            let eventList3 = [String : Date]()
            let events = PreSetCalendarDates(eventList: eventList3)
            for (eventName, eventDate) in events.eventList {
                let event = CalendarDate(context: CoreDataStack.shared.context)
                event.eventNameCore = eventName
                event.eventDateCore = eventDate
                self.saveContext()
            }
        }
        defaults.set(true, forKey: "First Launch")
        //deleteAllForEntity()
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
    
    func loadCoreDataEvents() -> [CalendarDate] {
        let request = CalendarDate.createFetchRequest()
        let sort = NSSortDescriptor(key: "eventDateCore", ascending: false)
        request.sortDescriptors = [sort]
        var events: [CalendarDate] = []
        do {
            events = try CoreDataStack.shared.context.fetch(request)
        }
        catch {
            print("Fetch failed")
        }
        return events
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
