//
//  Statistics.swift
//  AOSTests
//
//  Created by Yuma decaux on 19/5/2025.
//

import Foundation
import CoreGraphics
import GameplayKit

public struct Bin:Equatable, Comparable {
    public var min: Float
    public var max: Float
    public var weight: Float      // Fraction of total (0–1)
    public var percentage: Float  // Percentage 0–100

    public mutating func setWeight(weight: Float) {
        self.weight = weight
        self.percentage = weight * 100.0
    }
    
    public static func <(lhs: Bin, rhs: Bin) -> Bool {
        return lhs.max < rhs.max
    }
}

// MARK: - Numeric Protocol (Public)

public protocol TransformNumeric: BinaryFloatingPoint {
    static func log(_ x: Self) -> Self
    static func log10(_ x: Self) -> Self
    static func exp(_ x: Self) -> Self
    static func sqrt(_ x: Self) -> Self
    static func pow(_ x: Self, _ y: Self) -> Self
    static func asinh(_ x: Self) -> Self
}

// MARK: - Float Conformance

extension Float: TransformNumeric {
    public static func log(_ x: Float) -> Float { Foundation.log(x) }
    public static func log10(_ x: Float) -> Float { Foundation.log10(x) }
    public static func exp(_ x: Float) -> Float { Foundation.exp(x) }
    public static func sqrt(_ x: Float) -> Float { Foundation.sqrt(x) }
    public static func pow(_ x: Float, _ y: Float) -> Float { Foundation.pow(x, y) }
    public static func asinh(_ x: Float) -> Float { Foundation.asinh(x) }
}

// MARK: - Double Conformance

extension Double: TransformNumeric {
    public static func log(_ x: Double) -> Double { Foundation.log(x) }
    public static func log10(_ x: Double) -> Double { Foundation.log10(x) }
    public static func exp(_ x: Double) -> Double { Foundation.exp(x) }
    public static func sqrt(_ x: Double) -> Double { Foundation.sqrt(x) }
    public static func pow(_ x: Double, _ y: Double) -> Double { Foundation.pow(x, y) }
    public static func asinh(_ x: Double) -> Double { Foundation.asinh(x) }
}

// MARK: - CGFloat Conformance

extension CGFloat: TransformNumeric {
    public static func log(_ x: CGFloat) -> CGFloat {
        CGFloat(Foundation.log(Double(x)))
    }

    public static func log10(_ x: CGFloat) -> CGFloat {
        CGFloat(Foundation.log10(Double(x)))
    }

    public static func exp(_ x: CGFloat) -> CGFloat {
        CGFloat(Foundation.exp(Double(x)))
    }

    public static func sqrt(_ x: CGFloat) -> CGFloat {
        CGFloat(Foundation.sqrt(Double(x)))
    }

    public static func pow(_ x: CGFloat, _ y: CGFloat) -> CGFloat {
        CGFloat(Foundation.pow(Double(x), Double(y)))
    }

    public static func asinh(_ x: CGFloat) -> CGFloat {
        CGFloat(Foundation.asinh(Double(x)))
    }
}

// MARK: - Power / Root Transforms

public func sqrtTransform<T: TransformNumeric>(_ values: [T]) -> [T] {
    values.map { T.sqrt($0) }
}

public func cbrtTransform<T: TransformNumeric>(_ values: [T]) -> [T] {
    values.map { T.pow($0, T(1) / T(3)) }
}

// MARK: - Log with Offset

public func logOffsetTransform<T: TransformNumeric>(
    _ values: [T],
    offset: T = 500
) -> [T] {
    values.map { T.log($0 + offset) }
}

public func log10OffsetTransform<T: TransformNumeric>(
    _ values: [T],
    offset: T = 500
) -> [T] {
    values.map { T.log10($0 + offset) }
}

// MARK: - asinh Transform

public func asinhTransform<T: TransformNumeric>(
    _ values: [T],
    scale: T = 500
) -> [T] {
    values.map { T.asinh($0 / scale) }
}

// MARK: - Quantile Transform (duplicate-safe, average rank)

public func quantileTransform<T: TransformNumeric>(_ values: [T]) -> [T] {
    guard values.count > 1 else { return values.map { _ in 0 } }

    let sorted = values.sorted()
    let count = T(sorted.count - 1)

    var rankSum: [T: Int] = [:]
    var rankCount: [T: Int] = [:]

    for (i, v) in sorted.enumerated() {
        rankSum[v, default: 0] += i
        rankCount[v, default: 0] += 1
    }

    var avgRank: [T: T] = [:]
    for (v, sum) in rankSum {
        avgRank[v] = T(sum) / T(rankCount[v]!)
    }

    return values.map {
        (avgRank[$0] ?? 0) / count
    }
}

// MARK: - Winsorized Transforms

public func winsorizedTransform<T: TransformNumeric>(
    _ values: [T],
    percentile: T = 0.99
) -> [T] {
    guard !values.isEmpty else { return [] }

    let sorted = values.sorted()
    let index = Int(T(sorted.count - 1) * percentile)
    let cap = sorted[index]

    return values.map { min($0, cap) }
}

public func winsorizedSqrtTransform<T: TransformNumeric>(
    _ values: [T],
    percentile: T = 0.99
) -> [T] {
    winsorizedTransform(values, percentile: percentile).map { T.sqrt($0) }
}

