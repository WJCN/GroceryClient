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
			url:        .groceryCategories.delete(userID:            userID,
												  groceryCategoryID: groceryCategoryID),
			bearerToken: token
		)
		let (deletedGroceryCategory, _) = try await JSONDecoder().decode(
			GroceryCategoryResponseDTO.self, from: request
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
			url:        .groceryItems.delete(userID:            userID,
											 groceryCategoryID: groceryCategoryID,
											 groceryItemID:     groceryItemID),
			bearerToken: token
		)
		let (deletedGroceryItem, _) = try await JSONDecoder().decode(
			GroceryItemResponseDTO.self, from: request
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
			url:        .groceryCategories.get(userID: userID),
			bearerToken: token
		)
		(groceryCategories, _) = try await JSONDecoder().decode(
			[GroceryCategoryResponseDTO].self, from: request
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
			url:        .groceryItems.get(userID:            userID,
										  groceryCategoryID: groceryCategoryID),
			bearerToken: token
		)
		(groceryItems, _) = try await JSONDecoder().decode(
			[GroceryItemResponseDTO].self, from: request
		)
	}

	func register(username: String,
				  password: String) async throws -> RegisterResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method: .post,
			url:    .register,
			body:    JSONEncoder().encode(usernamePassword)
		)
		let (registerResponseDTO, _) = try await JSONDecoder().decode(
			RegisterResponseDTO.self, from: request
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
			url:        .groceryCategories.save(userID: userID),
			bearerToken: token,
			body:        JSONEncoder().encode(groceryCategoryRequestDTO)
		)
		let (groceryCategoryResponseDTO, _) = try await JSONDecoder().decode(
			GroceryCategoryResponseDTO.self, from: request
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
			url:        .groceryItems.save(userID:            userID,
										   groceryCategoryID: groceryCategoryID),
			bearerToken: token,
			body:        JSONEncoder().encode(groceryItemRequestDTO)
		)
		let (groceryItemResponseDTO, _) = try await JSONDecoder().decode(
			GroceryItemResponseDTO.self, from: request
		)
		groceryItems.append(groceryItemResponseDTO)
	}

	func signIn(username: String,
				password: String) async throws -> SignInResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method: .post,
			url:    .signIn,
			body:    JSONEncoder().encode(usernamePassword)
		)
		let (signInResponseDTO, _) = try await JSONDecoder().decode(
			SignInResponseDTO.self, from: request
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

	private static let log = Logger(subsystem: String(describing: GroceryModel.self),
									category: "")
}
