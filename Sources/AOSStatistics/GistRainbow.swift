//
//  GistRainbow.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 7/12/2025.
//


import SceneKit

#if os(iOS)
import UIKit
public typealias Color = UIColor
#elseif os(macOS)
import AppKit
public typealias Color = NSColor
#endif
import CoreGraphics

public enum ColorFamily {
    case violet
    case indigo
    case blue
    case azure
    case cyan
    case green
    case yellow
    case orange
    case red
}

public struct GistRainbow: Codable {

    public struct RGB: Codable {
        public var r: CGFloat
        public var g: CGFloat
        public var b: CGFloat

        public func color() -> Color {
            Color(red: r, green: g, blue: b, alpha: 1.0)
        }
    }

    // MARK: - Violet
    public var violetVeryDark  = RGB(r: 0.28, g: 0.00, b: 0.50)
    public var violetDark      = RGB(r: 0.42, g: 0.00, b: 0.75)
    public var violet          = RGB(r: 0.56, g: 0.00, b: 1.00)
    public var violetLight     = RGB(r: 0.70, g: 0.40, b: 1.00)
    public var violetVeryLight = RGB(r: 0.85, g: 0.70, b: 1.00)

    // MARK: - Indigo
    public var indigoVeryDark  = RGB(r: 0.14, g: 0.00, b: 0.26)
    public var indigoDark      = RGB(r: 0.22, g: 0.00, b: 0.38)
    public var indigo          = RGB(r: 0.29, g: 0.00, b: 0.51)
    public var indigoLight     = RGB(r: 0.48, g: 0.30, b: 0.70)
    public var indigoVeryLight = RGB(r: 0.70, g: 0.60, b: 0.85)

    // MARK: - Blue
    public var blueVeryDark    = RGB(r: 0.00, g: 0.00, b: 0.40)
    public var blueDark        = RGB(r: 0.00, g: 0.00, b: 0.70)
    public var blue            = RGB(r: 0.00, g: 0.00, b: 1.00)
    public var blueLight       = RGB(r: 0.40, g: 0.55, b: 1.00)
    public var blueVeryLight   = RGB(r: 0.70, g: 0.80, b: 1.00)

    // MARK: - Azure
    public var azureVeryDark   = RGB(r: 0.00, g: 0.25, b: 0.50)
    public var azureDark       = RGB(r: 0.00, g: 0.38, b: 0.75)
    public var azure           = RGB(r: 0.00, g: 0.50, b: 1.00)
    public var azureLight      = RGB(r: 0.40, g: 0.70, b: 1.00)
    public var azureVeryLight  = RGB(r: 0.70, g: 0.85, b: 1.00)

    // MARK: - Cyan
    public var cyanVeryDark    = RGB(r: 0.00, g: 0.50, b: 0.50)
    public var cyanDark        = RGB(r: 0.00, g: 0.75, b: 0.75)
    public var cyan            = RGB(r: 0.00, g: 1.00, b: 1.00)
    public var cyanLight       = RGB(r: 0.50, g: 1.00, b: 1.00)
    public var cyanVeryLight   = RGB(r: 0.80, g: 1.00, b: 1.00)

    // MARK: - Green
    public var greenVeryDark   = RGB(r: 0.00, g: 0.40, b: 0.00)
    public var greenDark       = RGB(r: 0.00, g: 0.70, b: 0.00)
    public var green           = RGB(r: 0.00, g: 1.00, b: 0.00)
    public var greenLight      = RGB(r: 0.50, g: 1.00, b: 0.50)
    public var greenVeryLight  = RGB(r: 0.80, g: 1.00, b: 0.80)

    // MARK: - Yellow
    public var yellowVeryDark  = RGB(r: 0.60, g: 0.60, b: 0.00)
    public var yellowDark      = RGB(r: 0.85, g: 0.85, b: 0.00)
    public var yellow          = RGB(r: 1.00, g: 1.00, b: 0.00)
    public var yellowLight     = RGB(r: 1.00, g: 1.00, b: 0.50)
    public var yellowVeryLight = RGB(r: 1.00, g: 1.00, b: 0.80)

