//
//  OpenMTTouch.swift
//  OpenMultitouchSupportXCF
//
//  Created by RyanBoyer on 3/31/25.
//

import Foundation

public struct OpenMTTouch {
	public let identifier: Int32
	public let state: OpenMTState?
	public let position: SIMD2<Float>
	public let velocity: SIMD2<Float>
	public let total: Float
	public let pressure: Float
	public let minorAxis: Float
	public let majorAxis: Float
	public let angle: Float
	public let density: Float
	public let timestamp: Date

	init(with touch: borrowing MTTouch) {		
		self.identifier = touch.identifier
		self.state = OpenMTState(touch.state)
		self.position = SIMD2<Float>(
			touch.normalizedPosition.position.x,
			touch.normalizedPosition.position.y
		)
		self.velocity = SIMD2<Float>(
			touch.normalizedPosition.velocity.x,
			touch.normalizedPosition.velocity.y
		)
		self.total = touch.total
		self.pressure = touch.pressure
		self.minorAxis = touch.minorAxis
		self.majorAxis = touch.majorAxis
		self.angle = touch.angle
		self.density = touch.density
		self.timestamp = Date(timeIntervalSinceReferenceDate: touch.timestamp)
	}
}

// MARK: - Sendable

extension OpenMTTouch: Sendable { }

// MARK: - CustomStringConvertible

extension OpenMTTouch: CustomStringConvertible {
	public var description: String {
		"""
		ID: \(identifier),
		State: \(String(describing: state)),
		Position: \(position),
		Velocity: \(velocity),
		Total: \(total),
		Pressure: \(pressure),
		Minor: \(minorAxis),
		Major: \(majorAxis),
		Angle: \(angle),
		Density: \(density),
		Timestamp: \(timestamp),
		"""
	}
}