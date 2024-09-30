//
//  ColorExtension.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/28/24.
//

import SwiftUI

extension Color {
	init(_ colorSpace: RGBColorSpace = .sRGB, fromHexadecimal: String, supportsOpacity: Bool = true) {
		let stringValue = fromHexadecimal
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "#", with: "")
		var binaryValue: Int64 = 0
		Scanner(string: stringValue).scanHexInt64(&binaryValue)
		let blue  = Double(binaryValue & 0xFF) / 0xFF
		binaryValue >>= 8
		let green = Double(binaryValue & 0xFF) / 0xFF
		binaryValue >>= 8
		let red   = Double(binaryValue & 0xFF) / 0xFF
		var opacity: Double = 1
		if supportsOpacity {
			binaryValue >>= 8
			opacity = Double(binaryValue & 0xFF) / 0xFF
		}
		self.init(colorSpace, red: red, green: green, blue: blue, opacity: opacity)
	}

	func toHexadecimal(supportsOpacity: Bool = true) -> String? {
		let color = UIColor(self)
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }
		var binaryValue: Int = 0
		if supportsOpacity {
			binaryValue |= Int(alpha * 0xFF)
			binaryValue <<= 8
		}
		binaryValue |= Int(red   * 0xFF)
		binaryValue <<= 8
		binaryValue |= Int(green * 0xFF)
		binaryValue <<= 8
		binaryValue |= Int(blue  * 0xFF)
		return String(format: supportsOpacity ? "#%08x" : "#%06x", binaryValue)
	}
}
