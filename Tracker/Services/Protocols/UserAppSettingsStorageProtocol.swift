import Foundation

// MARK: - UserAppSettingsStorage + UserAppSettingsStorageProtocol

protocol UserAppSettingsStorageProtocol {
    var isOnboardingVisited: Bool { get set }
    func clean()
}
