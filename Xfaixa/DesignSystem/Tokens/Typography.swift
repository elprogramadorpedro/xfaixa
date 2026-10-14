import SwiftUI

/// Type scale built on `Font.TextStyle`, so every token scales with Dynamic Type.
/// Display and title styles use the rounded design to give the brand a friendlier voice.
nonisolated enum Typography {
    static let display = Font.system(.largeTitle, design: .rounded, weight: .heavy)
    static let title = Font.system(.title2, design: .rounded, weight: .bold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.body
    static let bodyEmphasized = Font.body.weight(.semibold)
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption.weight(.medium)
}
