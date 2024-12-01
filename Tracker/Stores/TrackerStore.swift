import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let daysValueTransformer = DaysValueTransformer()

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        try context.save()
    }

    func updateExistingTracker(_ trackerCorData: TrackerCoreData, with tracker: Tracker) {
        trackerCorData.id = tracker.id
        trackerCorData.title = tracker.title
        trackerCorData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCorData.emoji = tracker.emoji
        trackerCorData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
        trackerCorData.type = tracker.emoji
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackerCoreDataList = try context.fetch(fetchRequest)
        
        return trackerCoreDataList.compactMap { trackerCoreData in
            guard
                let id = trackerCoreData.id,
                let title = trackerCoreData.title,
                let colorHex = trackerCoreData.color,
                let emoji = trackerCoreData.emoji,
                let scheduleData = trackerCoreData.schedule as? NSData,
                let schedule = daysValueTransformer.reverseTransformedValue(scheduleData) as? [Weekday],
                let color = uiColorMarshalling.color(from: colorHex)
            else { return nil }
            return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, type: .habbit)
        }
    }

    func fetchTracker(by id: UUID) throws -> Tracker? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let trackerCoreData = try context.fetch(fetchRequest).first else { return nil }
        
        guard
            let title = trackerCoreData.title,
            let colorHex = trackerCoreData.color,
            let emoji = trackerCoreData.emoji,
            let scheduleData = trackerCoreData.schedule as? NSData,
            let schedule = daysValueTransformer.reverseTransformedValue(scheduleData) as? [Weekday],
            let color = uiColorMarshalling.color(from: colorHex)
        else { return nil }
        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, type: .habbit)
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            updateExistingTracker(trackerCoreData, with: tracker)
            try context.save()
        }
    }

    func deleteTracker(by id: UUID) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            context.delete(trackerCoreData)
            try context.save()
        }
    }

    

}
