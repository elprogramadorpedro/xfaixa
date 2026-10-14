import SwiftUI

/// Fruit avatars a user can pick for their profile.
enum Fruit: String, CaseIterable, Identifiable, Sendable {
    case pineapple
    case mango
    case watermelon
    case orange
    case coconut
    case strawberry
    case banana
    case kiwi

    static let `default`: Fruit = .pineapple

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .pineapple: "🍍"
        case .mango: "🥭"
        case .watermelon: "🍉"
        case .orange: "🍊"
        case .coconut: "🥥"
        case .strawberry: "🍓"
        case .banana: "🍌"
        case .kiwi: "🥝"
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .pineapple: "Abacaxi"
        case .mango: "Manga"
        case .watermelon: "Melancia"
        case .orange: "Laranja"
        case .coconut: "Coco"
        case .strawberry: "Morango"
        case .banana: "Banana"
        case .kiwi: "Kiwi"
        }
    }

    var tint: Color {
        switch self {
        case .pineapple, .banana: .pineappleYellow
        case .mango, .orange: .tropicalOrange
        case .watermelon, .strawberry: .errorRed
        case .coconut: .deepGreen
        case .kiwi: .leafGreen
        }
    }
}
