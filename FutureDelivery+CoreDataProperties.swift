//
//  FutureDelivery+CoreDataProperties.swift
//  
//
//  Created by Sam Black on 9/1/22.
//
//

import Foundation
import CoreData


extension FutureDelivery {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FutureDelivery> {
        return NSFetchRequest<FutureDelivery>(entityName: "FutureDelivery")
    }

    @NSManaged public var card: Data?
    @NSManaged public var deliveryDate: Date?
    @NSManaged public var recipientList: NSObject?

}

extension FutureDelivery : Identifiable {

}
