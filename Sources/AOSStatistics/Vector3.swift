//
//  Vector3.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 22/3/2026.
//


import SceneKit
import Accelerate

struct Vector3 {
    var x: Double, y: Double, z: Double
    var scnVector: SCNVector3 { SCNVector3(x, y, z) }
    
    func distance(to other: Vector3) -> Double {
        return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2) + pow(z - other.z, 2))
    }
}

func parsePointCloud(_ data: [Double]) -> [Vector3] {
    var points = [Vector3]()
    for i in stride(from: 0, to: data.count, by: 3) where i + 2 < data.count {
        points.append(Vector3(x: data[i], y: data[i+1], z: data[i+2]))
    }
    return points
}