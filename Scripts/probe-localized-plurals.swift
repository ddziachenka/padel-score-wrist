import Foundation
let path = CommandLine.arguments[1]
let language = CommandLine.arguments[2]
let locale = Locale(identifier: language)
guard let bundle = Bundle(path: path + "/" + language + ".lproj") else { fatalError("Missing locale bundle") }
for n in [0, 1, 2, 4, 5, 11, 21, 22, 25, 101, 999] {
    let played: String.LocalizationValue = "\(n) of \(n) rallies played."
    let rules: String.LocalizationValue = "\(n) rallies in total, \(n) per server."
    print("\(n): " + String(localized: played, bundle: bundle, locale: locale))
    print("\(n): " + String(localized: rules, bundle: bundle, locale: locale))
}
