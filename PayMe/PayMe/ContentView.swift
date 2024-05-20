//
//  ContentView.swift
//  PayMe
//
//  Created by AMACOP on 20.05.24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var totalIncome: Double = 0.0
    @State private var transactions: [String] = []
    @State private var notificationTimer: Timer?

    var body: some View {
        VStack {
            Text("PayMe App")
                .font(.largeTitle)
                .padding()
            
            Text("Gesamteinkünfte: \(String(format: "%.2f", totalIncome))")
                .padding(.top)
            
            Text("Fünf letzte Transaktionen")
                .font(.headline)
                .padding(.top)
            
            List(transactions.prefix(5), id: \.self) { transaction in
                Text(transaction)
            }
            .frame(height: 200)
                
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
        
        // Trigger nach 10 Sekunden
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Fehlernotifikation: \(error.localizedDescription)")
            }
        }
        
        if let amountDouble = Double(amount) {
            DispatchQueue.main.async {
                updateIncomeAndTransactions(amount: amountDouble, currency: randomCurrency)
            }
        } else {
            print("Failed to convert amount to Double")
        }
    }

    func updateIncomeAndTransactions(amount: Double, currency: String) {
        totalIncome += amount
        let transaction = "\(String(format: "%.2f", amount))\(currency)"
        transactions.insert(transaction, at: 0)
        
        if transactions.count > 5 {
            transactions.removeLast()
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
