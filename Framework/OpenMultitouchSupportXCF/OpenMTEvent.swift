//
//  OpenMTEvent.swift
//  OpenMultitouchSupportXCF
//
//  Created by RyanBoyer on 3/31/25.
//

import Foundation

public struct OpenMTEvent {
	public let touches: [OpenMTTouch]
	public let deviceID: Int
	public let frameID: Int32
	public let timestamp: Date

	init(
		touches: [OpenMTTouch],
		deviceID: Int,
		frameID: Int32,
		timestamp: Date
	) {
		self.touches = touches
		self.deviceID = deviceID
		self.frameID = frameID
		self.timestamp = timestamp
	}
}

// MARK: - Sendable

extension OpenMTEvent: Sendable { }

// MARK: - CustomStringConvertible

extension OpenMTEvent: CustomStringConvertible {
	public var description: String {
		"""
		Touches: \(String(describing: touches))
		Device ID: \(deviceID)
		Frame ID: \(frameID)
		Timestamp: \(timestamp)
		"""
	}
}
