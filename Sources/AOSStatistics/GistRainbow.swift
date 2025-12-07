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

public struct GistRainbow: Codable {

    public struct RGB: Codable {
        public let r: CGFloat
        public let g: CGFloat
        public let b: CGFloat

        public func color() -> Color {
            Color(red: r, green: g, blue: b, alpha: 1.0)
        }
    }

    // MARK: - High → Low Frequency (Violet → Red)

    public let violet    = RGB(r: 0.56, g: 0.00, b: 1.00)
    public let indigo    = RGB(r: 0.29, g: 0.00, b: 0.51)
    public let blue      = RGB(r: 0.00, g: 0.00, b: 1.00)
    public let azure     = RGB(r: 0.00, g: 0.50, b: 1.00)
    public let cyan      = RGB(r: 0.00, g: 1.00, b: 1.00)
    public let spring    = RGB(r: 0.00, g: 1.00, b: 0.60)
    public let green     = RGB(r: 0.00, g: 1.00, b: 0.00)
    public let chartreuse = RGB(r: 0.50, g: 1.00, b: 0.00)
    public let yellow    = RGB(r: 1.00, g: 1.00, b: 0.00)
    public let orange    = RGB(r: 1.00, g: 0.50, b: 0.00)
    public let red       = RGB(r: 1.00, g: 0.00, b: 0.00)

    // MARK: - Return all colors in correct frequency order
    public func getColors() -> [Color] {
        return [
            violet.color(),
            indigo.color(),
            blue.color(),
            azure.color(),
            cyan.color(),
            spring.color(),
            green.color(),
            chartreuse.color(),
            yellow.color(),
            orange.color(),
            red.color()
        ]
    }
}
