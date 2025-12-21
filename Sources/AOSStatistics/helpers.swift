//
//  Untitled.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 21/12/2025.
//

import Foundation

public func normalize(_ values: [Float]) -> [Float] {
    guard let min = values.min(),
          let max = values.max(),
          max > min else {
        return values.map { _ in 0 }
    }

    return values.map { ($0 - min) / (max - min) }
}

public func inverseTransform(
    of transform: TransformType,
    values: [Float]
) -> [Float] {

    switch transform {

    case .sqrt:
        return values.map { $0 * $0 }

    case .cbrt:
        return values.map { $0 * $0 * $0 }

    case .log(let offset):
        return values.map { exp($0) - offset }

    case .log10(let offset):
        return values.map { pow(10, $0) - offset }

    case .asinh(let scale):
        return values.map { sinh($0) * scale }

    default:
        fatalError("Inverse not defined for \(transform)")
    }
}

