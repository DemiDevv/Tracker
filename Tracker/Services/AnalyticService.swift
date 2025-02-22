import Foundation
import YandexMobileMetrica

protocol AnalyticServiceProtocol {
    static func activate()
    func trackOpenScreen(screen: AnalyticScreen)
    func trackCloseScreen(screen: AnalyticScreen)
    func trackClick(screen: AnalyticScreen, item: AnalyticItems)
}

struct AnalyticService: AnalyticServiceProtocol {
    static func activate() {
        guard
            let configuration = YMMYandexMetricaConfiguration(apiKey: Constants.AppMetricaKey)
        else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
}

extension AnalyticService {
    func trackOpenScreen(screen: AnalyticScreen) {
        reportEvent(event: Events.open.rawValue, screen: screen.rawValue)
    }
    
    func trackCloseScreen(screen: AnalyticScreen) {
        reportEvent(event: Events.close.rawValue, screen: screen.rawValue)
    }
    
    func trackClick(screen: AnalyticScreen, item: AnalyticItems) {
        reportEvent(event: Events.click.rawValue, screen: screen.rawValue, item: item.rawValue)
    }
}

private extension AnalyticService {
    private func reportEvent(event: String, screen: String, item: String? = nil) {
        let params : [AnyHashable : Any] = ["event": event, "screen": screen]
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    private enum Events: String, CaseIterable {
        case open = "open"
        case close = "close"
        case click = "click"
    }
}
