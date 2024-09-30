//
//  URLExtension.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Foundation

extension URL {
	// MARK: Stored Properties

	static let register = URL(string: "\(baseURLPath)/register")!
	static let signIn   = URL(string: "\(baseURLPath)/sign-in")!

	// MARK: -

	enum groceryCategories {
		static func delete(userID:            UUID,
						   groceryCategoryID: UUID) -> URL {
			URL(string: "\(baseURLPath)/users/\(userID)/grocery-categories/\(groceryCategoryID)")!
		}

		static func get(userID: UUID) -> URL {
			URL(string: "\(baseURLPath)/users/\(userID)/grocery-categories")!
		}

		static func save(userID: UUID) -> URL {
			URL(string: "\(baseURLPath)/users/\(userID)/grocery-categories")!
		}
	}

	// MARK: -

	enum groceryItems {
		static func delete(userID:            UUID,
						   groceryCategoryID: UUID,
						   groceryItemID:     UUID) -> URL {
			URL(string: "\(baseURLPath)/users/\(userID)/grocery-categories/\(groceryCategoryID)/grocery-items/\(groceryItemID)")!
		}

		static func get(userID:            UUID,
						groceryCategoryID: UUID) -> URL {
			URL(string: "\(baseURLPath)/users/\(userID)/grocery-categories/\(groceryCategoryID)/grocery-items")!
		}

		static func save(userID:            UUID,
						 groceryCategoryID: UUID) -> URL {
			URL(string: "\(baseURLPath)/users/\(userID)/grocery-categories/\(groceryCategoryID)/grocery-items")!
		}
	}

	// MARK: - Private Stored Properties

	private static let baseURLPath = "http://localhost:8080/api"
}
