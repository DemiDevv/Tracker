import Foundation

enum TrackerType: Codable {
    case habit
    case event
    case editHabit
    case editEvent
    
    var paramsCellsCount: Int {
        switch self {
        case .habit, .editHabit: 1
        case .event, .editEvent: 2
        }
    }
}
