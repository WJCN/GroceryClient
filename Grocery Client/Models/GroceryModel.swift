//
//  GroceryModel.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Foundation
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
		let deletedGroceryCategory = try await URLSession
			.shared
			.receive(GroceryCategoryResponseDTO.self, for: request)
			.result
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
		let deletedGroceryItem = try await URLSession
			.shared
			.receive(GroceryItemResponseDTO.self, for: request)
			.result
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
		groceryCategories = try await URLSession
			.shared
			.receive([GroceryCategoryResponseDTO].self, for: request)
			.result
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
		groceryItems = try await URLSession
			.shared
			.receive([GroceryItemResponseDTO].self, for: request)
			.result
	}

	func register(username: String,
				  password: String) async throws -> RegisterResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method:  .post,
			url:     .register,
			httpBody: JSONEncoder().encode(usernamePassword)
		)
		return try await URLSession
			.shared
			.receive(RegisterResponseDTO.self, for: request)
			.result
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
			httpBody:    JSONEncoder().encode(groceryCategoryRequestDTO)
		)
		try await groceryCategories.append(
			URLSession
				.shared
				.receive(GroceryCategoryResponseDTO.self, for: request)
				.result
		)
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
			httpBody:    JSONEncoder().encode(groceryItemRequestDTO)
		)
		try await groceryItems.append(
			URLSession
				.shared
				.receive(GroceryItemResponseDTO.self, for: request)
				.result
		)
	}

	func signIn(username: String,
				password: String) async throws -> SignInResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method:  .post,
			url:     .signIn,
			httpBody: JSONEncoder().encode(usernamePassword)
		)
		let signInResponseDTO = try await URLSession
			.shared
			.receive(SignInResponseDTO.self, for: request)
			.result
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
