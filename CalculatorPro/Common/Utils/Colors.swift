import SwiftUI

enum CalculatorTheme: String, CaseIterable, Identifiable {
    case mist
    case ocean
    case lavender
    case sunset
    case forest
    case rose
    case graphite
    case citrus
    case celadon
    case sakura
    case dune
    case coffee
    case aurora
    case avocado
    case berry
    case indigo

    var id: String { rawValue }

    var name: String {
        switch self {
        case .mist: return "雾白"
        case .ocean: return "海洋"
        case .lavender: return "薰衣草"
        case .sunset: return "落日"
        case .forest: return "森林"
        case .rose: return "玫瑰"
        case .graphite: return "石墨"
        case .citrus: return "柑橘"
        case .celadon: return "青瓷"
        case .sakura: return "樱花"
        case .dune: return "沙丘"
        case .coffee: return "咖啡"
        case .aurora: return "极光"
        case .avocado: return "牛油果"
        case .berry: return "莓果"
        case .indigo: return "靛蓝"
        }
    }

    var icon: String {
        switch self {
        case .mist: return "leaf.fill"
        case .ocean: return "water.waves"
        case .lavender: return "sparkles"
        case .sunset: return "sun.horizon.fill"
        case .forest: return "tree.fill"
        case .rose: return "heart.fill"
        case .graphite: return "circle.lefthalf.filled"
        case .citrus: return "sun.max.fill"
        case .celadon: return "drop.fill"
        case .sakura: return "camera.macro"
        case .dune: return "mountain.2.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .aurora: return "wand.and.stars"
        case .avocado: return "oval.fill"
        case .berry: return "circle.hexagongrid.fill"
        case .indigo: return "moon.stars.fill"
        }
    }

    var background: Color {
        switch self {
        case .mist: return Color(red: 0.94, green: 0.97, blue: 0.96)
        case .ocean: return Color(red: 0.91, green: 0.96, blue: 0.98)
        case .lavender: return Color(red: 0.96, green: 0.94, blue: 0.98)
        case .sunset: return Color(red: 0.99, green: 0.95, blue: 0.91)
        case .forest: return Color(red: 0.93, green: 0.96, blue: 0.91)
        case .rose: return Color(red: 1.00, green: 0.94, blue: 0.95)
        case .graphite: return Color(red: 0.91, green: 0.93, blue: 0.94)
        case .citrus: return Color(red: 1.00, green: 0.97, blue: 0.88)
        case .celadon: return Color(red: 0.94, green: 0.98, blue: 0.96)
        case .sakura: return Color(red: 1.00, green: 0.95, blue: 0.97)
        case .dune: return Color(red: 0.97, green: 0.95, blue: 0.90)
        case .coffee: return Color(red: 0.96, green: 0.93, blue: 0.91)
        case .aurora: return Color(red: 0.93, green: 0.98, blue: 0.97)
        case .avocado: return Color(red: 0.96, green: 0.97, blue: 0.91)
        case .berry: return Color(red: 0.98, green: 0.93, blue: 0.96)
        case .indigo: return Color(red: 0.94, green: 0.95, blue: 0.98)
        }
    }

    var numberKey: Color {
        Color.white.opacity(0.72)
    }

    var functionKey: Color {
        switch self {
        case .mist: return Color(red: 0.93, green: 0.76, blue: 0.61)
        case .ocean: return Color(red: 0.66, green: 0.83, blue: 0.88)
        case .lavender: return Color(red: 0.87, green: 0.75, blue: 0.86)
        case .sunset: return Color(red: 0.95, green: 0.72, blue: 0.58)
        case .forest: return Color(red: 0.73, green: 0.83, blue: 0.66)
        case .rose: return Color(red: 0.91, green: 0.73, blue: 0.77)
        case .graphite: return Color(red: 0.81, green: 0.83, blue: 0.85)
        case .citrus: return Color(red: 0.95, green: 0.83, blue: 0.48)
        case .celadon: return Color(red: 0.72, green: 0.86, blue: 0.80)
        case .sakura: return Color(red: 0.94, green: 0.78, blue: 0.85)
        case .dune: return Color(red: 0.86, green: 0.78, blue: 0.65)
        case .coffee: return Color(red: 0.84, green: 0.73, blue: 0.66)
        case .aurora: return Color(red: 0.71, green: 0.86, blue: 0.85)
        case .avocado: return Color(red: 0.80, green: 0.84, blue: 0.64)
        case .berry: return Color(red: 0.86, green: 0.71, blue: 0.80)
        case .indigo: return Color(red: 0.77, green: 0.79, blue: 0.89)
        }
    }

    var operationKey: Color {
        switch self {
        case .mist: return Color(red: 0.39, green: 0.47, blue: 0.65)
        case .ocean: return Color(red: 0.28, green: 0.48, blue: 0.65)
        case .lavender: return Color(red: 0.47, green: 0.38, blue: 0.62)
        case .sunset: return Color(red: 0.68, green: 0.39, blue: 0.42)
        case .forest: return Color(red: 0.24, green: 0.42, blue: 0.31)
        case .rose: return Color(red: 0.58, green: 0.33, blue: 0.41)
        case .graphite: return Color(red: 0.29, green: 0.31, blue: 0.34)
        case .citrus: return Color(red: 0.50, green: 0.38, blue: 0.11)
        case .celadon: return Color(red: 0.24, green: 0.44, blue: 0.38)
        case .sakura: return Color(red: 0.54, green: 0.31, blue: 0.44)
        case .dune: return Color(red: 0.42, green: 0.35, blue: 0.26)
        case .coffee: return Color(red: 0.43, green: 0.29, blue: 0.24)
        case .aurora: return Color(red: 0.20, green: 0.42, blue: 0.44)
        case .avocado: return Color(red: 0.36, green: 0.42, blue: 0.20)
        case .berry: return Color(red: 0.46, green: 0.26, blue: 0.37)
        case .indigo: return Color(red: 0.29, green: 0.34, blue: 0.52)
        }
    }

