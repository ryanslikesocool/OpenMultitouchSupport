//
//  OpenMTListener.swift
//  OpenMultitouchSupportXCF
//
//  Created by RyanBoyer on 3/31/25.
//

import Foundation

public final class OpenMTListener {
	public var listening: Bool
	public var callback: ((borrowing OpenMTEvent) -> Void)?

	internal init(callback: @escaping (borrowing OpenMTEvent) -> Void) {
		listening = true
		self.callback = callback
	}

	internal func listenToEvent(_ event: borrowing OpenMTEvent) {
		guard
			let callback,
			listening
		else {
			return
		}

		callback(event)
	}
}