// MARK: - Saturation / Logistic

public func saturationTransform<T: TransformNumeric>(
    _ values: [T],
    k: T = 3000
) -> [T] {
    values.map { x in
        x / (x + k)
    }
}

public func logisticTransform<T: TransformNumeric>(
    _ values: [T],
    mean: T = 3000,
    scale: T = 1000
) -> [T] {
    values.map { x in
        T(1) / (T(1) + T.exp(-(x - mean) / scale))
    }
}

public func histogram(values: [Float], bins: Int, range: (Float, Float)? = nil) -> ([Int], [Bin]) {

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
    print("bin min \(minVal) max \(maxVal)")

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
    
    // Define the global domain (must never shrink)
    var flattenedBins = [Bin]()
    var belowThreshold = false
    var histBins = histogram(values: values, bins: maxBins).1
    var maxBin = histBins.first!
    var maxBinPercentage:Float = 0
    var maxValue:Float = 0

    for bin in histBins {
        print("bin: \(bin.min) \(bin.max)")
    }
    print("total values: \(values.count)")
    while !belowThreshold {
//        print("Reiterating histograms")
        for bin in histBins {
            if bin.percentage/100 > maxBinPercentage {
                maxBinPercentage = bin.percentage/100
                maxBin = bin
                maxValue = bin.max
            }
        }
        
        print("MaxBin: min \(maxBin.min) max \(maxBin.max) percentage \(maxBinPercentage)")
//        print("Percentage threshold: \(thresholdPercentage)")
        if maxBinPercentage > thresholdPercentage {
//            print("MaxBin percentage > threshold")
            // Collate the smaller percentages
            for bin in histBins {
                if bin != maxBin {
                    flattenedBins.append(bin)
                }
            }
            
//            print("Added \(flattenedBins.count) bins")
            // Continue with a new histogram
            let maxbinValues = values.filter{$0 < maxValue}
            
            let newMin = maxbinValues.min()!
            let newMax = maxbinValues.max()!
//            print("New values under maxValue: \(maxbinValues.count) min \(newMin) max \(newMax)")

            if newMin == newMax {
                // reached the last bin
                print("Last max bin \(maxBin.min) \(maxBin.max)")
                flattenedBins.append(maxBin)
                belowThreshold = true
                continue
            }
            histBins = histogram(values: maxbinValues, bins: maxBins).1
            maxBinPercentage = 0
            maxValue = 0

        } else {
//            print("Reached below threshold: \(maxBinPercentage)")
            belowThreshold = true
            continue
        }
    }
    
    // Recalculate bin ranges
    print("Recalculating bin ranges")
    flattenedBins.sort()
//    for bin in flattenedBins {
//        print("flat bin: \(bin.min) \(bin.max)")
//    }
    var finalBins = [Bin]()
    print("Flattened bin count: \(flattenedBins.count)")
    var cumulativeBin:Bin
    var currentIndex = 0
    while currentIndex < flattenedBins.count {
        print("getting bin at index \(currentIndex)")
        cumulativeBin = flattenedBins[currentIndex]
        var cumulativeThreshold = cumulativeBin.percentage/100
        var cumulativeWeight = cumulativeBin.weight
        if cumulativeThreshold <= thresholdPercentage {
            print("Cumulative threshold \(cumulativeThreshold) less than threshold \(thresholdPercentage)")
            print("Index less than flattened \(currentIndex + 1) <= flattenedBins.count)")
            if (currentIndex + 1) <= flattenedBins.count {
                var j:Int = 1
                var lastBin = flattenedBins[currentIndex + 1]
                while cumulativeThreshold <= thresholdPercentage && (currentIndex + j) < flattenedBins.count  {
                    lastBin = flattenedBins[currentIndex + j]
                    cumulativeThreshold += lastBin.percentage/100
                    cumulativeWeight += lastBin.weight
                    j += 1
                    print("New cumulative \(cumulativeThreshold) at \(currentIndex + j)")
                }
                finalBins.append(Bin(min: flattenedBins[currentIndex].min, max: lastBin.max, weight: cumulativeWeight, percentage: cumulativeThreshold*100))
                print("Added final bin")
                currentIndex += j
                if currentIndex >= flattenedBins.count {
                    currentIndex = flattenedBins.count
                }
            } else {
                print("Trailing bin \(flattenedBins[currentIndex])")
                // Trailing bin, just append
                finalBins.append(flattenedBins[currentIndex])
            }
        } else {
            // threshold is greater but the bin has floating point marginal overshot
            if currentIndex <= flattenedBins.count {
                finalBins.append(flattenedBins[currentIndex])
                currentIndex += 1
            }
        }
    }
    print("Final bins count: \(finalBins.count)")
    return finalBins
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
    guard let _ = group.first else {
        return Bin(min: 0, max: 0, weight: 0, percentage: 0)
    }

    let minVal = group.map { $0.min }.min()!
    let maxVal = group.map { $0.max }.max()!
    let totalWeight = group.map { $0.weight }.reduce(0, +)

    let merged = Bin(
        min: minVal,
        max: maxVal,
        weight: totalWeight,
        percentage: totalWeight * 100
    )

    return merged
}

