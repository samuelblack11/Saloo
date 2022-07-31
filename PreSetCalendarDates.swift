//
//  PreSetCalendarDates.swift
//  GreetMe-2
//
//  Created by Sam Black on 7/31/22.
//

import Foundation


struct PreSetCalendarDates {
    var eventList: [String: Date]

    func createDate(eventDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyy"
        return formatter.date(from: eventDate)!
    }
    
    
    init(eventList: [String: Date]) {
        self.eventList = eventList
        self.eventList["New Year's Day"] = createDate(eventDate: "01/01/2023")
        self.eventList["New Year's Day"] = createDate(eventDate: "01/17/2022")
        self.eventList["Chinese New Year 🧧"] = createDate(eventDate: "02/01/2022")
        self.eventList["Groundhog's Day 🦫"] = createDate(eventDate: "02/02/2022")
        self.eventList["Super Bowl Sunday 🏈"] = createDate(eventDate: "02/13/2022")
        self.eventList["Valentine's Day ❤️"] = createDate(eventDate: "02/14/2022")
        self.eventList["President's Day"] = createDate(eventDate: "02/21/2022")
        self.eventList["Mari Gras (Fat Tuesday) 🎉"] = createDate(eventDate: "03/01/2022")
        self.eventList["Ash Wednesday"] = createDate(eventDate: "03/02/2022")
        self.eventList["Purim ✡️"] = createDate(eventDate: "03/17/2022")
        self.eventList["St. Patrick's Day 🍀"] = createDate(eventDate: "03/17/2022")
        self.eventList["April Fool's Day"] = createDate(eventDate: "04/01/2022")
        self.eventList["Ramadan ☪️"] = createDate(eventDate: "04/02/2022")
        self.eventList["Palm Sunday 🌴"] = createDate(eventDate: "04/10/2022")
        self.eventList["Good Friday"] = createDate(eventDate: "04/15/2022")
        self.eventList["Passover ✡️"] = createDate(eventDate: "04/15/2022")
        self.eventList["Easter Sunday 🐇"] = createDate(eventDate: "04/17/2022")
        self.eventList["Eid al-Fitr"] = createDate(eventDate: "04/21/2022")
        self.eventList["Earth Day 🌎"] = createDate(eventDate: "04/22/2022")
        self.eventList["Star Wars Day 🚀"] = createDate(eventDate: "05/04/2022")
        self.eventList["Cinco De Mayo"] = createDate(eventDate: "05/05/2022")
        self.eventList["Kentucky Derby 🐎"] = createDate(eventDate: "05/07/2022")
        self.eventList["Mother's Day 🌸"] = createDate(eventDate: "05/08/2022")
        self.eventList["Memorial Day 🎗"] = createDate(eventDate: "05/30/2022")
        self.eventList["Father's Day"] = createDate(eventDate: "06/19/2022")
        self.eventList["Juneteenth ✊🏾"] = createDate(eventDate: "06/19/202")
        self.eventList["4th of July 🇺🇸"] = createDate(eventDate: "07/04/2022")
        self.eventList["Labor Day"] = createDate(eventDate: "09/05/2022")
        self.eventList["9/11 Remembrance 🇺🇸"] = createDate(eventDate: "09/21/2022")
        self.eventList["Rosh Hashanah ✡️"] = createDate(eventDate: "09/25/2022")
        self.eventList["Yom Kippur ✡️"] = createDate(eventDate: "10/04/2022")
        self.eventList["Indigenous People Day"] = createDate(eventDate: "10/10/2022")
        self.eventList["Halloween 🎃"] = createDate(eventDate: "10/31/2022")
        self.eventList["Election Day 🇺🇸"] = createDate(eventDate: "11/08/2022")
        self.eventList["Veteran's Day 🇺🇸"] = createDate(eventDate: "11/11/2022")
        self.eventList["Thanksgiving 🦃"] = createDate(eventDate: "11/24/2022")
        self.eventList["Black Friday 🛍"] = createDate(eventDate: "11/25/2022")
        self.eventList["Cyber Monday 💻"] = createDate(eventDate: "11/28/2022")
        self.eventList["Hanukkah 🕎"] = createDate(eventDate: "12/18/2022")
        self.eventList["Christmas 🎄"] = createDate(eventDate: "12/25/2022")
        self.eventList["Kwanzaa ✊🏾"] = createDate(eventDate: "12/26/2022")
        self.eventList["New Year's Eve 🎆"] = createDate(eventDate: "12/31/2022")
    }
    
    
    
    
}
