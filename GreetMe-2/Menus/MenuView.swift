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

struct MenuView: View {
    
    @State private var createNew = false
    @State private var showSent = false
    @State private var showReceived = false

    @State var searchObject: SearchParameter!
    @State var searchType: String!
    @State var noneSearch: String!
    @ObservedObject var calViewModel: CalViewModel
    
    
    var body: some View {
        //NavigationView {
            VStack {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 36))
                    .padding(.top, 30)
                Spacer()
                CalendarView(calendar: calViewModel.calendar, isCalendarExpanded: $calViewModel.isCalendarExpanded)
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
            }
        //}
        
    }
}

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

    
    override init() {
        super.init()
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
    
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let eventList2 = [String : Date]()
        let events = PreSetCalendarDates(eventList: eventList2)
        var matchingEventName: String!
        //if date in eventList values, take last character of corresponding eventList key and make that the title for the date
        for (eventName, eventDate) in events.eventList {
            if date == eventDate {
                print(String(eventName.last!))
                print(date)
                matchingEventName = String(eventName.last!)
                //matchingEventName = "H"
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
        
        if date < startOfMonth {
            fillColor = .lightGray
        }
        else if date < Date() {
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
        let eventList2 = [String : Date]()
        let events = PreSetCalendarDates(eventList: eventList2)
        var matchingCount = 0
        //if date in eventList values, take last character of corresponding eventList key and make that the title for the date
        for (_, eventDate) in events.eventList {
            if date == eventDate {
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
