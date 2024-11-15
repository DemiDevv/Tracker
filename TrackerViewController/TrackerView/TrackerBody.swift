import UIKit

enum Weekday: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

enum TrackerType {
    case habbit
    case event
}

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let type: TrackerType
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker] 
}

struct TrackerRecord {
    let trackerID: UUID
    let date: Date
}
