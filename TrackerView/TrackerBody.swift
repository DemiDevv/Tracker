import Foundation


struct Tracker {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [String]
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerID: UUID
    let date: Date
}
