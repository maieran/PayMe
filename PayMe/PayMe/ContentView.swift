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
                
            Button(action: requestNotificationPermission) {
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
        .onAppear(perform: startSendingNotifications)
    }
}

var notificationTimer: Timer?
var sendNotifications = true // Kontrolliert die Benachrichtigungen

func startSendingNotifications() {
    scheduleNextNotification()
}

func scheduleNextNotification() {
    let randomTimeInterval = Double.random(in: 4...5)
    notificationTimer = Timer.scheduledTimer(withTimeInterval: randomTimeInterval, repeats: true) { timer in
        sendRandomPaymentNotification()
        scheduleNextNotification()
    }
}

func stopSendingNotifications() {
    notificationTimer?.invalidate()
    print("Notifications stopped")
}

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Permission granted!")
        } else {
            print("Permission denied")
        }
    }
}


func sendRandomPaymentNotification() {
    // Zahlungsbenachrichtigung
    let content = UNMutableNotificationContent()

    //Wählen eine Liste von Zahlungsquellen
    let sources = ["Shopify", "Revo", "Etsy", "Amazon", "BlueSky.SandComp"]
    let randomSources = sources.randomElement()!
    
    content.title = "Zahlung erhalten von \(randomSources)"
    
    let amount = String(format: "%.2f", Double.random(in: 1...20))

    let currencies = ["$", "£", "€"]
    let randomCurrency = currencies.randomElement()!
    
    content.body = "Sie haben eine Zahlung in Höhe von \(amount)\(randomCurrency) erhalten."
    
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "payment_success.m4a"))
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    
    UNUserNotificationCenter.current().add(request) {
        error in
        if let error = error {
            print("Fehlernotifikation: \(error.localizedDescription)")
        }
    }
}


struct ConntentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
