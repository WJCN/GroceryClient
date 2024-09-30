//
//  GroceryModel.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Foundation
import GroceryDTOs
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
		guard let userID = UserDefaults.standard.userID
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let resource = Resource(
			url:      .groceryCategories.delete(userID:            userID,
												groceryCategoryID: groceryCategoryID),
			method:   .delete,
			modelType: GroceryCategoryResponseDTO.self
		)
		let deletedGroceryCategory = try await HTTPClient.load(resource)
		if deleteFromModel {
			groceryCategories.removeAll { $0.id == deletedGroceryCategory.id }
		}
	}

	func deleteGroceryItem(groceryCategoryID: UUID,
						   groceryItemID:     UUID,
						   deleteFromModel:   Bool = true) async throws {
		guard let userID = UserDefaults.standard.userID
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let resource = Resource(
			url:      .groceryItems.delete(userID:            userID,
										   groceryCategoryID: groceryCategoryID,
										   groceryItemID:     groceryItemID),
			method:   .delete,
			modelType: GroceryItemResponseDTO.self
		)
		let deletedGroceryItem = try await HTTPClient.load(resource)
		if deleteFromModel {
			groceryItems.removeAll { $0.id == deletedGroceryItem.id }
		}
	}

	func getGroceryCategories() async throws {
		guard let userID = UserDefaults.standard.userID
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let resource = Resource(
			url:       .groceryCategories.get(userID: userID),
			modelType: [GroceryCategoryResponseDTO].self
		)
		groceryCategories = try await HTTPClient.load(resource)
	}

	func getGroceryItems(groceryCategoryID: UUID) async throws {
		guard let userID = UserDefaults.standard.userID
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let resource = Resource(
			url:       .groceryItems.get(userID:            userID,
										 groceryCategoryID: groceryCategoryID),
			modelType: [GroceryItemResponseDTO].self
		)
		groceryItems = try await HTTPClient.load(resource)
	}

	func register(username: String,
				  password: String) async throws -> RegisterResponseDTO {
		let registerData: [String: String] = ["username": username,
											  "password": password]
		let resource = try Resource(
			url:      .register,
			method:   .post(JSONEncoder().encode(registerData)),
			modelType: RegisterResponseDTO.self
		)
		return try await HTTPClient.load(resource)
	}

	func saveGroceryCategory(groceryCategoryRequestDTO: GroceryCategoryRequestDTO) async throws {
		guard let userID = UserDefaults.standard.userID
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let resource = try Resource(
			url:      .groceryCategories.save(userID: userID),
			method:   .post(JSONEncoder().encode(groceryCategoryRequestDTO)),
			modelType: GroceryCategoryResponseDTO.self
		)
		try await groceryCategories += [HTTPClient.load(resource)]
	}

	func saveGroceryItem(groceryItemRequestDTO: GroceryItemRequestDTO,
						 groceryCategoryID:     UUID) async throws {
		guard let userID = UserDefaults.standard.userID
		else {
			Self.log.error("No user is logged in.")
			return
		}
		let resource = try Resource(
			url:      .groceryItems.save(userID:            userID,
										 groceryCategoryID: groceryCategoryID),
			method:   .post(JSONEncoder().encode(groceryItemRequestDTO)),
			modelType: GroceryItemResponseDTO.self
		)
		try await groceryItems += [HTTPClient.load(resource)]
	}

	func signIn(username: String,
				password: String) async throws -> SignInResponseDTO {
		let signInData: [String: String] = ["username": username,
											"password": password]
		let resource = try Resource(
			url:      .signIn,
			method:   .post(JSONEncoder().encode(signInData)),
			modelType: SignInResponseDTO.self
		)
		let signInResponseDTO = try await HTTPClient.load(resource)
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
