//
//  GroceryModel.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import GroceryDTOs
import NetworkingExtensions
import OSLog

@MainActor @Observable
final class GroceryModel: Sendable {
	// MARK: Stored Properties

	var groceryCategory:    GroceryCategoryResponseDTO?
	var groceryCategories: [GroceryCategoryResponseDTO] = []
	var groceryItems:      [GroceryItemResponseDTO]     = []

	// MARK: - Functions

	func deleteGroceryCategory(groceryCategoryID: UUID,
							   deleteFromModel:   Bool = true) async throws {
		guard let userID = UserDefaults.standard.userID,
			  let token  = UserDefaults.standard.token
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let request = URLRequest(
			method:     .delete,
			url:        .grocery.categories.delete(userID:            userID,
												   groceryCategoryID: groceryCategoryID),
			bearerToken: token
		)
		let (deletedGroceryCategory, _) = try await URLSession.shared.httpDecode(
			GroceryCategoryResponseDTO.self, for: request
		)
		if deleteFromModel {
			groceryCategories.removeAll { $0.id == deletedGroceryCategory.id }
		}
	}

	func deleteGroceryItem(groceryCategoryID: UUID,
						   groceryItemID:     UUID,
						   deleteFromModel:   Bool = true) async throws {
		guard let userID = UserDefaults.standard.userID,
			  let token  = UserDefaults.standard.token
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let request = URLRequest(
			method:     .delete,
			url:        .grocery.items.delete(userID:            userID,
											  groceryCategoryID: groceryCategoryID,
											  groceryItemID:     groceryItemID),
			bearerToken: token
		)
		let (deletedGroceryItem, _) = try await URLSession.shared.httpDecode(
			GroceryItemResponseDTO.self, for: request
		)
		if deleteFromModel {
			groceryItems.removeAll { $0.id == deletedGroceryItem.id }
		}
	}

	func getGroceryCategories() async throws {
		guard let userID = UserDefaults.standard.userID,
			  let token  = UserDefaults.standard.token
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let request = URLRequest(
			method:     .get,
			url:        .grocery.categories.get(userID: userID),
			bearerToken: token
		)
		(groceryCategories, _) = try await URLSession.shared.httpDecode(
			[GroceryCategoryResponseDTO].self, for: request
		)
	}

	func getGroceryItems(groceryCategoryID: UUID) async throws {
		guard let userID = UserDefaults.standard.userID,
			  let token  = UserDefaults.standard.token
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let request = URLRequest(
			method:     .get,
			url:        .grocery.items.get(userID:            userID,
										   groceryCategoryID: groceryCategoryID),
			bearerToken: token
		)
		(groceryItems, _) = try await URLSession.shared.httpDecode(
			[GroceryItemResponseDTO].self, for: request
		)
	}

	func register(username: String,
				  password: String) async throws -> RegisterResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method: .post,
			url:    .grocery.register,
			body:    JSONEncoder().encode(usernamePassword)
		)
		let (registerResponseDTO, _) = try await URLSession.shared.httpDecode(
			RegisterResponseDTO.self, for: request
		)
		return registerResponseDTO
	}

	func saveGroceryCategory(groceryCategoryRequestDTO: GroceryCategoryRequestDTO) async throws {
		guard let userID = UserDefaults.standard.userID,
			  let token  = UserDefaults.standard.token
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let request = try URLRequest(
			method:     .post,
			url:        .grocery.categories.save(userID: userID),
			bearerToken: token,
			body:        JSONEncoder().encode(groceryCategoryRequestDTO)
		)
		let (groceryCategoryResponseDTO, _) = try await URLSession.shared.httpDecode(
			GroceryCategoryResponseDTO.self, for: request
		)
		groceryCategories.append(groceryCategoryResponseDTO)
	}

	func saveGroceryItem(groceryItemRequestDTO: GroceryItemRequestDTO,
						 groceryCategoryID:     UUID) async throws {
		guard let userID = UserDefaults.standard.userID,
			  let token  = UserDefaults.standard.token
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let request = try URLRequest(
			method:     .post,
			url:        .grocery.items.save(userID:            userID,
											groceryCategoryID: groceryCategoryID),
			bearerToken: token,
			body:        JSONEncoder().encode(groceryItemRequestDTO)
		)
		let (groceryItemResponseDTO, _) = try await URLSession.shared.httpDecode(
			GroceryItemResponseDTO.self, for: request
		)
		groceryItems.append(groceryItemResponseDTO)
	}

	func signIn(username: String,
				password: String) async throws -> SignInResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method: .post,
			url:    .grocery.signIn,
			body:    JSONEncoder().encode(usernamePassword)
		)
		let (signInResponseDTO, _) = try await URLSession.shared.httpDecode(
			SignInResponseDTO.self, for: request
		)
		if let token  = signInResponseDTO.token,
		   let userID = signInResponseDTO.userID {
			UserDefaults.standard.token  = token
			UserDefaults.standard.userID = userID
		}
		return signInResponseDTO
	}

	func signOut() {
		UserDefaults.standard.removeToken()
		UserDefaults.standard.removeUserID()
	}

	// MARK: - Private Stored Properties

	private static let log = Logger(
		subsystem: String(describing: GroceryModel.self), category: ""
	)
}
