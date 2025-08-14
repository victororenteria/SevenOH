import SwiftUI
import SwiftData
import UserNotifications

/// A form for configuring targets, tapering settings and reminder notifications.
struct SettingsView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var settingsList: [Settings]
    @State private var showAlert = false
    @State private var alertMsg = ""

    /// Returns the singleton Settings object, creating it if necessary.
    var settings: Settings {
        if let s = settingsList.first { return s }
        let s = Settings()
        ctx.insert(s)
        return s
    }

    var body: some View {
        Form {
            Section("Targets and taper") {
                Stepper("Daily target \(Int(settings.dailyTargetMg)) mg", value: binding(\.dailyTargetMg), in: 0...200, step: 5)
                Picker("Taper mode", selection: binding(\.taperMode)) {
                    ForEach(TaperMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                if settings.taperMode == .mg {
                    Stepper("Weekly step down \(Int(settings.weeklyStepDownMg)) mg", value: binding(\.weeklyStepDownMg), in: 0...100, step: 1)
                } else {
                    Stepper("Weekly step down \(Int(settings.weeklyStepDownPercent)) percent", value: binding(\.weeklyStepDownPercent), in: 0...50, step: 1)
                }
                Stepper("Start baseline \(Int(settings.startBaselineMg)) mg", value: binding(\.startBaselineMg), in: 0...300, step: 5)
                DatePicker("Target quit date", selection: Binding($settingsList.first!.targetDate, replacingNilWith: Date()), displayedComponents: .date)
            }

            Section("Reminders") {
                Toggle("Enable reminders", isOn: binding(\.reminderEnabled))
                    .onChange(of: settings.reminderEnabled) { _, on in
                        if on { requestNotifications() }
                    }
                if settings.reminderEnabled {
                    HoursPicker(hours: binding(\.reminderHours))
                }
            }

            Section("About") {
                Text("Seven OH helps you log usage and taper with targets and trends. Export your data anytime.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .onDisappear { try? ctx.save() }
    }

    private func binding<T>(_ keyPath: WritableKeyPath<Settings, T>) -> Binding<T> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { settings[keyPath: keyPath] = $0 }
        )
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ok, _ in
            if !ok {
                alertMsg = "Notifications not allowed. Enable in Settings."
                showAlert = true
            }
        }
    }
}

/// A horizontal picker for selecting reminder hours.
struct HoursPicker: View {
    @Binding var hours: [Int]
    let all = Array(6...22)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(all, id: \.self) { h in
                    let selected = hours.contains(h)
                    Button(String(format: "%02d:00", h)) {
                        if selected {
                            hours.removeAll { $0 == h }
                        } else {
                            hours.append(h)
                            hours.sort()
                        }
                        schedule(h)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selected ? .accentColor : .gray.opacity(0.3))
                }
            }
        }
    }

    private func schedule(_ hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Gentle check in"
        content.body = "How are you feeling? Log if you need to."
        var date = DateComponents()
        date.hour = hour
        let trig = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let req = UNNotificationRequest(identifier: "sevenoh.\(hour)", content: content, trigger: trig)
        UNUserNotificationCenter.current().add(req)
    }
}

extension Binding where Value == Date? {
    init(_ source: Binding<Date?>, replacingNilWith defaultDate: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultDate },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}