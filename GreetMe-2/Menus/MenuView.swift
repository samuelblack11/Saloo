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
    @State private var showPrior = false
    @State var searchObject: SearchParameter!
    @State var searchType: String!
    @State var noneSearch: String!
    @ObservedObject var calViewModel: CalViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    CalendarView(calendar: calViewModel.calendar, isCalendarExpanded: $calViewModel.isCalendarExpanded)
                    }
                .frame(width: (UIScreen.screenWidth/1.1), height: (UIScreen.screenHeight/1.3))
                HStack {
                    Button{} label: {
                        Image(systemName: "tray.and.arrow.up.fill").foregroundColor(.blue)
                        }
                    Spacer()
                    Button{} label: {
                        Image(systemName: "plus").foregroundColor(.blue)
                        }
                    Spacer()
                    Button{} label: {
                        Image(systemName: "tray.and.arrow.down.fill").foregroundColor(.blue)
                        }
                    }
                    .frame(width: (UIScreen.screenWidth/1), height: (UIScreen.screenHeight/20))
            }
        }
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

extension CalViewModel: FSCalendarDelegate {

    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        dateSelected(date)
    }

    func calendar(_ calendar: FSCalendar,
                  boundingRectWillChange bounds: CGRect,
                  animated: Bool) {
        //calendarHeight = bounds.height
    }
}

extension CalViewModel: FSCalendarDataSource {

    func calendar(_ calendar: FSCalendar,
                  numberOfEventsFor date: Date) -> Int {
        numberOfEvent(for: date)
    }
}

private extension CalViewModel {

    func numberOfEvent(for date: Date) -> Int {
        /// some logic here
        return 0
    }

    func dateSelected(_ date: Date) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.selectedDate = date.description
        }
    }
}
