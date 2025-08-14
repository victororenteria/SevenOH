import Foundation
import SwiftUI

/// Optional support for passing preset milligram amounts via URL query, used by quick buttons in the widget.
extension RootView {
    /// Applies a custom URL to the view, pre‑filling the log sheet if the `preset` query item is present.
    func applyURL(_ url: URL) {
        guard url.scheme == "sevenoh" else { return }
        if url.host == "log" {
            if let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let preset = comps.queryItems?.first(where: { $0.name == "preset" })?.value {
                // Persist the preset milligram value into user defaults to be read by LogSheet
                UserDefaults.standard.setValue(preset, forKey: "sevenoh.preset")
            }
        }
    }
}