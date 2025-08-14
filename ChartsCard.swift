import SwiftUI
import SwiftData
import Charts

/// A card containing bar and line charts of the last N days of dose totals and average mood.
struct ChartsCard: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \DoseEntry.date, order: .forward) private var entries: [DoseEntry]
    @Binding var rangeDays: Int

    /// Groups entries by day and aggregates total milligrams and average mood.
    var dataByDay: [(day: Date, total: Double, avgMood: Double?)] {
        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -rangeDays + 1, to: Date())!
        let filtered = entries.filter { $0.date >= start }
        let groups = Dictionary(grouping: filtered) { entry in
            cal.startOfDay(for: entry.date)
        }
        return groups.keys.sorted().map { day in
            let items = groups[day]!
            let total = items.reduce(0) { $0 + $1.mg }
            let avgMood = items.isEmpty ? nil : Double(items.map { $0.mood }.reduce(0, +)) / Double(items.count)
            return (day, total, avgMood)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trends")
                    .font(.title2.bold())
                Spacer()
                Picker("", selection: $rangeDays) {
                    Text("7d").tag(7)
                    Text("30d").tag(30)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
            }

            Chart {
                ForEach(dataByDay, id: \.day) { point in
                    BarMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("Total mg", point.total)
                    )
                }
            }
            .frame(height: 160)

            Chart {
                ForEach(dataByDay, id: \.day) { point in
                    if let mood = point.avgMood {
                        LineMark(
                            x: .value("Day", point.day, unit: .day),
                            y: .value("Mood", mood)
                        )
                        .interpolationMethod(.monotone)
                    }
                }
            }
            .frame(height: 140)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}