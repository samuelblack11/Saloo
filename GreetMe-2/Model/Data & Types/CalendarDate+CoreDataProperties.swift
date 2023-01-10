//
//  CalendarDate+CoreDataProperties.swift
//  
//
//  Created by Sam Black on 8/1/22.
//
//

import Foundation
import CoreData


extension CalendarDate {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<CalendarDate> {
        return NSFetchRequest<CalendarDate>(entityName: "CalendarDate")
    }

    @NSManaged public var eventDateCore: Date?
    @NSManaged public var eventNameCore: String?

}

extension CalendarDate : Identifiable {

}
