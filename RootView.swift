import SwiftUI
import SwiftData

/// The main root view of the SevenOH app.  Displays today's total, charts, taper helper and buttons to log and view history.
struct RootView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \DoseEntry.date, order: .reverse) private var entries: [DoseEntry]
    @Query private var settingsList: [Settings]
    @Binding var route: AppRoute

    @State private var showLogSheet = false
    @State private var rangeDays: Int = 7

    /// Returns the singleton Settings object, creating it if necessary.
    var settings: Settings {
        if let s = settingsList.first { return s }
        let s = Settings()
        ctx.insert(s)
        return s
    }

    /// Calculates the total milligrams consumed today.
    var todayTotal: Double {
        let cal = Calendar.current
        return entries
            .filter { cal.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.mg }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TodayCard(todayTotal: todayTotal, target: settings.dailyTargetMg)

                    ChartsCard(rangeDays: $rangeDays)

                    TaperCard(settings: settings)

                    HStack {
                        Button {
                            showLogSheet = true
                        } label: {
                            Label("Log dose", systemImage: "plus.circle.fill")
                                .font(.title3.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)

                        NavigationLink {
                            HistoryView()
                        } label: {
                            Label("History", systemImage: "clock.arrow.circlepath")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Seven OH")
            .toolbar {
                NavigationLink {
                    SettingsView()
                } label: { Image(systemName: "gearshape") }
            }
            .sheet(isPresented: $showLogSheet) {
                LogSheet()
            }
            .onChange(of: route) { _, newValue in
                if newValue == .presentLog {
                    showLogSheet = true
                    route = .none
                }
            }
        }
    }
}

/// A card view showing today's total consumption and a progress ring against the daily target.
struct TodayCard: View {
    let todayTotal: Double
    let target: Double
    var progress: Double { min(todayTotal / max(target, 1), 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.title2.bold())
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: "%.0f mg", todayTotal))
                        .font(.largeTitle.weight(.bold))
                    Text("Daily target \(Int(target)) mg")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ProgressView(value: progress)
                    .progressViewStyle(.circular)
                    .frame(width: 44, height: 44)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}