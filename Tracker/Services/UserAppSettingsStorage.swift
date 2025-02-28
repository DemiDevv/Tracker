import Foundation

final class UserAppSettingsStorage: UserAppSettingsStorageProtocol {
    
    // MARK: - Properties
    
    static let shared = UserAppSettingsStorage()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case isOnBoardingVisited
        case selectedFilter
    }
    
    var isOnboardingVisited: Bool {
        get {
            userDefaults.bool(forKey: Keys.isOnBoardingVisited.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.isOnBoardingVisited.rawValue)
        }
    }
    
    var selectedFilter: FilterType? {
        get {
            guard let selectedFilter = userDefaults.string(forKey: Keys.selectedFilter.rawValue) else {
                return nil
            }
            
            return FilterType(rawValue: selectedFilter)
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: Keys.selectedFilter.rawValue)
        }
    }
    
    private init() {}
    
    // MARK: - clean
    
    func clean() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
}
