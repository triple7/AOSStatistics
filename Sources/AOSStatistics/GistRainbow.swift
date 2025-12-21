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

    public init() {}

    // MARK: - Full spectrum (high → low frequency)

    public func getColors() -> [Color] {
        return [
            violetVeryDark, violetDark, violet, violetLight, violetVeryLight,
            indigoVeryDark, indigoDark, indigo, indigoLight, indigoVeryLight,
            blueVeryDark, blueDark, blue, blueLight, blueVeryLight,
            azureVeryDark, azureDark, azure, azureLight, azureVeryLight,
            cyanVeryDark, cyanDark, cyan, cyanLight, cyanVeryLight,
            greenVeryDark, greenDark, green, greenLight, greenVeryLight,
            yellowVeryDark, yellowDark, yellow, yellowLight, yellowVeryLight,
            orangeVeryDark, orangeDark, orange, orangeLight, orangeVeryLight
        ].map { $0.color() }
    }
}
