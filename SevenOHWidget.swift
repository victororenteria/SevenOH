import WidgetKit
import SwiftUI
import SwiftData

/// A timeline provider that supplies today’s total consumption to the widget.
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, todayTotal: 40)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let total = await Self.fetchTodayTotal()
            completion(SimpleEntry(date: .now, todayTotal: total))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            let total = await Self.fetchTodayTotal()
            let entry = SimpleEntry(date: .now, todayTotal: total)
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    static func fetchTodayTotal() async -> Double {
        do {
            let container = Persistence.sharedModelContainer
            let context = ModelContext(container)
            let fetch = FetchDescriptor<DoseEntry>()
            let all = try context.fetch(fetch)
            let cal = Calendar.current
            return all.filter { cal.isDateInToday($0.date) }.reduce(0) { $0 + $1.mg }
        } catch {
            return 0
        }
    }
}

/// A simple timeline entry carrying today’s total milligrams.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let todayTotal: Double
}

/// The widget view showing today’s total and quick logging actions.
struct SevenOHWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Seven OH")
                .font(.headline)
            Text("Today \(Int(entry.todayTotal)) mg")
                .font(.title3.bold())

            Spacer()

            // Primary action opens the log sheet in the app
            Link(destination: URL(string: "sevenoh://log")!) {
                Label("Log dose", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)

            // Optional quick buttons
            HStack {
                ForEach([5, 10, 15], id: \.self) { v in
                    Link("\(v)", destination: URL(string: "sevenoh://log?preset=\(v)")!)
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}

@main
struct SevenOHWidget: Widget {
    let kind: String = "SevenOHWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SevenOHWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Seven OH")
        .description("Log and view today’s total.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    SevenOHWidget()
} timeline: {
    SimpleEntry(date: .now, todayTotal: 42)
}