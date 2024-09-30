//
//  AppState.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/26/24.
//

import GroceryDTOs
import Observation

enum Route: Hashable {
	case register
	case signIn
	case groceryCategoryList
	case groceryCategoryDetail(GroceryCategoryResponseDTO)
}

@Observable
final class AppState {
	var routes:      [Route] = []
	var errorWrapper: ErrorWrapper?
}
