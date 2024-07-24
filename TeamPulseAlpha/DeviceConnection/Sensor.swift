//
//  Sensor.swift.swift
//  TeamPulseAlpha
//
//  Created by blackstar on 24/07/2024.
//

import Foundation

struct Sensor: Identifiable {
    let id: UUID
    let macAddress: String
    var isConnected: Bool = false
}
