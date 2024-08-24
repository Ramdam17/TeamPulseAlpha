//
//  MatrixDataEvent+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/24/24.
//
//

import Foundation
import CoreData


extension MatrixDataEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatrixDataEvent> {
        return NSFetchRequest<MatrixDataEvent>(entityName: "MatrixDataEvent")
    }

    @NSManaged public var conditionalEntropyMatrix: Data?
    @NSManaged public var correlationMatrix: Data?
    @NSManaged public var crossEntropyMatrix: Data?
    @NSManaged public var mutualInformationMatrix: Data?
    @NSManaged public var proximityMatrix: Data?
    @NSManaged public var timestamp: Date?
    @NSManaged public var session: SessionEntity?

}

extension MatrixDataEvent : Identifiable {

}
