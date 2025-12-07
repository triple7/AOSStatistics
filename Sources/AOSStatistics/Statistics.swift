//
//  Statistics.swift
//  AOSTests
//
//  Created by Yuma decaux on 19/5/2025.
//


import Foundation
import GameplayKit

public struct Bin:Equatable {
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

    print("total values: \(values.count)")
    while !belowThreshold {
        print("Reiterating histograms")
        for bin in histBins {
            if bin.percentage > maxBinPercentage {
                maxBinPercentage = bin.percentage
                maxBin = bin
                maxValue = bin.max
            }
        }
        
        print("MaxBin: min \(maxBin.min) max \(maxBin.max) percentage \(maxBinPercentage)")
        if maxBinPercentage > thresholdPercentage {
            print("MaxBin percentage > threshold")
            // Collate the smaller percentages
            for bin in histBins {
                if bin != maxBin {
                    flattenedBins.append(bin)
                }
            }
            
            print("Added \(flattenedBins.count) bins")
            // Continue with a new histogram
            let maxbinValues = values.filter{$0 < maxValue}
            
            let newMin = maxbinValues.min()!
            let newMax = maxbinValues.max()!
            print("New values under maxValue: \(maxbinValues.count) min \(newMin) max \(newMax)")

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
            print("Reached below threshold: \(maxBinPercentage)")
            belowThreshold = true
            continue
        }
    }
    
    // Recalculate bin ranges
    print("Recalculating bin ranges")
    var finalBins = [Bin]()
    print("Flattened bin count: \(flattenedBins.count)")
    var cumulativeBin:Bin
    var currentIndex = 0
    while currentIndex <= flattenedBins.count {
        cumulativeBin = flattenedBins[currentIndex]
        var cumulativeThreshold = cumulativeBin.percentage
        var cumulativeWeight = cumulativeBin.weight
        if cumulativeThreshold <= thresholdPercentage {
            print("Cumulative threshold \(cumulativeThreshold) less than threshold")
            if (currentIndex + 1) <= flattenedBins.count {
                var j:Int = 1
                var lastBin:Bin
                while cumulativeThreshold <= thresholdPercentage && (currentIndex + j) <= flattenedBins.count  {
                    cumulativeThreshold += flattenedBins[j].percentage
                    cumulativeWeight += flattenedBins[j].weight
                    j += 1
                    print("New cumulative \(cumulativeThreshold)")
                }
                lastBin = flattenedBins[currentIndex + j]
                finalBins.append(Bin(min: flattenedBins[currentIndex].min, max: lastBin.max, weight: cumulativeWeight, percentage: cumulativeThreshold))
                currentIndex += j
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