    // MARK: - Orange
    public var orangeVeryDark  = RGB(r: 0.60, g: 0.30, b: 0.00)
    public var orangeDark      = RGB(r: 0.85, g: 0.45, b: 0.00)
    public var orange          = RGB(r: 1.00, g: 0.50, b: 0.00)
    public var orangeLight     = RGB(r: 1.00, g: 0.70, b: 0.40)
    public var orangeVeryLight = RGB(r: 1.00, g: 0.85, b: 0.70)

    // MARK: - Red (NEW)
    public var redVeryDark     = RGB(r: 0.50, g: 0.00, b: 0.00)
    public var redDark         = RGB(r: 0.75, g: 0.00, b: 0.00)
    public var red             = RGB(r: 1.00, g: 0.00, b: 0.00)
    public var redLight        = RGB(r: 1.00, g: 0.40, b: 0.40)
    public var redVeryLight    = RGB(r: 1.00, g: 0.70, b: 0.70)

    public init() {}

    public func darkestAndBrightest(
        for family: ColorFamily
    ) -> (dark: Color, bright: Color) {

        let darkRGB: RGB
        let brightRGB: RGB

        switch family {

        case .violet:
            darkRGB = violetVeryDark
            brightRGB = violetVeryLight

        case .indigo:
            darkRGB = indigoVeryDark
            brightRGB = indigoVeryLight

        case .blue:
            darkRGB = blueVeryDark
            brightRGB = blueVeryLight

        case .azure:
            darkRGB = azureVeryDark
            brightRGB = azureVeryLight

        case .cyan:
            darkRGB = cyanVeryDark
            brightRGB = cyanVeryLight

        case .green:
            darkRGB = greenVeryDark
            brightRGB = greenVeryLight

        case .yellow:
            darkRGB = yellowVeryDark
            brightRGB = yellowVeryLight

        case .orange:
            darkRGB = orangeVeryDark
            brightRGB = orangeVeryLight

        case .red:
            darkRGB = redVeryDark
            brightRGB = redVeryLight
        }

        return (dark: darkRGB.color(), bright: brightRGB.color())
    }

    // MARK: - Full spectrum (high → low frequency)

    public func getColors() -> [Color] {
        return [
            // Violet — bright → dark
            violetVeryLight, violetLight, violet, violetDark, violetVeryDark,

            // Indigo — dark → bright
            indigoVeryDark, indigoDark, indigo, indigoLight, indigoVeryLight,

            // Blue — bright → dark
            blueVeryLight, blueLight, blue, blueDark, blueVeryDark,

            // Azure — dark → bright
            azureVeryDark, azureDark, azure, azureLight, azureVeryLight,

            // Cyan — bright → dark
            cyanVeryLight, cyanLight, cyan, cyanDark, cyanVeryDark,

            // Green — dark → bright
            greenVeryDark, greenDark, green, greenLight, greenVeryLight,

            // Yellow — bright → dark
            yellowVeryLight, yellowLight, yellow, yellowDark, yellowVeryDark,

            // Orange — dark → bright
            orangeVeryDark, orangeDark, orange, orangeLight, orangeVeryLight,

            // Red — bright → dark
            redVeryLight, redLight, red, redDark, redVeryDark
        ].map { $0.color() }
    }
}

internal func interpolate(_ c1: Color, _ c2: Color, t: CGFloat) -> Color {
    let t = max(0, min(1, t)) // clamp

    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

    c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

    return Color(
        red:   r1 + (r2 - r1) * t,
        green: g1 + (g2 - g1) * t,
        blue:  b1 + (b2 - b1) * t,
        alpha: a1 + (a2 - a1) * t
    )
}

public func interpolateGradient(
    colors: [Color],
    count: Int
) -> [Color] {
    guard colors.count > 1, count > 0 else {
        return Array(repeating: colors.first ?? .clear, count: count)
    }

    let lastIndex = colors.count - 1
    let maxIndex = CGFloat(lastIndex)

    return (0..<count).map { i in
        let t = CGFloat(i) / CGFloat(count - 1)      // 0 → 1
        let position = t * maxIndex

        let lower = Int(floor(position))
        let upper = min(lower + 1, lastIndex)
        let localT = position - CGFloat(lower)

        return interpolate(colors[lower], colors[upper], t: localT)
    }
}

