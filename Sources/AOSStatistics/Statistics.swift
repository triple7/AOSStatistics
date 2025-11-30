//
//  Statistics.swift
//  AOSTests
//
//  Created by Yuma decaux on 19/5/2025.
//


import Foundation
import GameplayKit

public struct Bin {
    public var min: Float
    public var max: Float
    public var weight: Float      // Fraction of total (0–1)
    public var percentage: Float  // Percentage 0–100

    public mutating func setWeight(weight: Float) {
        self.weight = weight
        self.percentage = weight * 100.0
    }
}

public func histogram(values: [Float], bins: Int, range: (Float, Float)? = nil) -> ([Int], [Bin]) {
    guard bins > 0, !values.isEmpty else { return ([], []) }

    let minVal: Float
    let maxVal: Float

    if let range = range {
        minVal = range.0
        maxVal = range.1
    } else {
        minVal = values.min()!
        maxVal = values.max()!
    }

    let binWidth = (maxVal - minVal) / Float(bins)
    var counts = Array(repeating: 0, count: bins)
    var edges = [Bin]()

    var lastEdge: Float = 0
    for i in 0...bins {
        let edge = minVal + Float(i) * binWidth
        edges.append(Bin(min: lastEdge, max: edge, weight: 0, percentage: 0))
        lastEdge = edge
    }

    for value in values {
        if value < minVal || value > maxVal { continue }

        var index = Int((value - minVal) / binWidth)
        if index == bins { index = bins - 1 }  // Edge case: max value
        counts[index] += 1
    }

    let total = Float(values.count)
    for i in 0..<bins {
        let w = Float(counts[i]) / total
        edges[i].setWeight(weight: w)
    }

    return (counts, edges)
}

public func sampleFromBins(using rng: GKRandomSource, bins: [Bin]) -> Float {
    let totalWeight = bins.map { $0.weight }.reduce(0, +)
    let threshold = rng.nextUniform() * totalWeight

    var cumulative: Float = 0.0
    for bin in bins {
        cumulative += bin.weight
        if threshold <= cumulative {
            let u = rng.nextUniform()
            return bin.min + (bin.max - bin.min) * u
        }
    }
    return bins.last!.max
}

public func generateHistograms(values: [Float], iterations: Int, bins: Int) -> [Int: [Bin]] {
    var results: [Int: [Bin]] = [:]
    var currentValues = values

    for iter in 1...iterations {
        let (_, edges) = histogram(values: currentValues, bins: bins)

        // Only take the first `bins` entries, since edges contains bins+1 items.
        let binStructs = Array(edges[0..<bins])
        results[iter] = binStructs

        guard let maxIndex = binStructs.enumerated().max(by: { $0.element.weight < $1.element.weight })?.offset else {
            break
        }

        let largestBin = binStructs[maxIndex]
        let minRange = largestBin.min
        let maxRange = largestBin.max

        let filtered = currentValues.filter { v in
            (v >= minRange && v < maxRange)
        }

        if filtered.isEmpty {
            break
        }

        currentValues = filtered
    }

    return results
}
