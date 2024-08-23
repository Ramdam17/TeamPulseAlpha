//
//  CustomTransformers.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Foundation

/// A custom value transformer class designed to transform and reverse-transform various data structures,
/// such as arrays and matrices, into data suitable for storage in Core Data.
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

    /// Transforms an array of `Double` values into `Data` for storage.
    /// - Parameter value: The value to transform, expected to be an array of `Double`.
    /// - Returns: A `Data` object representing the array, or `nil` if the input is invalid.
    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [Double] else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true)
    }

    /// Reverses the transformation of `Data` back into an array of `Double` values.
    /// - Parameter value: The value to reverse transform, expected to be `Data`.
    /// - Returns: An array of `Double` values, or `nil` if the transformation fails.
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Double]
    }

    /// Transforms a 2D array (matrix) of `Double` values into `Data` for storage.
    /// - Parameter matrix: The matrix to transform.
    /// - Returns: A `Data` object representing the matrix, or `nil` if the transformation fails.
    func transformMatrixToData(_ matrix: [[Double]]) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: matrix, requiringSecureCoding: true)
    }

    /// Reverses the transformation of `Data` back into a 2D array (matrix) of `Double` values.
    /// - Parameter data: The `Data` to reverse transform.
    /// - Returns: A 2D array of `Double` values, or `nil` if the transformation fails.
    func reverseTransformDataToMatrix(_ data: Data) -> [[Double]]? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [[Double]]
    }

    /// Transforms a dictionary representing a cluster state into `Data` for storage.
    /// - Parameter clusterState: The cluster state to transform.
    /// - Returns: A `Data` object representing the cluster state, or `nil` if the transformation fails.
    func transformClusterStateToData(_ clusterState: [UUID: (isActive: Bool, activeCount: Int)]) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: clusterState, requiringSecureCoding: true)
    }

    /// Reverses the transformation of `Data` back into a dictionary representing a cluster state.
    /// - Parameter data: The `Data` to reverse transform.
    /// - Returns: A dictionary representing the cluster state, or `nil` if the transformation fails.
    func reverseTransformDataToClusterState(_ data: Data) -> [UUID: (isActive: Bool, activeCount: Int)]? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: data) as? [UUID: (isActive: Bool, activeCount: Int)]
    }

    /// Transforms an array of UUID arrays (for clusters) into `Data` for storage.
    /// - Parameter clusterArray: The array of UUID arrays to transform.
    /// - Returns: A `Data` object representing the cluster array, or `nil` if the transformation fails.
    func transformClusterArrayToData(_ clusterArray: [[UUID]]) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: clusterArray, requiringSecureCoding: true)
    }

    /// Reverses the transformation of `Data` back into an array of UUID arrays.
    /// - Parameter data: The `Data` to reverse transform.
    /// - Returns: An array of UUID arrays, or `nil` if the transformation fails.
    func reverseTransformDataToClusterArray(_ data: Data) -> [[UUID]]? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [[UUID]]
    }
}
