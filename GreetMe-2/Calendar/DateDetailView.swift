//
//  DateDetailView.swift
//  GreetMe-2
//
//  Created by Sam Black on 8/1/22.
//

import Foundation
import SwiftUI
import FSCalendar
import CoreData
import UserNotifications


struct DateDetailView: View {
    @State var eventsForShow: [CalendarDate]
    @State var chosenDate: Date!
    
    //init(_ eventsForShow: [CalendarDate] ) {
    //    print("initializing dateDetailView")
   //     self.eventsForShow = eventsForShow
   //     print(eventsForShow)
   // }
    
    
    var body: some View {
            ForEach(eventsForShow, id: \.self) {event in
                HStack(spacing: 15) {
                    Text(event.eventNameCore!)
                        .contextMenu {
                            Button {
                                chosenDate = event.eventDateCore!
                                deleteCoreData(event: event)
                                loadCoreData(date: chosenDate)
                            } label: {
                                Text("Delete Event")
                                Image(systemName: "trash")
                                .foregroundColor(.red)
                            }
                        }
                    Button("Notify Me") {
                        // second
                        let content = UNMutableNotificationContent()
                        content.title = "Make a Card For \(event.eventNameCore!)"
                        content.subtitle = "Don't Forget 😁"
                        content.sound = UNNotificationSound.default
                        //https://stackoverflow.com/questions/42042215/convert-date-to-datecomponents-in-function-to-schedule-local-notification-in-swi
                        let n = -7
                        let nextTriggerDate = Calendar.current.date(byAdding: .day, value: n, to: event.eventDateCore!)!
                        let comps = Calendar.current.dateComponents([.year, .month, .day], from: nextTriggerDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                        print("Trigger = \(trigger)")
                        // choose a random identifier
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                        // add our notification request
                        UNUserNotificationCenter.current().add(request)
                    }
                }
            }
        }
    }
    
    extension DateDetailView {
        
        
        func deleteCoreData(event: CalendarDate) {
            do {
                print("Attempting Delete")
                PersistenceController.shared.persistentContainer.viewContext.delete(event)
                try PersistenceController.shared.persistentContainer.viewContext.save()
                }
                // Save Changes
             catch {
                // Error Handling
                // ...
                 print("Couldn't Delete")
             }
        }
        
        func loadCoreData(date: Date) {
            print("#$#$")
            print(date)
            let request = CalendarDate.createFetchRequest()
            let sort = NSSortDescriptor(key: "eventDateCore", ascending: false)
            request.sortDescriptors = [sort]
            let filter = date
            let predicate = NSPredicate(format: "eventDateCore = %@", filter as CVarArg)
            request.predicate = predicate
            do {
                eventsForShow = try PersistenceController.shared.persistentContainer.viewContext.fetch(request)
                print("Got \(eventsForShow.count) Events")
                //collectionView.reloadData()
            }
            catch {
                print("Fetch failed")
            }
        }
        
    }
