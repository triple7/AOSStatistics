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

    func recurse(level: Int, vals: [Float]) {
        guard level <= iterations else { return }
        guard !vals.isEmpty else { return }

        let (_, edges) = histogram(values: vals, bins: bins)
        let allBins = Array(edges[0..<bins])   // keep exactly 'bins' bins

        // Find the bin with the largest amplitude
        guard let maxIndex = allBins.enumerated()
            .max(by: { $0.element.weight < $1.element.weight })?.offset else {
            return
        }

        // Determine if this is the final iteration
        let isLastIteration: Bool = (level == iterations)

        // Filter values to the max bin
        let largestBin = allBins[maxIndex]
        let nextValues = vals.filter { v in
            v >= largestBin.min && v < largestBin.max
        }

        // If this is the last iteration OR filtering yields no further values:
        // → store ALL bins (including largest)
        if nextValues.isEmpty || isLastIteration {
            results[level] = allBins
            return
        }

        // Otherwise: store all bins except the largest one
        var nonLargestBins = allBins
        nonLargestBins.remove(at: maxIndex)
        results[level] = nonLargestBins

        // Continue recursion
        recurse(level: level + 1, vals: nextValues)
    }

    recurse(level: 1, vals: values)
    return results
}
