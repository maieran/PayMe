//
//  ContentView.swift
//  PayMe
//
//  Created by AMACOP on 19.05.24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        VStack {
            Text("PayMe App")
                .font(.largeTitle)
                .padding()
                
            Button(action: enableNotifications) {
                Text("Enable Notifications")
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: stopSendingNotifications) {
                Text("Stop Notifications")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear(perform: requestNotificationPermission)
    }
}

var notificationTimer: Timer?

func enableNotifications() {
    startSendingNotifications()
}

func startSendingNotifications() {
    scheduleNextNotification()
}

func scheduleNextNotification() {
    let timeInterval: TimeInterval = 5
    notificationTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
        sendRandomPaymentNotification()
    }
}

func stopSendingNotifications() {
    notificationTimer?.invalidate()
    notificationTimer = nil
    print("Notifications stopped")
}

func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Permission granted!")
            center.delegate = NotificationDelegate.shared
        } else {
            print("Permission denied")
        }
    }
}

func sendRandomPaymentNotification() {
    let content = UNMutableNotificationContent()

    let sources = ["Shopify", "Revo", "Etsy", "Amazon", "BlueSky.SandComp"]
    let randomSource = sources.randomElement()!
    
    content.title = "Zahlung erhalten von \(randomSource)"
    
    let amount = String(format: "%.2f", Double.random(in: 1...20))
    let currencies = ["$", "£", "€"]
    let randomCurrency = currencies.randomElement()!
    
    content.body = "Sie haben eine Zahlung in Höhe von \(amount)\(randomCurrency) erhalten."
    
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "payment_success.m4a"))
    
    // trigger nac 10 Sekunden
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Fehlernotifikation: \(error.localizedDescription)")
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
