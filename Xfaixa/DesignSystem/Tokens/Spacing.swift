import CoreGraphics

/// Spacing scale on a 4-point grid.
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

/// Corner radii. Kept generous so glass surfaces read as soft, friendly shapes.
enum Radius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 18
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

/// Fixed sizes for recurring visual elements.
enum Size {
    static let artworkSmall: CGFloat = 44
    static let artworkRow: CGFloat = 56
    static let iconButton: CGFloat = 44
    static let avatar: CGFloat = 132
}
