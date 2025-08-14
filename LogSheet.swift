import SwiftUI
import SwiftData

/// A sheet that prompts the user to log a dose in milligrams and rate their mood.
struct LogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx

    @State private var mgString: String = ""
    @State private var mood: Int = 5
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Dose") {
                    TextField("Milligrams", text: $mgString)
                        .keyboardType(.decimalPad)
                    HStack(spacing: 8) {
                        ForEach([5, 10, 15, 20, 25, 30], id: \.self) { v in
                            Button("\(v)") { mgString = "\(v)" }
                                .buttonStyle(.bordered)
                        }
                    }
                }
                Section("Mood 1 to 10") {
                    Stepper(value: $mood, in: 1...10) {
                        Text("\(mood)")
                    }
                    Slider(value: Binding(
                        get: { Double(mood) },
                        set: { mood = Int($0.rounded()) }
                    ), in: 1...10, step: 1)
                }
                Section("Optional note") {
                    TextField("Note", text: $note)
                }
            }
            .navigationTitle("Log dose")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(Double(mgString) == nil)
                }
            }
        }
    }

    private func save() {
        guard let mg = Double(mgString), mg > 0 else { return }
        let entry = DoseEntry(mg: mg, mood: mood, note: note.isEmpty ? nil : note)
        ctx.insert(entry)
        try? ctx.save()
        dismiss()
    }
}