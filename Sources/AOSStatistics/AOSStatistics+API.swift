//
//  Untitled.swift
//  AOSStatistics
//
//  Created by Yuma decaux on 21/12/2025.
//

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

