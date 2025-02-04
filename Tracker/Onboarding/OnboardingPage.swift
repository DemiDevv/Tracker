import Foundation

enum OnboardingPage {
    case first
    case second
    
    var backGroundImageName: String {
        switch self {
        case .first: "OnboardingPage_1"
        case .second: "OnboardingPage_2"
        }
    }
    
    var message: String {
        switch self {
        case .first: "Отслеживайте только то, что хотите"
        case .second: "Даже если это не литры воды и йога"
        }
    }
}
