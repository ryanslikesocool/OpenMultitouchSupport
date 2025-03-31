/*
 OMSManager.swift

 Created by Takuto Nakamura on 2024/03/02.
*/

@preconcurrency import Combine
import OpenMultitouchSupportXCF
import os

@MainActor
public final class OMSManager {
	public static let shared: OMSManager = OMSManager()

	private let protectedManager: OSAllocatedUnfairLock<OpenMTManager?>
	private let protectedListener = OSAllocatedUnfairLock<OpenMTListener?>(uncheckedState: nil)

	private let touchDataSubject = PassthroughSubject<[OMSTouchData], Never>()
	public var touchDataStream: AsyncStream<[OMSTouchData]> {
		AsyncStream { continuation in
			let cancellable = touchDataSubject.sink { value in
				continuation.yield(value)
			}
			continuation.onTermination = { _ in
				cancellable.cancel()
			}
		}
	}

	public var isListening: Bool {
		protectedListener.withLockUnchecked { $0 != nil }
	}

	private init() {
		protectedManager = OSAllocatedUnfairLock(uncheckedState: OpenMTManager.shared)
	}

	@discardableResult
	public func startListening() -> Bool {
		guard
			let xcfManager = protectedManager.withLockUnchecked(\.self),
			protectedListener.withLockUnchecked({ $0 == nil })
		else {
			return false
		}
		let listener = xcfManager.addListener(listen(_:))
		protectedListener.withLockUnchecked { $0 = listener }
		return true
	}

	@discardableResult
	public func stopListening() -> Bool {
		guard
			let xcfManager = protectedManager.withLockUnchecked(\.self),
			let listener = protectedListener.withLockUnchecked(\.self)
		else {
			return false
		}
		xcfManager.removeListener(listener)
		protectedListener.withLockUnchecked { $0 = nil }
		return true
	}

	func listen(_ event: OpenMTEvent) {
		touchDataSubject.send(event.touches)
	}
}
