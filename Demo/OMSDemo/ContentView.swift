//
//  ContentView.swift
//  OMSDemo
//
//  Created by Takuto Nakamura on 2024/03/02.
//

import OpenMultitouchSupport
import SwiftUI

struct ContentView: View {
	@StateObject var viewModel = ContentViewModel()

	var body: some View {
		VStack {
			if viewModel.isListening {
				Button {
					viewModel.stop()
				} label: {
					Text("Stop")
				}
			} else {
				Button {
					viewModel.start()
				} label: {
					Text("Start")
				}
			}

			Canvas { context, size in
				viewModel.touchData.forEach { touch in
					let path = makeEllipse(touch: touch, size: size)
					let color: Color = .primary.opacity(Double(touch.total))
					context.fill(path, with: .color(color))
				}
			}
			.frame(width: 600, height: 400)
			.border(Color.primary)
		}
		.fixedSize()
		.padding()
		.onAppear {
			viewModel.onAppear()
		}
		.onDisappear {
			viewModel.onDisappear()
		}
	}

	private func makeEllipse(touch: OMSTouchData, size: CGSize) -> Path {
		let x = Double(touch.position.x) * size.width
		let y = Double(1.0 - touch.position.y) * size.height
		let u = size.width * 0.01
		let w = Double(touch.majorAxis) * u
		let h = Double(touch.minorAxis) * u
		let rect = CGRect(
			x: -0.5 * w, y: -0.5 * h,
			width: w, height: h
		)
		let rotation: Angle = .radians(Double(-touch.angle))

		return Path(ellipseIn: rect)
			.rotation(rotation, anchor: .topLeading)
			.offset(x: x, y: y)
			.path(in: CGRect(origin: .zero, size: size))
	}
}

#Preview {
	ContentView()
}
