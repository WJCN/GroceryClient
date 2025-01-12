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
			bearerToken: token,
			contentType: nil
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		let deletedGroceryCategory = try JSONDecoder().decode(
			GroceryCategoryResponseDTO.self, from: data
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
			bearerToken: token,
			contentType: nil
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		let deletedGroceryItem = try JSONDecoder().decode(
			GroceryItemResponseDTO.self, from: data
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
			bearerToken: token,
			contentType: nil
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		groceryCategories = try JSONDecoder().decode(
			[GroceryCategoryResponseDTO].self, from: data
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
			bearerToken: token,
			contentType: nil
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		groceryItems = try JSONDecoder().decode(
			[GroceryItemResponseDTO].self, from: data
		)
	}

	func register(username: String,
				  password: String) async throws -> RegisterResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method:     .post,
			url:        .grocery.register,
			bearerToken: nil,
			body:        usernamePassword
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		let registerResponseDTO = try JSONDecoder().decode(
			RegisterResponseDTO.self, from: data
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
			body:        groceryCategoryRequestDTO
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		let groceryCategoryResponseDTO = try JSONDecoder().decode(
			GroceryCategoryResponseDTO.self, from: data
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
			body:        groceryItemRequestDTO
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		let groceryItemResponseDTO = try JSONDecoder().decode(
			GroceryItemResponseDTO.self, from: data
		)
		groceryItems.append(groceryItemResponseDTO)
	}

	func signIn(username: String,
				password: String) async throws -> SignInResponseDTO {
		let usernamePassword: [String: String] = ["username": username,
												  "password": password]
		let request = try URLRequest(
			method:     .post,
			url:        .grocery.signIn,
			bearerToken: nil,
			body:        usernamePassword
		)
		let (data, _) = try await URLSession.shared.httpData(for: request)
		let signInResponseDTO = try JSONDecoder().decode(
			SignInResponseDTO.self, from: data
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
