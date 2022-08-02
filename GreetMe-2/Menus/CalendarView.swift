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



struct CalendarView: UIViewRepresentable {
    var calendar: FSCalendar
    @Binding var isCalendarExpanded: Bool
    
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
    //@Published var calendarHeight: CGFloat = 300.0
    @Published var selectedDate: String = ""
    var eventsFromCore = [CalendarDate]()

    
    override init() {
        super.init()
        deleteAllForEntity()
        loadCoreDataEvents()
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = isCalendarExpanded ? .month : .week
        calendar.firstWeekday = 2
    }
}

extension CalViewModel: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        dateSelected(date)
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
    
    func loadCoreDataEvents() {
        let request = CalendarDate.createFetchRequest()
        let sort = NSSortDescriptor(key: "eventDateCore", ascending: false)
        request.sortDescriptors = [sort]
        do {
            eventsFromCore = try CoreDataStack.shared.persistentContainer.viewContext.fetch(request)
            print("Got \(eventsFromCore.count) Events")
            //collectionView.reloadData()
        }
        catch {
            print("Fetch failed")
        }
    }
    
    func deleteAllForEntity() {
        let context = CoreDataStack.shared.context
        for object in eventsFromCore {
            context.delete(object)
        }
        do {
            try context.save()
        }
        catch {
            print("Couldn't save after delete")
        }
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        var matchingEventName: String!
        //if date in eventList values, take last character of corresponding eventList key and make that the title for the date
        //for (eventName, eventDate) in events.eventList {
        for event in eventsFromCore {
            if date == event.eventDateCore! {
                matchingEventName = String(event.eventNameCore!.last!)
            }
            //else if date != eventDate {
            //    matchingEventName = dateFormatter.string(from: date)
            //  }
        }
        return matchingEventName
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        var fillColor: UIColor!
        let dateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
        let startOfMonth = Calendar.current.date(from: dateComponents)!
        
        //if date < startOfMonth {
        //    fillColor = .lightGray
        //}
        //else
        if date < Date() {
            fillColor = .darkGray
        }
        else {
            fillColor = .black
        }
        return fillColor
    }
    
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //let item = DateDetailView(selectedDate: date, eventsFromCore: eventsFromCore)
        NavigationLink(destination: DateDetailView(selectedDate: date, eventsFromCore: eventsFromCore)){}
                       

    }
    
    
    
    
}

private extension CalViewModel {

    func numberOfEvent(for date: Date) -> Int {
        /// some logic here
        var matchingCount = 0
        //if date in eventList values, take last character of corresponding eventList key and make that the title for the date
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
            self.selectedDate = date.description
        }
    }
}
