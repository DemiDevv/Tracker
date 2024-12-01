import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let daysValueTransformer = DaysValueTransformer()
    private let trackerTyperValueTransformer = TrackerTypeValueTransformer()

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.title = tracker.title
            trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
            trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
            categoryCoreData.addToTracker(trackerCoreData)
        }
        try context.save()
    }

    func fetchAllCategories() throws -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoryCoreDataList = try context.fetch(fetchRequest)
        
        return categoryCoreDataList.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }
            
            if let trackersSet = categoryCoreData.trackers as? NSSet {
                let trackerCoreDataList = trackersSet.allObjects as? [TrackerCoreData] ?? []
                
                let trackers = trackerCoreDataList.compactMap { trackerCoreData -> Tracker? in
                    guard let id = trackerCoreData.id,
                          let title = trackerCoreData.title,
                          let colorHex = trackerCoreData.color,
                          let emoji = trackerCoreData.emoji,
                          let scheduleData = trackerCoreData.schedule as? NSData,
                          let schedule = DaysValueTransformer().reverseTransformedValue(scheduleData) as? [Weekday],
                          let color = uiColorMarshalling.color(from: colorHex) else { return nil }
                    
                    return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, type: .habbit)
                }
                
                return TrackerCategory(title: title, trackers: trackers)
            }
            
            return nil
        }
    }


    func updateCategory(_ category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        if let categoryCoreData = try context.fetch(fetchRequest).first {
            categoryCoreData.removeFromTracker(categoryCoreData.trackers ?? NSSet())
            for tracker in category.trackers {
                let trackerCoreData = TrackerCoreData(context: context)
                trackerCoreData.id = tracker.id
                trackerCoreData.title = tracker.title
                trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.schedule = DaysValueTransformer().transformedValue(tracker.schedule) as? NSData
                trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
                categoryCoreData.addToTracker(trackerCoreData)
            }
            try context.save()
        }
    }

    func deleteCategory(byTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        if let categoryCoreData = try context.fetch(fetchRequest).first {
            context.delete(categoryCoreData)
            try context.save()
        }
    }
}

