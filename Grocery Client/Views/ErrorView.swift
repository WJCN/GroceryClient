//
//  ErrorView.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import SwiftUI

struct ErrorView: View {
	// MARK: Stored Properties

	let errorWrapper: ErrorWrapper

	// MARK: - Computed Properties

	var body: some View {
		VStack(spacing: 20) {
			Text("An error has occurred in the application.")
				.font(.headline)
			VStack(spacing: 10) {
				Text(errorWrapper.error.localizedDescription)
				if let guidance = errorWrapper.guidance {
					Text(guidance)
						.font(.caption)
				}
			}
		}
	}
}

// MARK: - Preview

#Preview {
	ErrorView(
		errorWrapper: ErrorWrapper(
			error: URLError(.badURL),
			guidance: "Error Guidance"
		)
	)
}
