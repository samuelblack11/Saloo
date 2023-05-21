//
//  GreetMe_2App.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.

import SwiftUI
import CloudKit

@main
struct Saloo_App: App {
    @StateObject var musicSub = MusicSubscription()
    @StateObject var calViewModel = CalViewModel()
    @StateObject var showDetailView = ShowDetailView()
    let persistenceController = PersistenceController.shared
    @StateObject var appDelegate = AppDelegate()
    @StateObject var sceneDelegate = SceneDelegate()
    @StateObject var networkMonitor = NetworkMonitor()
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State private var isCountdownShown: Bool = false

    //@UIApplicationDelegateAdaptor var appDelegate2: AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate3

    var body: some Scene {
        WindowGroup {
            ZStack {
                StartMenu()
                //.background(appDelegate.appColor)
                    .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
                    .environmentObject(networkMonitor)
                    .environmentObject(sceneDelegate)
                    .environmentObject(appDelegate)
                    .environmentObject(musicSub)
                    .environmentObject(calViewModel)
                    .environmentObject(showDetailView)
                    .environmentObject(GettingRecord.shared)
                    .onReceive(gettingRecord.$hideProgViewOnAcceptShare) { newValue in
                        self.isCountdownShown = !newValue
                    }
                
                if isCountdownShown {
                    CountdownView(startTime: 60)
                        .border(.gray)
                        .padding()
                        .background(Color.black.opacity(1.0))
                        .cornerRadius(15)
                }
            }
        }
    }
}

struct CountdownView: View {
    @State private var remainingTime: Int
    init(startTime: Int) { _remainingTime = State(initialValue: startTime)}
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var backgroundTime = Date()

    var body: some View {
        VStack {
            Text("We're Still Saving Your Card to the Cloud. It'll be ready in just a minute 😊")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("Time Remaining: \(remainingTime)")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            ProgressView()
                .tint(.black)
                .scaleEffect(2)
                .progressViewStyle(CircularProgressViewStyle())
        }
            .onReceive(timer) { _ in if remainingTime > 0 {remainingTime -= 1}}
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                backgroundTime = Date()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                let elapsedSeconds = Int(Date().timeIntervalSince(backgroundTime))
                remainingTime = max(remainingTime - elapsedSeconds, 0)
            }
    }
}
