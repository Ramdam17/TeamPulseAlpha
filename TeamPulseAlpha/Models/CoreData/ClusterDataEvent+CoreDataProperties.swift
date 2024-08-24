//
//  ClusterDataEvent+CoreDataProperties.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 8/24/24.
//
//

import Foundation
import CoreData


extension ClusterDataEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClusterDataEvent> {
        return NSFetchRequest<ClusterDataEvent>(entityName: "ClusterDataEvent")
    }

    @NSManaged public var clusterState: Data?
    @NSManaged public var timestamp: Date?
    @NSManaged public var session: SessionEntity?

}

extension ClusterDataEvent : Identifiable {

}
