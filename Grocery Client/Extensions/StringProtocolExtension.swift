//
//  StringProtocolExtension.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Foundation

extension StringProtocol {
	@inlinable
	func isEmpty(trimming characterSet: CharacterSet) -> Bool {
		trimmingCharacters(in: characterSet).isEmpty
	}

	@inlinable
	func trimming(_ characterSet: CharacterSet) -> String {
		trimmingCharacters(in: characterSet)
	}
}
