//
//  CustomTransformers.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Foundation

@objc(ArrayTransformer)
class ArrayTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    // General transformation method for an array of doubles
    override func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [Double] else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: false)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Double]
    }
    
    // Method to transform a matrix (2D array of doubles) to data
    func transformMatrixToData(_ matrix: [[Double]]) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: matrix, requiringSecureCoding: false)
    }

    // Method to transform data back into a matrix (2D array of doubles)
    func reverseTransformDataToMatrix(_ data: Data) -> [[Double]]? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [[Double]]
    }

    // Method to transform a cluster state dictionary to data
    func transformClusterStateToData(_ clusterState: [UUID: (isActive: Bool, activeCount: Int)]) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: clusterState, requiringSecureCoding: false)
    }

    // Method to transform data back into a cluster state dictionary
    func reverseTransformDataToClusterState(_ data: Data) -> [UUID: (isActive: Bool, activeCount: Int)]? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: data) as? [UUID: (isActive: Bool, activeCount: Int)]
    }
    
    // Method to transform an array of UUID arrays (for clusters) to data
    func transformClusterArrayToData(_ clusterArray: [[UUID]]) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: clusterArray, requiringSecureCoding: false)
    }

    // Method to transform data back into an array of UUID arrays
    func reverseTransformDataToClusterArray(_ data: Data) -> [[UUID]]? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [[UUID]]
    }
}
