//
//  SignInScreen.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/26/24.
//

import SwiftUI

struct SignInScreen: View {
	// MARK: Computed Properties

	var body: some View {
		Form {
			TextField("Username", text: $username)
				.autocorrectionDisabled(true)
				.textContentType(.username)
				.textInputAutocapitalization(.never)
			SecureField("Password", text: $password)
				.textContentType(.password)
			Button("Sign In", action: signIn)
				.buttonStyle(.borderless)
				.disabled(!formIsValid)
		}
		.navigationTitle("Sign In")
		.onAppear   (perform: resetForm)
		.onDisappear(perform: resetForm)
		.sheet(
			item: Binding(
				get: { state.errorWrapper      },
				set: { state.errorWrapper = $0 }
			)
		) { errorWrapper in
			ErrorView(errorWrapper: errorWrapper)
				.presentationDetents([.fraction(1/4)])
				.presentationDragIndicator(.visible)
		}
	}

	// MARK: - Private Stored Properties

	private let whitespace: CharacterSet = .whitespacesAndNewlines

	@Environment(GroceryModel.self) private var model
	@Environment(AppState    .self) private var state

	@State private var username: String = ""
	@State private var password: String = ""

	// MARK: - Private Computed Properties

	private var formIsValid: Bool {
		!username.isEmpty(trimming: whitespace) &&
		!password.isEmpty(trimming: whitespace)
	}

	// MARK: - Private Functions

	private func resetForm() {
		username.removeAll(keepingCapacity: true)
		password.removeAll(keepingCapacity: true)
	}

	private func signIn() {
		Task {
			do {
				let signInResponseDTO = try await model.signIn(
					username: username.trimming(.whitespacesAndNewlines),
					password: password.trimming(.whitespacesAndNewlines))
				if signInResponseDTO.error {
					state.errorWrapper = ErrorWrapper(
						error:    URLError(.badServerResponse),
						guidance: signInResponseDTO.reason
					)
				} else if let _ = signInResponseDTO.token,
						  let _ = signInResponseDTO.userID {
					state.routes += [.groceryCategoryList]
				} else {
					fatalError()
				}
			} catch {
				state.errorWrapper = ErrorWrapper(error: error)
			}
		}
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var model = GroceryModel()
	@Previewable @State var state = AppState()

	NavigationStack(path: $state.routes) {
		SignInScreen()
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
			.environment(model)
			.environment(state)
	}
}
