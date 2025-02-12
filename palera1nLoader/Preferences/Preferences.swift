//
//  Preferences.swift
//  loader-rewrite
//
//  Created by samara on 1/29/24.
//

import Foundation

/// A set of user controlled preferences.
enum Preferences {
    static var installPathChangedCallback: ((String?) -> Void)?
	static let defaultInstallPath: String = "https://gist.githubusercontent.com/xliee/191f1648b6d1e7dc4d3ac3d56950c203/raw/5169383d3e18504082a33254d091bd10015a5517/loaderv2.json"

    @Storage(key: "UserPreferredLanguageCode", defaultValue: nil, callback: preferredLangChangedCallback)
    /// Preferred language
    static var preferredLanguageCode: String?
    
    @Storage(key: "UserSpecifiedInstallPath", defaultValue: defaultInstallPath)
    /// User specified download path
    static var installPath: String? {
        didSet { installPathChangedCallback?(installPath) }
    }
    
    @Storage(key: "UserSpecifiedRebootOnRevert", defaultValue: true)
    /// If the user wants to reboot when restoring system
    static var rebootOnRevert: Bool?
    
    @Storage(key: "UserSpecifiedDoDisplayPasswordPrompt", defaultValue: true)
    /// Show whether the psasword prompt is not displayed during installation, default will display the prompt for password
    static var doPasswordPrompt: Bool?
}

// MARK: - Callbacks
fileprivate extension Preferences {
    
    static func preferredLangChangedCallback(newValue: String?) {
        Bundle.preferredLocalizationBundle = .makeLocalizationBundle(preferredLanguageCode: newValue)
    }
}



// MARK: -



@propertyWrapper
struct Storage<Value> {
    typealias Callback = (Value) -> Void
    let key: String
    let defaultValue: Value
    let callback: Callback?
    
    init(key: String, defaultValue: Value, callback: Callback? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.callback = callback
    }
    
    var wrappedValue: Value {
        get {
            if let storedValue = UserDefaults.standard.object(forKey: key) {
                if let castedValue = storedValue as? Value {
                    return castedValue
                }
            }
            return defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            callback?(newValue)
        }
    }

}
