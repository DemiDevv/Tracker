import Foundation

// MARK: - AnalyticService + AnalyticServiceProtocol

protocol AnalyticServiceProtocol {
    static func activate()
    func trackOpenScreen(screen: AnalyticScreen)
    func trackCloseScreen(screen: AnalyticScreen)
    func trackClick(screen: AnalyticScreen, item: AnalyticItems)
}
