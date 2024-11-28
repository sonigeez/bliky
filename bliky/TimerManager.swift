import SwiftUI
import UserNotifications

class TimerManager: ObservableObject {
    @Published private(set) var timeRemaining: Int
    @Published var isActive = false
    @Published var breakInterval: Double {
        didSet {
            updateTimeRemaining()
        }
    }
    
    private var timer: Timer?
    
    init() {
        let defaultBreakInterval = 20.0
        self.breakInterval = defaultBreakInterval
        self.timeRemaining = Int(defaultBreakInterval * 60)
        requestNotificationPermission()
    }

    
    func updateTimeRemaining() {
        timeRemaining = Int(breakInterval * 60)
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func toggleTimer() {
        if isActive {
            stopTimer()
        } else {
            startTimer()
        }
        isActive.toggle()
    }
    
    private func startTimer() {
        timeRemaining = Int(breakInterval * 60)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.sendNotification()
                self.timeRemaining = Int(self.breakInterval * 60)
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
                if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for a Screen Break!"
        content.body = "Look at something 20 feet away for 20 seconds"
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
