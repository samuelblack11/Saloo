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


extension View {
    func alertView() -> some View {
        self.modifier(GettingRecordAlert())
    }
}


struct GettingRecordAlert: ViewModifier {
    @ObservedObject var gettingRecord = GettingRecord.shared

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $gettingRecord.showLoadingRecordAlert) {
                Alert(
                    title: Text("We're Still Saving Your Card to the Cloud."),
                    message: Text("It'll be ready in just a minute."),
                    primaryButton: .default(Text("OK, I'll Wait"), action: {
                        gettingRecord.showLoadingRecordAlert = false
                        gettingRecord.isShowingActivityIndicator = true
                    }),
                    secondaryButton: .default(Text("I'll Try Again Later"), action: {
                        // Your action here...
                        gettingRecord.showLoadingRecordAlert = false
                        gettingRecord.willTryAgainLater = true
                    })
                )
            }
    }
}

struct LoadingOverlay: View {
    @ObservedObject var gettingRecord = GettingRecord.shared

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea() // This will make the semi-transparent view cover the entire screen

            ProgressView() // This is the built-in iOS activity indicator
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
        }
        .opacity(gettingRecord.isShowingActivityIndicator ? 1 : 0)
    }
}


