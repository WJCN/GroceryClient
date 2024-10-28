//
//  GroceryCategoryDetailScreen.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import GroceryDTOs
import OSLog
import SwiftUI

struct GroceryCategoryDetailScreen: View {
	// MARK: Stored Properties

	let groceryCategory: GroceryCategoryResponseDTO

	// MARK: - Computed Properties

	var body: some View {
		Group {
			GroceryItemsListView(
				groceryItems: model.groceryItems,
				onDelete:     deleteGroceryItems
			)
		}
		.navigationTitle(groceryCategory.title)
		.onAppear    { model.groceryCategory = groceryCategory }
		.onDisappear { model.groceryCategory = nil }
		.task(getGroceryItems)
		.sheet(isPresented: $isPresented) {
			NavigationStack {
				AddGroceryItemScreen()
			}
		}
		.toolbar {
			ToolbarItem {
				Button("Add Grocery Item", systemImage: "plus") { isPresented.toggle() }
			}
		}
	}

	// MARK: - Private Stored Properties

	private static let log = Logger(
		subsystem: String(describing: Self.self), category: ""
	)

	@Environment(GroceryModel.self) private var model

	@State private var isPresented: Bool = false

	// MARK: - Private Functions

	private func deleteGroceryItems(indices: IndexSet) {
		Task {
			do {
				let offsets = try await withThrowingTaskGroup(of: Int.self) { group -> IndexSet in
					for index in indices {
						group.addTask {
							try await model.deleteGroceryItem(
								groceryCategoryID: groceryCategory.id,
								groceryItemID:     model.groceryItems[index].id,
								deleteFromModel:   false
							)
							return index
						}
					}
					var offsets = IndexSet()
					for try await index in group {
						offsets.insert(index)
					}
					return offsets
				}
				model.groceryItems.remove(atOffsets: offsets)
			} catch {
				Self.log.error("\(error.localizedDescription)")
			}
		}
	}

	private func getGroceryItems() async {
		do {
			model.groceryItems.removeAll(keepingCapacity: true)
			try await model.getGroceryItems(groceryCategoryID: groceryCategory.id)
		} catch {
			Self.log.error("\(error.localizedDescription)")
		}
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var model = GroceryModel()

	NavigationStack {
		GroceryCategoryDetailScreen(
			groceryCategory: GroceryCategoryResponseDTO(
				id: UUID(uuidString: "21fc465f-0a6a-4feb-af27-f13544804d2a")!,
				title: "Seafood",
				color: "#FF3498DB"
			)
		)
		.environment(model)
	}
}
