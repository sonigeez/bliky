//
//  ContentView.swift
//  bliky
//
//  Created by bharat on 29/11/24.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var timeRemaining = 20 * 60
    @State private var isActive = false
    @State private var timer: Timer?
    @State private var breakInterval = 20.0

    var body: some View {
        VStack(spacing: 20) {
            Text("Screen Break Reminder")
                .font(.title)
                .fontWeight(.bold)

            VStack {
                Text("Next break in:")
                    .font(.headline)
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(isActive ? .blue : .gray)
            }
            .padding()

            HStack {
                Text("Break interval:")
                Picker("Break interval", selection: $breakInterval) {
                    ForEach([5, 10, 15, 20, 25, 30, 45, 60], id: \.self) { minutes in
                        Text("\(minutes) min").tag(Double(minutes))
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding()

            Button(action: toggleTimer) {
                Text(isActive ? "Stop Timer" : "Start Timer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(isActive ? Color.red : Color.green)
                    .cornerRadius(10)
            }

            Text(
                "Remember the 20-20-20 rule:\nEvery 20 minutes, look at something\n20 feet away for 20 seconds"
            )
            .multilineTextAlignment(.center)
            .font(.caption)
            .foregroundColor(.gray)
            .padding()
        }
        .padding()
        .onAppear {
            requestNotificationPermission()
        }
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func toggleTimer() {
        if isActive {
            stopTimer()
        } else {
            startTimer()
        }
        isActive.toggle()
    }

    private func startTimer() {
        timeRemaining = Int(breakInterval * 60)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                sendNotification()
                timeRemaining = Int(breakInterval * 60)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = Int(breakInterval * 60)
    }

    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a Screen Break!"
        content.body = "Move your body and drink water"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
