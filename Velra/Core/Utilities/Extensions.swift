import Foundation
import SwiftUI

extension Double {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}

extension Int {
    var formattedCentsToDollars: String {
        let dollars = Double(self) / 100.0
        return dollars.formattedPrice
    }
}

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    @ViewBuilder
    func redactedShimmer(when condition: Bool) -> some View {
        if condition {
            self.redacted(reason: .placeholder)
        } else {
            self
        }
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return self.wholeMatch(of: emailRegex) != nil
    }

    var isStrongPassword: Bool {
        count >= 8
    }
}
