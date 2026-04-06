//
//  Untitled.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 21/12/2025.
//

import SceneKit

public func applyTransform<T: TransformNumeric>(
    transformType: TransformType,
    values: [T]
) -> [Float] {

    switch transformType {

    case .constant(let constantVal):
        return ConstantTransform(values, constant: T(constantVal)).map(Float.init)

    case .sqrt:
        return sqrtTransform(values).map(Float.init)

    case .cbrt:
        return cbrtTransform(values).map(Float.init)

    case .log(let offset):
        return logOffsetTransform(values, offset: T(offset)).map(Float.init)

    case .log10(let offset):
        return log10OffsetTransform(values, offset: T(offset)).map(Float.init)

    case .asinh(let scale):
        return asinhTransform(values, scale: T(scale)).map(Float.init)

    case .quantile:
        return quantileTransform(values).map(Float.init)

    case .winsorized(let p):
        return winsorizedTransform(values, percentile: T(p)).map(Float.init)

    case .winsorizedSqrt(let p):
        return winsorizedSqrtTransform(values, percentile: T(p)).map(Float.init)

    case .saturation(let k):
        return saturationTransform(values, k: T(k)).map(Float.init)

    case .logistic(let mean, let scale):
        return logisticTransform(values, mean: T(mean), scale: T(scale)).map(Float.init)

    case .normalize:
        return normalize(values.map(Float.init))

    case .custom(let fn):
        return values.map { fn(Float($0)) }

    case .inverse:
        fatalError("Inverse must be applied in a pipeline context")
    }
}

/* SOR algorithm
 Determines gaps using local delta for distances between points
 Using statistical Mu and SIGMA
 Best suited for: Non genus 0 topologies (Doughnuts)
 */
public func statisticalOutlierRemoval(points: [SCNVector3], k: Int, stdDevMult: Float) -> [SCNVector3] {
    guard let tree = buildKDTree(points: points) else { return [] }
    
    var avgDistances = [Float]()
    
    // 1. Calculate average distance to k-neighbors for every point
    for point in points {
        var heap: [(distance: Float, point: SCNVector3)] = []
        // k+1 because the search will always find the point itself at distance 0
        knnSearch(nodeSearch: tree, target: point, k: k + 1, heap: &heap)
        
        // Remove the point itself (dist 0) and calculate mean of neighbor distances
        let neighbors = heap.filter { $0.distance > 0 }
        let sumDist = neighbors.reduce(0) { $0 + sqrt($1.distance) }
        avgDistances.append(sumDist / Float(neighbors.count))
    }
    
    // 2. Calculate Global Mean and Standard Deviation
    let globalMean = avgDistances.reduce(0, +) / Float(avgDistances.count)
    let sumSq = avgDistances.reduce(0) { $0 + pow($1 - globalMean, 2) }
    let stdDev = sqrt(sumSq / Float(avgDistances.count))
    
    // 3. Filter points
    // Points with avgDist > threshold are outliers (tears/gaps)
    let threshold = globalMean + (stdDevMult * stdDev)
    
    var outliers = [SCNVector3]()
    for (index, dist) in avgDistances.enumerated() {
        if dist > threshold {
            outliers.append(points[index])
        }
    }
    
    return outliers
}

/* Creates a Centroid node with bounding boxes using Axis Aligned Bounding Box (AABB)
 Best suited for non convex hulls (density symmetry across angles)
 */
public func createLocalizationNode(points: [SCNVector3]) -> SCNNode? {
    guard !points.isEmpty else { return nil }
    
    // 1. Calculate Centroid
    let sumX = points.reduce(0) { $0 + $1.x }
    let sumY = points.reduce(0) { $0 + $1.y }
    let sumZ = points.reduce(0) { $0 + $1.z }
    let count = Float(points.count)
    let centroid = SCNVector3(sumX/count, sumY/count, sumZ/count)
    
    // 2. Calculate Bounds
    let minX = points.map { $0.x }.min() ?? 0
    let maxX = points.map { $0.x }.max() ?? 0
    let minY = points.map { $0.y }.min() ?? 0
    let maxY = points.map { $0.y }.max() ?? 0
    let minZ = points.map { $0.z }.min() ?? 0
    let maxZ = points.map { $0.z }.max() ?? 0
    
    // 3. Create Geometry
    let width = CGFloat(maxX - minX)
    let height = CGFloat(maxY - minY)
    let length = CGFloat(maxZ - minZ)
    
    let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
    box.firstMaterial?.diffuse.contents = UIColor.systemRed.withAlphaComponent(0.4)
    
    let node = SCNNode(geometry: box)
    node.position = centroid
    return node
}



/* Density Based Spatial clustering of Applications with Noise (DBSCAN)
 Best suited for: Interlacing tendrils of data:
 * crescent or concave shapes
 * Torii
 * Entangled shapes
 * tears in a shape
 * Blood vessels or neuros
 * cracks in a volume
 */
public func dbscanKDTree(points: [SCNVector3], eps: Float, minPts: Int) -> [[SCNVector3]] {
    guard let tree = buildKDTree(points: points) else { return [] }
    
    // 1. Create a fast lookup map (Point -> Index)
    var pointToIndex = [SCNVector3: Int]()
    for (index, pt) in points.enumerated() {
        pointToIndex[pt] = index
    }
    
    var visited = Set<Int>()
    var clusters = [[SCNVector3]]()
    let epsSquared = eps * eps
    
    for i in 0..<points.count {
        if visited.contains(i) { continue }
        visited.insert(i)
        
        var initialHeap: [(distance: Float, point: SCNVector3)] = []
        knnSearch(nodeSearch: tree, target: points[i], k: minPts + 10, heap: &initialHeap)
        let neighbors = initialHeap.filter { $0.distance <= epsSquared }
        
        if neighbors.count < minPts { continue }
        
        var currentCluster = [points[i]]
        var seedQueue = neighbors.map { $0.point }.filter { $0 != points[i] }
        
        var j = 0
        while j < seedQueue.count {
            let neighborPoint = seedQueue[j]
            
            // 2. Fast O(1) Lookup instead of firstIndex(where:)
            if let idx = pointToIndex[neighborPoint] {
                if !visited.contains(idx) {
                    visited.insert(idx)
                    
                    var secondaryHeap: [(distance: Float, point: SCNVector3)] = []
                    knnSearch(nodeSearch: tree, target: neighborPoint, k: minPts + 10, heap: &secondaryHeap)
                    let secondaryNeighbors = secondaryHeap.filter { $0.distance <= epsSquared }
                    
                    if secondaryNeighbors.count >= minPts {
                        for sn in secondaryNeighbors {
                            // Only add to queue if we haven't processed it
                            if let sIdx = pointToIndex[sn.point], !visited.contains(sIdx) {
                                seedQueue.append(sn.point)
                            }
                        }
                    }
                }
                currentCluster.append(neighborPoint)
            }
            j += 1
        }
        clusters.append(currentCluster)
    }
    return clusters
}

// Ensure SCNVector3 can be used as a Dictionary Key
extension SCNVector3: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

