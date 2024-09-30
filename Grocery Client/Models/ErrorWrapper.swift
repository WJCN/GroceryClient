//
//  ErrorWrapper.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/29/24.
//

import Foundation

struct ErrorWrapper: Equatable, Identifiable {
	let id      = UUID()
	let error:    Error
	var guidance: String?

	static func == (lhs: ErrorWrapper,
					rhs: ErrorWrapper) -> Bool {
		lhs.id       == rhs.id &&
		lhs.guidance == rhs.guidance
	}
}
