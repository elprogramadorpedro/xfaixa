import Foundation

/// Remembers which fruit avatar each user picked.
@MainActor
protocol AvatarStore: AnyObject {
    func fruit(for userId: String) -> Fruit?
    func setFruit(_ fruit: Fruit, for userId: String)
}

/// `AvatarStore` backed by `UserDefaults`. A single small value per user doesn't justify a SwiftData model.
@MainActor
final class UserDefaultsAvatarStore: AvatarStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func fruit(for userId: String) -> Fruit? {
        defaults.string(forKey: key(for: userId)).flatMap(Fruit.init(rawValue:))
    }

    func setFruit(_ fruit: Fruit, for userId: String) {
        defaults.set(fruit.rawValue, forKey: key(for: userId))
    }

    private func key(for userId: String) -> String {
        "avatar.fruit.\(userId)"
    }
}

/// `AvatarStore` kept in memory, for previews and tests.
@MainActor
final class InMemoryAvatarStore: AvatarStore {
    private var fruits: [String: Fruit]

    init(fruits: [String: Fruit] = [:]) {
        self.fruits = fruits
    }

    func fruit(for userId: String) -> Fruit? {
        fruits[userId]
    }

    func setFruit(_ fruit: Fruit, for userId: String) {
        fruits[userId] = fruit
    }
}
