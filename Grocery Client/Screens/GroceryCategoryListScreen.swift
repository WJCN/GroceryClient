//
//  GroceryCategoryListScreen.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/28/24.
//

import GroceryDTOs
import OSLog
import SwiftUI

struct GroceryCategoryListScreen: View {
	// MARK: Computed Properties

	var body: some View {
		Group {
			if model.groceryCategories.isEmpty {
				ContentUnavailableView(
					"No Categories",
					systemImage: "list.dash",
					description: Text("Tap the \(Image(systemName: "plus")) button above to add a category.")
				)
			} else {
				List {
					ForEach(model.groceryCategories) { groceryCategory in
						NavigationLink(value: Route.groceryCategoryDetail(groceryCategory)) {
							HStack {
								Circle()
									.fill(Color(fromHexadecimal: groceryCategory.color).gradient)
									.frame(width: 25, height: 25)
								Text(groceryCategory.title)
							}
						}
					}
					.onDelete(perform: deleteGroceryCategories)
				}
			}
		}
		.navigationTitle("Categories")
		.navigationBarBackButtonHidden()
		.task(getGroceryCategories)
		.sheet(isPresented: $isPresented) {
			NavigationStack {
				AddGroceryCategoryScreen()
			}
		}
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button("Sign Out", /* systemImage: "arrowshape.turn.up.left", */ action: signOut)
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button("Add Grocery Category", systemImage: "plus") { isPresented.toggle() }
			}
		}
	}

	// MARK: - Private Stored Properties

	private static let log = Logger(subsystem: String(describing: Self.self),
									category: "")

	@Environment(GroceryModel.self) private var model
	@Environment(AppState    .self) private var state

	@State private var isPresented: Bool = false

	// MARK: - Private Functions

	private func deleteGroceryCategories(indices: IndexSet) {
		Task {
			do {
				let offsets = try await withThrowingTaskGroup(of: Int.self) { group -> IndexSet in
					for index in indices {
						group.addTask {
							try await model.deleteGroceryCategory(
								groceryCategoryID: model.groceryCategories[index].id,
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
				model.groceryCategories.remove(atOffsets: offsets)
			} catch {
				Self.log.error("\(error.localizedDescription)")
			}
		}
	}

	private func getGroceryCategories() async {
		do {
			try await model.getGroceryCategories()
		} catch {
			Self.log.error("\(error.localizedDescription)")
		}
	}

	private func signOut() {
		model.signOut()
		_ = state.routes.popLast()
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var model = GroceryModel()
	@Previewable @State var state = AppState()

	NavigationStack {
		GroceryCategoryListScreen()
			.environment(model)
			.environment(state)
	}
}
