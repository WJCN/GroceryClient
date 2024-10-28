//
//  AddGroceryItemScreen.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import GroceryDTOs
import OSLog
import SwiftUI

struct AddGroceryItemScreen: View {
	// MARK: Computed Properties

	var body: some View {
		Form {
			TextField("Title", text:  $title)
			TextField("Price", value: $price,
					  format: .currency(code: Locale.current.currencySymbol ?? ""))
			TextField("Quantity", value: $quantity, format: .number)
		}
		.navigationTitle("New Grocery Item")
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Close", systemImage: "multiply", action: dismiss.callAsFunction)
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button("Save", systemImage: "square.and.arrow.down", action: saveGroceryItem)
					.disabled(!formIsValid)
			}
		}
	}

	// MARK: - Private Stored Properties

	private static let log = Logger(
		subsystem: String(describing: Self.self), category: ""
	)

	@Environment(\.dismiss)         private var dismiss
	@Environment(GroceryModel.self) private var model

	@State private var title:    String = ""
	@State private var price:    Double?
	@State private var quantity: Int?

	// MARK: - Private Computed Properties

	private var formIsValid: Bool {
		guard let price, let quantity else { return false }
		return !title.isEmpty(trimming: .whitespacesAndNewlines)
		&& price > 0 && quantity > 0
	}

	// MARK: - Private Functions

	private func saveGroceryItem() {
		Task {
			defer { dismiss() }
			do {
				guard let price,
					  let quantity,
					  let groceryCategory = model.groceryCategory
				else { return }
				let groceryItemRequestDTO = GroceryItemRequestDTO(
					title:    title,
					price:    price,
					quantity: quantity
				)
				try await model.saveGroceryItem(
					groceryItemRequestDTO: groceryItemRequestDTO,
					groceryCategoryID:     groceryCategory.id
				)
			} catch {
				Self.log.error("\(error)")
			}
		}
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var model = GroceryModel()

	NavigationStack {
		AddGroceryItemScreen()
			.environment(model)
	}
}
