import SwiftUI

struct MenuBarView: View {
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        VStack(spacing: 12) {
            Text(timerManager.timeString)
                .font(.system(.title2, design: .rounded))
                .foregroundColor(timerManager.isActive ? .blue : .gray)
            
            Divider()
            
            Menu("Break Interval: \(Int(timerManager.breakInterval))min") {
                ForEach([0.3, 5, 10, 15, 20, 25, 30, 45, 60], id: \.self) { minutes in
                    Button("\(Int(minutes)) minutes") {
                        if !timerManager.isActive {
                            timerManager.breakInterval = minutes
                            timerManager.updateTimeRemaining()
                        }
                    }
                }
            }
            .disabled(timerManager.isActive)
            
            Button(timerManager.isActive ? "Stop Timer" : "Start Timer") {
                timerManager.toggleTimer()
            }
            .keyboardShortcut("t")
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 200)
    }
}
