//
//  CustomTransformers.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/19/24.
//

import Foundation

/// `ArrayTransformer` is a custom `ValueTransformer` subclass used to transform arrays of `Double` into `Data` for storage in Core Data, and to reverse that transformation back into arrays.
///
/// This is necessary for storing non-standard data types (like arrays) in Core Data's binary data fields.
@objc(ArrayTransformer)
class ArrayTransformer: ValueTransformer {
    
    /// Specifies the type of value that this transformer converts to.
    override class func transformedValueClass() -> AnyClass {
        return NSData.self // The transformed value will be of type `NSData`.
    }

    /// Indicates that this transformer allows reverse transformations.
    override class func allowsReverseTransformation() -> Bool {
        return true // This transformer supports both forward and reverse transformations.
    }

    /// Transforms an array of `Double` into `Data` for storage.
    ///
    /// - Parameter value: The value to be transformed, expected to be an array of `Double`.
    /// - Returns: The transformed value as `Data`, or `nil` if the transformation fails.
    override func transformedValue(_ value: Any?) -> Any? {
        // Ensure the value is of type `[Double]`.
        guard let array = value as? [Double] else { return nil }
        // Archive the array into `Data` using `NSKeyedArchiver`.
        return try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: false)
    }

    /// Reverses the transformation, converting `Data` back into an array of `Double`.
    ///
    /// - Parameter value: The value to be reverse transformed, expected to be of type `Data`.
    /// - Returns: The reverse transformed value as an array of `Double`, or `nil` if the transformation fails.
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        // Ensure the value is of type `Data`.
        guard let data = value as? Data else { return nil }
        // Unarchive the data back into an array of `Double` using `NSKeyedUnarchiver`.
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Double]
    }
}
