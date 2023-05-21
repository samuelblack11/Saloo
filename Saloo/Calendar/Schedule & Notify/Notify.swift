//
//  Notify.swift
//  GreetMe-2
//
//  Created by Sam Black on 8/23/22.
//
import SwiftUI
import UserNotifications

struct Notify: View {
    
    var body: some View {
        VStack {
            Button("Request Permission") {
                // first
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

            Button("Schedule Notification") {
                // second
                let content = UNMutableNotificationContent()
                content.title = "Make a Card For {Event}"
                content.subtitle = "It looks hungry"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    
}

// 3 Components to Notification
// Content: to be show: title, subtitle, sound image, etc
// Trigger: When should notification be shown?
// Request: Content + Trigger + Unique Identifier (allows us to edit alert or remove it later)
