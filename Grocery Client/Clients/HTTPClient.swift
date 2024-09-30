//
//  HTTPClient.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 6/25/24.
//

import Foundation

enum HTTPMethod {
	case delete
	case get([URLQueryItem] = [])
	case post(Data?)

	var name: String {
		switch self {
			case .delete: "Delete"
			case .get:    "Get"
			case .post:   "Post"
		}
	}
}

#if false
enum NetworkError: LocalizedError {
	case badRequest
	case decodingError
	case invalidResponse
	case serverError(String)

	var errorDescription: String? {
		switch self {
			case .badRequest:               "Bad Request"
			case .decodingError:            "Decoding Error"
			case .invalidResponse:          "Invalid Response"
			case .serverError(let message): "Server Error: \(message)"
		}
	}
}
#endif

struct Resource<T: Codable> {
	let url:       URL
	var method:    HTTPMethod = .get()
	let modelType: T.Type
}

enum HTTPClient {
	@discardableResult
	static func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
		var request = URLRequest(url: resource.url)
		switch resource.method {
			case .delete:
				request.httpMethod = resource.method.name
			case .get(let queryItems):
				var components = URLComponents(url: resource.url,
											   resolvingAgainstBaseURL: false)
				components?.queryItems = queryItems
				guard let url = components?.url else { throw URLError(.badURL) }
				request = URLRequest(url: url)
			case .post(let data):
				request.httpMethod = resource.method.name
				request.httpBody = data
		}
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = defaultHeaders
		let session = URLSession(configuration: configuration)
		let (data, _) = try await session.data(for: request)
		return try JSONDecoder().decode(resource.modelType, from: data)
	}

	private static var defaultHeaders: [String: String] {
		var headers: [String: String] = ["Content-Type": "application/json"]
		if let token = UserDefaults.standard.token {
			headers["Authorization"] = "Bearer \(token)"
		}
		return headers
	}

#if false
	private static func check(_ response: URLResponse) throws {
		if let response = response as? HTTPURLResponse {
			guard (200 ..< 300).contains(response.statusCode)
			else { throw URLError(.badServerResponse) }
		}
	}
#endif
}
