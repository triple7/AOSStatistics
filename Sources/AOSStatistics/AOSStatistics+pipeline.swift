//
//  Untitled.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 21/12/2025.
//

import Foundation

public func applyPipeline<T: TransformNumeric>(
    transforms: [TransformType],
    values: [T]
) -> [Float] {

    var current = values.map(Float.init)
    var lastTransform: TransformType?

    for transform in transforms {

        switch transform {

        case .inverse:
            guard let last = lastTransform else {
                fatalError("No previous transform to invert")
            }
            current = inverseTransform(of: last, values: current)

        case .custom(let fn):
            current = current.map(fn)

        case .normalize:
            current = normalize(current)

        default:
            current = applyTransform(
                transformType: transform,
                values: current
            )
        }

        if case .inverse = transform {
            // do not update lastTransform
        } else {
            lastTransform = transform
        }
    }

    return current
}

