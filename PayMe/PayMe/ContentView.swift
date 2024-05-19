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
        }
        .onAppear(perform: requestNotificationPermission)
        .onAppear(perform: startSendingNotifications)

    }

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

func startSendingNotifications() {
    scheduleNextNotification()
}

func scheduleNextNotification() {
    let randomTimeInteval = Double.random(in: 10...45)
    Timer.scheduledTimer(withTimeInterval: randomTimeInteval, repeats: false) { timer in
        sendRandomPaymentNotification()
        scheduleNextNotification()
    }
}

func sendRandomPaymentNotification() {
    // Zahlungsbenachrichtigung
    let content = UNMutableNotificationContent()

    //Wählen eine Liste von Zahlungsquellen
    let sources = ["AmaCorp.Shopify", "TarasCorp.Revo", "ShawgatCorp.Network", "BlueSky.SandComp"]
    let randomSources = sources.randomElement()!
    
    content.title = "Zahlung erhalten von \(randomSources)"
    
    let amount = String(format: "%.2f", Double.random(in: 25...5000))

    let currencies = ["$", "£", "€"]
    let randomCurrency = currencies.randomElement()!
    
    content.body = "Sie haben eine Zahlung erhalten in Höhe von \(amount)\(randomCurrency)"
    content.sound = UNNotificationSound.default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
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
