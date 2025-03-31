//
//  ContentViewModel.swift
//  OMSDemo
//
//  Created by Takuto Nakamura on 2024/03/02.
//

import OpenMultitouchSupport
import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
	private let manager: OMSManager
	private var task: Task<Void, Never>?

	@Published fileprivate(set) var touchData: [OMSTouchData]
	@Published fileprivate(set) var isListening: Bool

	init() {
		manager = OMSManager.shared
		task = nil

		touchData = []
		isListening = false
	}

	func onAppear() {
		task = Task { [weak self, manager] in
			for await touchData in manager.touchDataStream {
				Task { @MainActor in
					self?.touchData = touchData
				}
			}
		}
	}

	func onDisappear() {
		task?.cancel()
		stop()
	}

	func start() {
		if manager.startListening() {
			isListening = true
		}
	}

	func stop() {
		if manager.stopListening() {
			isListening = false
			touchData.removeAll()
		}
	}
}
