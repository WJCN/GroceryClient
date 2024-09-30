//
//  ColorSelector.swift
//  Grocery Client
//
//  Created by William J. C. Nesbitt on 9/28/24.
//

import SwiftUI

struct ColorSelector: View {
	// MARK: Enumerations

	enum Colors: String, CaseIterable, Identifiable {
		case red    = "#FFE74C3C"
		case yellow = "#FFF1C40F"
		case green  = "#FF2ECC71"
		case blue   = "#FF3498DB"
		case purple = "#FF9B59B6"

		var id: String { rawValue }
	}

	// MARK: - Stored Properties

	@Binding var color: String

	// MARK: Computed Properties

	var body: some View {
		HStack {
			ForEach(Colors.allCases) { color in
				VStack {
					Image(systemName: self.color == color.rawValue ? "record.circle.fill" : "circle.fill")
						.font(.title)
						.foregroundStyle(Color(fromHexadecimal: color.rawValue))
						.onTapGesture {
							self.color = color.rawValue
						}
				}
			}
		}
	}
}

// MARK: - Preview

#Preview {
	@Previewable @State var color = ColorSelector.Colors.green.rawValue

	ColorSelector(color: $color)
}
