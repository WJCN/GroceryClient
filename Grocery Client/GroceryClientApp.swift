//
//  GroceryClientApp.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import SwiftUI

@main
struct GroceryClientApp: App {
	// MARK: Computed Properties

	var body: some Scene {
		WindowGroup {
			NavigationStack(path: $state.routes) {
				RegistrationScreen()
					.onAppear(perform: checkSignedIn)
					.navigationDestination(for: Route.self) { route in
						switch route {
							case .register:
								RegistrationScreen()
							case .signIn:
								SignInScreen()
							case .groceryCategoryList:
								GroceryCategoryListScreen()
							case .groceryCategoryDetail(let groceryCategory):
								GroceryCategoryDetailScreen(groceryCategory: groceryCategory)
						}
					}
			}
			.environment(model)
			.environment(state)
		}
	}

	// MARK: - Private Stored Properties

	@State private var model = GroceryModel()
	@State private var state = AppState()

	// MARK: - Private Functions

	private func checkSignedIn() {
		if UserDefaults.standard.token != nil {
			state.routes += [.signIn, .groceryCategoryList]
		}
	}
}
