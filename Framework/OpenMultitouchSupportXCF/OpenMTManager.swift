//
//  OpenMTManager.swift
//  OpenMultitouchSupportXCF
//
//  Created by RyanBoyer on 3/31/25.
//

import AppKit
import Foundation
import OSLog

@MainActor
public final class OpenMTManager {
	public static var systemSupportsMultitouch: Bool { MTDeviceIsAvailable() }
	public static let shared: OpenMTManager = OpenMTManager()

	private nonisolated static let logger: Logger = Logger(subsystem: "com.kyome.OpenMultitouchSupportXCF", category: "OpenMTManager")

	private var listeners: [OpenMTListener]
	private var device: MTDeviceRef?

	private init() {
		listeners = []

		NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: nil, using: willSleep(_:))
		NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: nil, using: didWake(_:))
	}

	private func makeDevice() {
		guard MTDeviceIsAvailable() else {
			return
		}

		let device = MTDeviceCreateDefault()
		self.device = device

		var guid: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		if MTDeviceGetGUID(device, &guid) == .zero {
			let uuid: UUID = UUID(uuid: guid)
			Self.logger.debug("GUID: \(uuid)")
		}

		var type: Int32 = .zero
		if MTDeviceGetDriverType(device, &type) == .zero {
			Self.logger.debug("Driver Type: \(type)")
		}

		var deviceID: UInt64 = .zero
		if MTDeviceGetDeviceID(device, &deviceID) == .zero {
			Self.logger.debug("DeviceID: \(deviceID)")
		}

		var familyID: Int32 = .zero
		if MTDeviceGetFamilyID(device, &familyID) == .zero {
			Self.logger.debug("FamilyID: \(familyID)")
		}

		var width: Int32 = .zero
		var height: Int32 = .zero
		if MTDeviceGetSensorSurfaceDimensions(device, &width, &height) == .zero {
			Self.logger.debug("Surface Dimensions: \(width) x \(height)")
		}

		var rows: Int32 = .zero
		var cols: Int32 = .zero
		if MTDeviceGetSensorDimensions(device, &rows, &cols) == .zero {
			Self.logger.debug("Dimensions: \(rows) x \(cols)")
		}

		let isOpaque: Bool = MTDeviceIsOpaqueSurface(device);
		Self.logger.debug("Opaque: \(isOpaque)")
	}

	fileprivate func handleMultitouchEvent(_ event: sending OpenMTEvent) {
		for listener in listeners {
			guard listener.callback != nil else {
				removeListener(listener)
				continue
			}
			guard listener.listening else {
				continue
			}

			listener.listenToEvent(event)
		}
	}

	private func startHandlingMultitouchEvents() {
		self.makeDevice()

		// We can't catch Objective-C exceptions in Swift...
//		do {
			MTRegisterContactFrameCallback(device, contactEventHandler) // work
			// MTEasyInstallPrintCallbacks(device, true, false, false, false, false, false) // work
			// MTRegisterPathCallback(device, pathEventHandler) // work
			// MTRegisterMultitouchImageCallback(device, MTImagePrintCallback) // not work
			MTDeviceStart(device, 0)
//		} catch {
//			Self.logger.debug("Failed Start Handling Multitouch Events")
//		}
	}

	private func stopHandlingMultitouchEvents() {
		guard MTDeviceIsRunning(self.device) else {
			return
		}

		// We can't catch Objective-C exceptions in Swift...
//		do {
			MTUnregisterContactFrameCallback(device, contactEventHandler) // work
			// MTUnregisterPathCallback(device, pathEventHandler) // work
			// MTUnregisterImageCallback(device, MTImagePrintCallback) // not work
			MTDeviceStop(device)
			MTDeviceRelease(device)
//		} catch {
//			Self.logger.debug("Failed Stop Handling Multitouch Events")
//		}
	}

	private nonisolated func willSleep(_ notification: Notification) {
		Task { @MainActor in
			stopHandlingMultitouchEvents()
		}
	}

	private nonisolated func didWake(_ notification: Notification) {
		Task { @MainActor in
			startHandlingMultitouchEvents()
		}
	}

	public func addListener(_ callback: @escaping (borrowing OpenMTEvent) -> Void) -> OpenMTListener? {
		guard Self.systemSupportsMultitouch else {
			return nil
		}
		if (listeners.isEmpty) {
			startHandlingMultitouchEvents()
		}
		let listener = OpenMTListener(callback: callback)
		listeners.append(listener)
		return listener;
	}

	public func removeListener(_ listener: OpenMTListener) {
		listeners.removeAll { element in element === listener }
		if (listeners.isEmpty) {
			stopHandlingMultitouchEvents()
		}
	}

}

private func contactEventHandler(
	_ eventDevice: MTDeviceRef?,
	_ eventTouches: UnsafeMutablePointer<MTTouch>?,
	_ numTouches: Int32,
	_ timestamp: TimeInterval,
	_ frame: Int32
) {
	let touches: [OpenMTTouch] = if let eventTouches {
		(0 ..< Int(numTouches)).map { i in
			let eventTouch = eventTouches[i]
			return OpenMTTouch(with: eventTouch)
		}
	} else {
		[]
	}

	let deviceID = Int(bitPattern: eventDevice)
	let timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
	let event: OpenMTEvent = OpenMTEvent(
		touches: touches,
		deviceID: deviceID,
		frameID: frame,
		timestamp: timestamp
	)

	Task { @MainActor in
		OpenMTManager.shared.handleMultitouchEvent(event)
	}
}
