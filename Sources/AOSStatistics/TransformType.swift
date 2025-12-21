//
//  TransformType.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 21/12/2025.
//


public enum TransformType {

    // Mark: Constant across all
    case constant(constantVal: Float = 1)
    
    // MARK: Basic
    case sqrt
    case cbrt

    case log(offset: Float = 500)
    case log10(offset: Float = 500)

    case asinh(scale: Float = 500)

    case quantile

    case winsorized(percentile: Float = 0.99)
    case winsorizedSqrt(percentile: Float = 0.99)

    case saturation(k: Float = 3000)
    case logistic(mean: Float = 3000, scale: Float = 1000)

    // MARK: Upgrades
    case normalize               // min–max normalize to 0–1
    case inverse                 // inverse of previous transform (when supported)
    case custom((Float) -> Float)
}
