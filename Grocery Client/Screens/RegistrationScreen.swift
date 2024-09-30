//
//  RegistrationScreen.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import SwiftUI

struct RegistrationScreen: View {
	// MARK: Computed Properties

	var body: some View {
		Form {
			TextField("Username", text: $username)
				.autocorrectionDisabled(true)
				.textContentType(.username)
				.textInputAutocapitalization(.never)
			HStack {
				SecureField("Password", text: $password)
					.textContentType(.newPassword)
				Image(
					systemName: passwordIsValid
					? "checkmark.circle.fill"
					:  "multiply.circle.fill"
				)
				.foregroundStyle(passwordIsValid ? .green : .red)
			}
			HStack {
				SecureField("Confirmation", text: $passwordConfirmation)
					.textContentType(.newPassword)
				Image(systemName: passwordConfirmationIsValid
					  ? "checkmark.circle.fill"
					  :  "multiply.circle.fill"
				)
				.foregroundStyle(passwordConfirmationIsValid ? .green : .red)
			}
			HStack {
				Button("Register", action: register)
					.buttonStyle(.borderless)
					.disabled(!formIsValid)
				Spacer()
				Button("Sign In") { state.routes += [.signIn] }
					.buttonStyle(.borderless)
			}
			if !errorMessage.isEmpty {
				Text(errorMessage)
					.foregroundStyle(.red)
			}
		}
		.navigationTitle("Registration")
		.onAppear   (perform: resetForm)
		.onDisappear(perform: resetForm)
	}

	// MARK: - Private Stored Properties

	private let passwordCountRange = 5 ... 10
	private let whitespace: CharacterSet = .whitespacesAndNewlines

	@Environment(GroceryModel.self) private var model
	@Environment(AppState    .self) private var state

	@State private var username:             String = ""
	@State private var password:             String = ""
	@State private var passwordConfirmation: String = ""
	@State private var errorMessage:         String = ""

	// MARK: - Private Computed Properties

	private var formIsValid: Bool {
		!username.isEmpty(trimming: whitespace) &&
		passwordIsValid &&
		passwordConfirmationIsValid
	}

	private var passwordIsValid: Bool {
		let trimmedPassword = password.trimming(whitespace)
		return !trimmedPassword.isEmpty
		&& passwordCountRange.contains(trimmedPassword.count)
	}

	private var passwordConfirmationIsValid: Bool {
		!passwordConfirmation.isEmpty(trimming: whitespace) &&
		passwordConfirmation == password
	}

	// MARK: - Private Functions

	private func register() {
		Task {
			do {
				errorMessage.removeAll(keepingCapacity: true)
				let registerResponseDTO = try await model.register(
					username: username.trimming(whitespace),
					password: password.trimming(whitespace)
				)
				if registerResponseDTO.error, let reason = registerResponseDTO.reason {
					errorMessage = reason
				} else {
					state.routes += [.signIn]
				}
			} catch {
				errorMessage = error.localizedDescription
			}
		}
	}

	private func resetForm() {
		username            .removeAll(keepingCapacity: true)
		password            .removeAll(keepingCapacity: true)
		passwordConfirmation.removeAll(keepingCapacity: true)
		errorMessage        .removeAll(keepingCapacity: true)
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var model = GroceryModel()
	@Previewable @State var state = AppState()

	NavigationStack(path: $state.routes) {
		RegistrationScreen()
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
