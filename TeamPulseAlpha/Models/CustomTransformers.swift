//
//  CustomTransformers.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Foundation

/// A custom value transformer class designed to transform and reverse-transform various data structures,
/// such as 3x3 matrices and cluster state arrays, into data suitable for storage in Core Data.
@objc(ArrayTransformer)
class ArrayTransformer: ValueTransformer {

    /// Specifies that the transformed value class will be NSData.
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    /// Indicates that reverse transformations are supported by this transformer.
    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    // MARK: - Transformation Methods

    /// Transforms a 3x3 matrix (or a 9-element vector) of `Double` values into `Data` for storage.
    ///
    /// - Parameter matrix: The matrix to transform, expected to be a 3x3 array of `Double`.
    /// - Returns: A `Data` object representing the matrix, or `nil` if the input is invalid.
    func transformMatrixToData(_ matrix: [[Double]]) -> Data? {
        guard matrix.count == 3 && matrix.allSatisfy({ $0.count == 3 }) else {
            return nil  // Ensure the matrix is 3x3
        }
        
        let flattenedMatrix = matrix.flatMap { $0 }
        return try? NSKeyedArchiver.archivedData(withRootObject: flattenedMatrix, requiringSecureCoding: true)
    }

    /// Transforms a cluster state array of 6 `Double` values into `Data` for storage.
    ///
    /// - Parameter clusterState: The array of six `Double` values representing the cluster state.
    /// - Returns: A `Data` object representing the cluster state, or `nil` if the input is invalid.
    func transformClusterStateToData(_ clusterState: [Double]) -> Data? {
        guard clusterState.count == 6 else {
            return nil  // Ensure the cluster state array has exactly six elements
        }

        return try? NSKeyedArchiver.archivedData(withRootObject: clusterState, requiringSecureCoding: true)
    }

    // MARK: - Reverse Transformation Methods

    /// Reverses the transformation of `Data` back into a 3x3 matrix (or a 9-element vector) of `Double` values.
    ///
    /// - Parameter data: The `Data` to reverse transform.
    /// - Returns: A 3x3 array of `Double` values, or `nil` if the transformation fails.
    func reverseTransformDataToMatrix(_ data: Data) -> [[Double]]? {
        guard let flattenedMatrix = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Double],
              flattenedMatrix.count == 9 else {
            return nil  // Ensure we have a flattened array of 9 elements
        }

        return [
            Array(flattenedMatrix[0..<3]),
            Array(flattenedMatrix[3..<6]),
            Array(flattenedMatrix[6..<9])
        ]
    }

    /// Reverses the transformation of `Data` back into a cluster state array of six `Double` values.
    ///
    /// - Parameter data: The `Data` to reverse transform.
    /// - Returns: An array of six `Double` values representing the cluster state, or `nil` if the transformation fails.
    func reverseTransformDataToClusterState(_ data: Data) -> [Double]? {
        guard let clusterState = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Double],
              clusterState.count == 6 else {
            return nil  // Ensure the cluster state array has exactly six elements
        }

        return clusterState
    }

    // MARK: - Transformation Overrides

    /// Transforms a general value into `Data` for storage. Supports both 3x3 matrices and cluster state arrays.
    ///
    /// - Parameter value: The value to transform, expected to be either a 3x3 array of `Double` or an array of six `Double`.
    /// - Returns: A `Data` object representing the value, or `nil` if the transformation fails.
    override func transformedValue(_ value: Any?) -> Any? {
        if let matrix = value as? [[Double]] {
            return transformMatrixToData(matrix)
        } else if let clusterState = value as? [Double], clusterState.count == 6 {
            return transformClusterStateToData(clusterState)
        }

        return nil
    }

    /// Reverses the transformation of `Data` back into a general value. Supports both 3x3 matrices and cluster state arrays.
    ///
    /// - Parameter value: The value to reverse transform, expected to be `Data`.
    /// - Returns: The original value, which can be either a 3x3 array of `Double` or an array of six `Double`.
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }

        if let matrix = reverseTransformDataToMatrix(data) {
            return matrix
        } else if let clusterState = reverseTransformDataToClusterState(data) {
            return clusterState
        }

        return nil
    }
}
