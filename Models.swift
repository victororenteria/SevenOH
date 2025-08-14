import Foundation
import SwiftData

@Model
final class DoseEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var mg: Double
    var mood: Int
    var note: String?

    init(id: UUID = UUID(), date: Date = .now, mg: Double, mood: Int, note: String? = nil) {
        self.id = id
        self.date = date
        self.mg = mg
        self.mood = mood
        self.note = note
    }
}

@Model
final class Settings {
    var dailyTargetMg: Double
    var taperMode: TaperMode
    var weeklyStepDownMg: Double
    var weeklyStepDownPercent: Double
    var reminderEnabled: Bool
    var reminderHours: [Int]   // for example [9, 13, 18]
    var startBaselineMg: Double
    var targetDate: Date?

    init(
        dailyTargetMg: Double = 60,
        taperMode: TaperMode = .percent,
        weeklyStepDownMg: Double = 10,
        weeklyStepDownPercent: Double = 10,
        reminderEnabled: Bool = false,
        reminderHours: [Int] = [9, 13, 18],
        startBaselineMg: Double = 100,
        targetDate: Date? = nil
    ) {
        self.dailyTargetMg = dailyTargetMg
        self.taperMode = taperMode
        self.weeklyStepDownMg = weeklyStepDownMg
        self.weeklyStepDownPercent = weeklyStepDownPercent
        self.reminderEnabled = reminderEnabled
        self.reminderHours = reminderHours
        self.startBaselineMg = startBaselineMg
        self.targetDate = targetDate
    }
}

enum TaperMode: Int, Codable, CaseIterable, Identifiable {
    case mg
    case percent
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .mg: return "Fixed mg per week"
        case .percent: return "Percent per week"
        }
    }
}