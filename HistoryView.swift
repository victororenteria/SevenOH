import SwiftUI
import SwiftData

/// Presents a list of all logged dose entries and allows deletion and CSV export.
struct HistoryView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \DoseEntry.date, order: .reverse) private var entries: [DoseEntry]
    @State private var showExport = false
    @State private var exportURL: URL?

    var body: some View {
        List {
            ForEach(entries) { e in
                VStack(alignment: .leading) {
                    Text(String(format: "%.0f mg • mood %d", e.mg, e.mood))
                        .font(.headline)
                    Text(e.date.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                    if let n = e.note, !n.isEmpty {
                        Text(n).foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { idx in
                idx.map { entries[$0] }.forEach(ctx.delete)
                try? ctx.save()
            }
        }
        .navigationTitle("History")
        .toolbar {
            Button {
                exportURL = CSVExporter.export(entries: entries)
                showExport = exportURL != nil
            } label: {
                Label("Export CSV", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $showExport) {
            if let url = exportURL {
                ShareLink(item: url)
            }
        }
    }
}

/// Exports an array of dose entries to a temporary CSV file and returns its URL.
struct CSVExporter {
    static func export(entries: [DoseEntry]) -> URL? {
        let header = "date,mg,mood,note\n"
        let lines = entries.sorted(by: { $0.date < $1.date }).map { e in
            let d = ISO8601DateFormatter().string(from: e.date)
            let n = (e.note ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            return "\(d),\(e.mg),\(e.mood),\"\(n)\""
        }
        let csv = header + lines.joined(separator: "\n")
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("SevenOH.csv")
            try csv.data(using: .utf8)?.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}