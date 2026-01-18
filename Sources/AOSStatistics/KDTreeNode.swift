//
//  KDTreeNode.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 18/1/2026.
//

import SceneKit

public class KDTreeNode {
    var point: SCNVector3
    var left: KDTreeNode?
    var right: KDTreeNode?
    var axis: Int

    init(point: SCNVector3, axis: Int) {
        self.point = point
        self.axis = axis
    }
}


func buildKDTree(points: [SCNVector3], depth: Int = 0) -> KDTreeNode? {
    if points.isEmpty{ return nil }
    let axis = depth % 3
    let sorted = points.sorted {
        axis == 0 ? $0.x < $1.x :
        axis == 1 ? $0.y < $1.y :
                    $0.z < $1.z
    }
    let medianIndex = sorted.count / 2
    let medianPoint = sorted[medianIndex]

    let node = KDTreeNode(point: medianPoint, axis: axis)
    
    node.left = buildKDTree(points: Array(sorted[..<medianIndex]), depth: depth + 1)
    node.right = buildKDTree(points: Array(sorted[(medianIndex + 1)...]), depth: depth + 1)

    return node
}

func distanceSquared(_ a: SCNVector3, _ b: SCNVector3) -> Float {
    let dx = a.x - b.x, dy = a.y - b.y, dz = a.z - b.z
    let dx2 = dx*dx
    let dy2 = dy*dy
    let dz2 = dz*dz
    return Float(dx2 + dy2 + dz2)
}

public func knnSearch(nodeSearch: KDTreeNode?, target: SCNVector3, k: Int, heap: inout [(distance: Float, point: SCNVector3)]) {
    guard let node = nodeSearch else{
        return
    }
    
    let dist = distanceSquared(target, node.point)

    // Add to heap if there's space or if closer than the farthest
    if heap.count < k {
        heap.append((dist, node.point))
        heap.sort { $0.distance > $1.distance } // max-heap
    } else if dist < heap[0].distance {
        heap[0] = (dist, node.point)
        heap.sort { $0.distance > $1.distance }
    }

    let axis = node.axis
    let targetCoord: Float = axis == 0 ? Float(target.x) : axis == 1 ? Float(target.y) : Float(target.z)
    let nodeCoord: Float = axis == 0 ? Float(node.point.x) : axis == 1 ? Float(node.point.y) : Float(node.point.z)

    let next = targetCoord < nodeCoord ? node.left : node.right
    let other = targetCoord < nodeCoord ? node.right : node.left

    knnSearch(nodeSearch: next, target: target, k: k, heap: &heap)

    let axisDist = (targetCoord - nodeCoord) * (targetCoord - nodeCoord)
    if heap.count < k || axisDist < heap[0].distance {
        knnSearch(nodeSearch: other, target: target, k: k, heap: &heap)
    }
}

public func estimateDensity(points: [SCNVector3], k: Int) -> [Float] {
    let tree = buildKDTree(points: points)
    var densities: [Float] = []
    for point in points {
        var heap: [(distance: Float, point: SCNVector3)] = []
        knnSearch(nodeSearch: tree, target: point, k: k + 1, heap: &heap) // k+1 to skip self
        let avgDist = heap.dropFirst().map { sqrt($0.distance) }.reduce(0, +) / Float(k)
        densities.append(1.0 / (avgDist + 1e-5))
    }
    return densities
}

// TODO: generalise this in AOSUniverse instead
public func getSCN(path: URL) -> SCNScene {
    do {
        let scene = try SCNScene(url: path, options: nil)
        return scene
    } catch {
        print("Failed to load SCNScene from \(path): \(error)")
        return SCNScene()
    }
}

