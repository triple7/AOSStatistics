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

    guard !values.isEmpty, bins > 0 else {
        return ([], [])
    }

    // Determine range
    let minVal: Float
    let maxVal: Float

    if let r = range {
        minVal = r.0
        maxVal = r.1
    } else {
        minVal = values.min()!
        maxVal = values.max()!
    }

    // Compute bin width
    let binWidth = (maxVal - minVal) / Float(bins)

    // Prepare counts and bin edges
    var counts = Array(repeating: 0, count: bins)
    var edges: [Bin] = []
    edges.reserveCapacity(bins)

    // Build correct bin edges
    var lastEdge = minVal

    for i in 1...bins {
        let nextEdge = minVal + Float(i) * binWidth
        edges.append(Bin(min: lastEdge, max: nextEdge, weight: 0, percentage: 0))
        lastEdge = nextEdge
    }

    // Fill counts
    for v in values {
        if v < minVal { continue }
        if v > maxVal { continue }

        // compute bin index
        var idx = Int((v - minVal) / binWidth)

        // Handle max-value edge case
        if idx == bins { idx = bins - 1 }

        counts[idx] += 1
    }

    // Assign weights and percentages
    let total = Float(values.count)

    for i in 0..<bins {
        let w = Float(counts[i]) / total
        edges[i].setWeight(weight: w)
    }

    return (counts, edges)
}

public func refineBinsRecursively(
    values: [Float],
    maxBins: Int,
    thresholdPercentage: Float
) -> [Bin] {

    func recurse(values: [Float], range: (Float, Float)?) -> [Bin] {
        let (_, bins) = histogram(values: values, bins: maxBins, range: range)
        let usableBins = Array(bins[0..<maxBins])

        // Find largest bin
        guard let maxIndex = usableBins.enumerated()
            .max(by: { $0.element.percentage < $1.element.percentage })?.offset else {
            return usableBins
        }

        let largest = usableBins[maxIndex]

        // If this bin does NOT exceed the threshold, we stop recursing
        if largest.percentage < thresholdPercentage {
            return usableBins
        }

        // Filter values into the largest bin's range
        let filtered = values.filter { v in
            v >= largest.min && v < largest.max
        }

        if filtered.isEmpty {
            // Cannot refine further — return current bins
            return usableBins
        }

        // Recurse into this narrowed range
        let refined = recurse(values: filtered, range: (largest.min, largest.max))

        // After recursion, we must reconstitute the bins:
        // i.e., return NEW bins spanning the narrowed domain
        let newMin = refined.first!.min
        let newMax = refined.last!.max

        let (_, finalBins) = histogram(values: values, bins: maxBins, range: (newMin, newMax))
        return Array(finalBins[0..<maxBins])
    }

    return recurse(values: values, range: nil)
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

public func spreadBinLists(values: [Float], bins: Int, by percentage: CGFloat) -> [Bin] {
    let (_, originalBins) = histogram(values: values, bins: bins)
    print("Checking original bins")
    for bin in originalBins {
        print("bin: \(bin.min) \(bin.max) percentage \(bin.percentage)")
    }

    // Only keep the first `bins` entries (histogram returns bins + 1 edges)
    let binsOnly = Array(originalBins[0..<bins])

    var results: [Bin] = []
    var currentGroup: [Bin] = []
    var cumulative: CGFloat = 0.0

    for bin in binsOnly {
        let p = CGFloat(bin.percentage)
        let newCumulative = cumulative + p

        // If adding the bin exceeds the target threshold, close previous group
        if !currentGroup.isEmpty && newCumulative > percentage {
            // Create a merged bin
            let merged = mergeBins(group: currentGroup)
            results.append(merged)

            // Start a new group with current bin
            currentGroup = [bin]
            cumulative = p
        } else {
            // Add bin normally
            currentGroup.append(bin)
            cumulative = newCumulative
        }
    }

    // Add the final group if any bins remain
    if !currentGroup.isEmpty {
        let merged = mergeBins(group: currentGroup)
        results.append(merged)
    }

    return results
}

/// Merge a group of bins into one combined bin
private func mergeBins(group: [Bin]) -> Bin {
    guard let first = group.first else {
        return Bin(min: 0, max: 0, weight: 0, percentage: 0)
    }

    let minVal = group.map { $0.min }.min()!
    let maxVal = group.map { $0.max }.max()!
    let totalWeight = group.map { $0.weight }.reduce(0, +)

    var merged = Bin(
        min: minVal,
        max: maxVal,
        weight: totalWeight,
        percentage: totalWeight * 100
    )

    return merged
}