    var equalKey: Color {
        switch self {
        case .mist: return Color(red: 0.20, green: 0.51, blue: 0.48)
        case .ocean: return Color(red: 0.14, green: 0.55, blue: 0.58)
        case .lavender: return Color(red: 0.55, green: 0.35, blue: 0.55)
        case .sunset: return Color(red: 0.73, green: 0.36, blue: 0.25)
        case .forest: return Color(red: 0.18, green: 0.46, blue: 0.37)
        case .rose: return Color(red: 0.64, green: 0.26, blue: 0.34)
        case .graphite: return Color(red: 0.20, green: 0.23, blue: 0.25)
        case .citrus: return Color(red: 0.37, green: 0.44, blue: 0.15)
        case .celadon: return Color(red: 0.14, green: 0.44, blue: 0.37)
        case .sakura: return Color(red: 0.63, green: 0.24, blue: 0.41)
        case .dune: return Color(red: 0.46, green: 0.38, blue: 0.23)
        case .coffee: return Color(red: 0.46, green: 0.32, blue: 0.23)
        case .aurora: return Color(red: 0.12, green: 0.45, blue: 0.42)
        case .avocado: return Color(red: 0.32, green: 0.42, blue: 0.15)
        case .berry: return Color(red: 0.50, green: 0.21, blue: 0.32)
        case .indigo: return Color(red: 0.27, green: 0.31, blue: 0.55)
        }
    }

    var primaryInk: Color {
        switch self {
        case .mist: return Color(red: 0.13, green: 0.21, blue: 0.28)
        case .ocean: return Color(red: 0.09, green: 0.22, blue: 0.31)
        case .lavender: return Color(red: 0.22, green: 0.17, blue: 0.31)
        case .sunset: return Color(red: 0.28, green: 0.18, blue: 0.16)
        case .forest: return Color(red: 0.09, green: 0.21, blue: 0.12)
        case .rose: return Color(red: 0.28, green: 0.14, blue: 0.17)
        case .graphite: return Color(red: 0.13, green: 0.15, blue: 0.16)
        case .citrus: return Color(red: 0.22, green: 0.17, blue: 0.06)
        case .celadon: return Color(red: 0.09, green: 0.22, blue: 0.18)
        case .sakura: return Color(red: 0.26, green: 0.13, blue: 0.19)
        case .dune: return Color(red: 0.19, green: 0.15, blue: 0.11)
        case .coffee: return Color(red: 0.20, green: 0.14, blue: 0.11)
        case .aurora: return Color(red: 0.07, green: 0.21, blue: 0.22)
        case .avocado: return Color(red: 0.16, green: 0.19, blue: 0.08)
        case .berry: return Color(red: 0.21, green: 0.11, blue: 0.16)
        case .indigo: return Color(red: 0.13, green: 0.15, blue: 0.27)
        }
    }

    var secondaryInk: Color {
        switch self {
        case .mist: return Color(red: 0.35, green: 0.43, blue: 0.47)
        case .ocean: return Color(red: 0.30, green: 0.43, blue: 0.49)
        case .lavender: return Color(red: 0.42, green: 0.36, blue: 0.48)
        case .sunset: return Color(red: 0.49, green: 0.37, blue: 0.33)
        case .forest: return Color(red: 0.30, green: 0.40, blue: 0.31)
        case .rose: return Color(red: 0.47, green: 0.34, blue: 0.37)
        case .graphite: return Color(red: 0.35, green: 0.38, blue: 0.40)
        case .citrus: return Color(red: 0.43, green: 0.36, blue: 0.20)
        case .celadon: return Color(red: 0.30, green: 0.42, blue: 0.37)
        case .sakura: return Color(red: 0.46, green: 0.32, blue: 0.38)
        case .dune: return Color(red: 0.40, green: 0.34, blue: 0.27)
        case .coffee: return Color(red: 0.42, green: 0.32, blue: 0.27)
        case .aurora: return Color(red: 0.27, green: 0.41, blue: 0.41)
        case .avocado: return Color(red: 0.37, green: 0.41, blue: 0.23)
        case .berry: return Color(red: 0.43, green: 0.30, blue: 0.36)
        case .indigo: return Color(red: 0.33, green: 0.36, blue: 0.49)
        }
    }
}

private struct CalculatorThemeKey: EnvironmentKey {
    static let defaultValue = CalculatorTheme.mist
}

extension EnvironmentValues {
    var calculatorTheme: CalculatorTheme {
        get { self[CalculatorThemeKey.self] }
        set { self[CalculatorThemeKey.self] = newValue }
    }
}

// 颜色扩展
extension Color {
    static let background = Color(red: 0.94, green: 0.97, blue: 0.96)
    static let displayBackground = Color(red: 0.13, green: 0.21, blue: 0.28)
    static let numberKey = Color.white.opacity(0.72)
    static let functionKey = Color(red: 0.93, green: 0.76, blue: 0.61)
    static let operationKey = Color(red: 0.39, green: 0.47, blue: 0.65)
    static let equalKey = Color(red: 0.20, green: 0.51, blue: 0.48)
    static let primaryInk = Color(red: 0.13, green: 0.21, blue: 0.28)
    static let secondaryInk = Color(red: 0.35, green: 0.43, blue: 0.47)
}
