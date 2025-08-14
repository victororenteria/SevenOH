import SwiftUI
import SwiftData

/// A card that displays taper progress and forecasts days remaining until zero based on settings.
struct TaperCard: View {
    @Query(sort: \DoseEntry.date, order: .reverse) private var entries: [DoseEntry]
    let settings: Settings

    private var today: Date { Calendar.current.startOfDay(for: Date()) }

    /// Total milligrams consumed today.
    private var todayTotal: Double {
        let cal = Calendar.current
        return entries.filter { cal.isDateInToday($0.date) }.reduce(0) { $0 + $1.mg }
    }

    /// Forecast of days remaining until zero if following the configured weekly step down.
    private var forecastDaysToZero: Int? {
        guard settings.startBaselineMg > 0 else { return nil }
        let weeklyDrop: Double = settings.taperMode == .mg
            ? settings.weeklyStepDownMg
            : settings.startBaselineMg * (settings.weeklyStepDownPercent / 100.0)
        guard weeklyDrop > 0 else { return nil }
        let weeks = settings.startBaselineMg / weeklyDrop
        return Int(ceil(weeks * 7))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Taper helper")
                .font(.title2.bold())

            HStack {
                VStack(alignment: .leading) {
                    Text("Target today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(settings.dailyTargetMg)) mg")
                        .font(.title3.bold())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("So far today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(todayTotal)) mg")
                        .font(.title3.bold())
                        .foregroundStyle(todayTotal > settings.dailyTargetMg ? .red : .primary)
                }
            }

            if let days = forecastDaysToZero {
                Text("If you keep stepping down weekly, you could reach zero in about \(days) days.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}