//
//  AddGroceryCategoryScreen.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/28/24.
//

import GroceryDTOs
import OSLog
import SwiftUI

struct AddGroceryCategoryScreen: View {
	// MARK: Computed Properties

	var body: some View {
		Form {
			TextField("Title", text: $title)
			ColorSelector(color: $color)
		}
		.navigationTitle("New Category")
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Close", systemImage: "multiply", action: dismiss.callAsFunction)
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button("Save", systemImage: "square.and.arrow.down", action: saveGroceryCategory)
					.disabled(!formIsValid)
			}
		}
	}

	// MARK: Private Stored Properties

	private static let log = Logger(
		subsystem: String(describing: Self.self), category: ""
	)

	@Environment(\.dismiss)         private var dismiss
	@Environment(GroceryModel.self) private var model

	@State private var title = ""
	@State private var color = ColorSelector.Colors.green.rawValue

	// MARK: - Private Computed Properties

	private var formIsValid: Bool {
		!title.isEmpty(trimming: .whitespacesAndNewlines)
	}

	// MARK: - Private Functions

	private func saveGroceryCategory() {
		Task {
			defer { dismiss() }
			let groceryCategoryRequestDTO = GroceryCategoryRequestDTO(
				title: title.trimming(.whitespacesAndNewlines),
				color: color
			)
			do {
				try await model.saveGroceryCategory(groceryCategoryRequestDTO: groceryCategoryRequestDTO)
			} catch {
				Self.log.error("\(error.localizedDescription)")
			}
		}
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var model = GroceryModel()

	NavigationStack {
		AddGroceryCategoryScreen()
			.environment(model)
	}
}
