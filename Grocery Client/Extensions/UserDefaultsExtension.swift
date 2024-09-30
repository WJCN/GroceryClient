//
//  UserDefaultsExtension.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/28/24.
//

import Foundation

extension UserDefaults {
	var token: String? {
		get { string(       forKey: Self.tokenKey) }
		set { set(newValue, forKey: Self.tokenKey) }
	}

	var userID: UUID? {
		get {
			guard let userIDString = string(forKey: Self.userIDKey) else { return nil }
			return UUID(uuidString: userIDString)
		}
		set { set(newValue?.uuidString, forKey: Self.userIDKey) }
	}

	func removeToken()  { removeObject(forKey: Self.tokenKey)}
	func removeUserID() { removeObject(forKey: Self.userIDKey) }

	private static let tokenKey:  String = "Token"
	private static let userIDKey: String = "User ID"
}
