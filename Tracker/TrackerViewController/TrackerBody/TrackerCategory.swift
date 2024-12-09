import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    init?(from categoryCoreData: TrackerCategoryCoreData) {
        guard let title = categoryCoreData.title
        else {
            return nil
        }
        
        let trackerList = categoryCoreData.tracker as? Set<Tracker> ?? []
        
        self.title = title
        self.trackers = Array(trackerList)
    }
}
