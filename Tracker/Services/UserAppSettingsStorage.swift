import Foundation

import Foundation

protocol UserAppSettingsStorageProtocol {
    var isOnboardingVisited: Bool { get set }
    func clean()
}

final class UserAppSettingsStorage: UserAppSettingsStorageProtocol {
    
    // MARK: - Properties
    
    static let shared = UserAppSettingsStorage()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case isOnBoardingVisited
    }
    
    var isOnboardingVisited: Bool {
        get {
            userDefaults.bool(forKey: Keys.isOnBoardingVisited.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.isOnBoardingVisited.rawValue)
        }
    }
    
    private init() {}
    
    // MARK: - clean
    
    func clean() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}
