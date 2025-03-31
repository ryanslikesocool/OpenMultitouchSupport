//
//  OpenMTState.swift
//  OpenMultitouchSupportXCF
//
//  Created by RyanBoyer on 3/31/25.
//

public enum OpenMTState: UInt {
	case notTouching
	case starting
	case hovering
	case making
	case touching
	case breaking
	case lingering
	case leaving
}

// MARK: - Sendable

extension OpenMTState: Sendable { }

// MARK: - Equatable

extension OpenMTState: Equatable { }

// MARK: - Hashable

extension OpenMTState: Hashable { }

// MARK: - Convenience

extension OpenMTState {
	init?(_ state: MTTouchState) {
		switch Int(state) {
			case MTTouchStateNotTracking: 	self = .notTouching
			case MTTouchStateStartInRange: 	self = .starting
			case MTTouchStateHoverInRange: 	self = .hovering
			case MTTouchStateMakeTouch: 	self = .making
			case MTTouchStateTouching: 		self = .touching
			case MTTouchStateBreakTouch: 	self = .breaking
			case MTTouchStateLingerInRange: self = .lingering
			case MTTouchStateOutOfRange: 	self = .leaving
			default: 						return nil
		}
	}
}
