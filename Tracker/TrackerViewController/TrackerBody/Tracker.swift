import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let type: TrackerType
}

extension Tracker {
    init?(from trackerCoreData: TrackerCoreData) {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let hexColor = trackerCoreData.color,
            let color = UIColorMarshalling().color(from: hexColor),
            let emoji = trackerCoreData.emoji,
            let typeRaw = trackerCoreData.type,
            let type = TrackerTypeValueTransformer().reverseTransformedValue(typeRaw) as? TrackerType,
            let scheduleData = trackerCoreData.schedule as? Data,
            let schedule = DaysValueTransformer().reverseTransformedValue(scheduleData) as? [Weekday]
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.type = type
    }
}
