//
//  NetworkingExtensions.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 10/7/24.
//

import Foundation

extension URLRequest {
	enum Method: String {
		case connect
		case delete
		case head
		case get
		case options
		case patch
		case post
		case put
		case trace
	}

	init(
		method httpMethod: Method,
		url:               URL,
		bearerToken:       String? =  nil,
		contentType:       String  = "application/json",
		httpBody:          Data?   =  nil
	) {
		self.init(url: url)
		self.httpMethod = httpMethod.rawValue
		if let bearerToken {
			self.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
		}
		if let httpBody {
			self.httpBody = httpBody
			self.setValue(contentType, forHTTPHeaderField: "Content-Type")
		}
	}
}

// MARK: -

#if false
extension URLResponse {
	func check() throws {
		if let response = self as? HTTPURLResponse {
			guard (200 ..< 300).contains(response.statusCode)
			else { throw URLError(.badServerResponse) }
		}
	}
}
#endif

// MARK: -

extension URLSession {
	func receive<T: Decodable>(
		_    type: T.Type,
		from url:  URL,
		delegate:  URLSessionTaskDelegate? = nil
	) async throws -> (result: T, response: URLResponse) {
		let (data, response) = try await data(from: url, delegate: delegate)
		return try (JSONDecoder().decode(T.self, from: data), response)
	}

	func receive<T: Decodable>(
		_   type:    T.Type,
		for request: URLRequest,
		delegate:    URLSessionTaskDelegate? = nil
	) async throws -> (result: T, response: URLResponse) {
		let (data, response) = try await data(for: request)
		return try (JSONDecoder().decode(T.self, from: data), response)
	}
}
