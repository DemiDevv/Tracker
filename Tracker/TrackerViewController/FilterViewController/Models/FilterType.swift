import Foundation

enum FilterType: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: Constants.all
        case .today: Constants.today
        case .completed: Constants.completed
        case .notCompleted: Constants.notCompleted
        }
    }
}

private extension FilterType {
    enum Constants {
        static let all = NSLocalizedString("filter.screen.all", comment: "")
        static let today = NSLocalizedString("filter.screen.today", comment: "")
        static let completed = NSLocalizedString("filter.screen.completed", comment: "")
        static let notCompleted = NSLocalizedString("filter.screen.notCompleted", comment: "")
    }
}
