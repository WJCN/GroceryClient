//
//  GroceryItemListView.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import GroceryDTOs
import SwiftUI

struct GroceryItemsListView: View {
	// MARK: Stored Properties

	let groceryItems: [GroceryItemResponseDTO]
	var onDelete:     (IndexSet) -> Void

	// MARK: - Computed Properties

	var body: some View {
		Group {
			if groceryItems.isEmpty {
				ContentUnavailableView(
					"No Grocery Items",
					systemImage: "list.dash",
					description: Text("Tap the \(Image(systemName: "plus")) button above to add a grocery item.")
				)
			} else {
				List {
					ForEach(groceryItems) { groceryItem in
						Text(groceryItem.title)
					}
					.onDelete(perform: onDelete)
				}
			}
		}
	}
}

// MARK: - Preview

#Preview {
	GroceryItemsListView(groceryItems: []) { _ in }
}
