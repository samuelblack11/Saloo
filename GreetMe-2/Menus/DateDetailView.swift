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
                VStack(spacing: 15) {
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
                    }
            }
        }
    }
    
    extension DateDetailView {
        func deleteCoreData(event: CalendarDate) {
            do {
                print("Attempting Delete")
                CoreDataStack.shared.context.delete(event)
                try CoreDataStack.shared.context.save()
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
                eventsForShow = try CoreDataStack.shared.persistentContainer.viewContext.fetch(request)
                print("Got \(eventsForShow.count) Events")
                //collectionView.reloadData()
            }
            catch {
                print("Fetch failed")
            }
        }
        
    }
