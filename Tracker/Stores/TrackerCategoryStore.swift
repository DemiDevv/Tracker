import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let daysValueTransformer = DaysValueTransformer()
    private let trackerTyperValueTransformer = TrackerTypeValueTransformer()

    enum TrackerCategoryStoreError: Error {
        case categoryNotFound
        case trackerNotFound
    }

    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }

    // Выполнение синхронных операций с контекстом
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        var result: Result<R, Error>!
        context.performAndWait {
            result = action(context)
        }
        return try result.get()
    }

    // Добавить категорию и связанные с ней трекеры
    func addCategory(_ category: TrackerCategory) throws {
        try performSync { context in
            Result {
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
                    trackerCoreData.category = categoryCoreData
                }

                try context.save()
            }
        }
    }

    // Получить все категории с трекерами
    func fetchAllCategories() throws -> [TrackerCategory] {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                let categoryCoreDataList = try context.fetch(fetchRequest)

                return categoryCoreDataList.compactMap { categoryCoreData in
                    guard let title = categoryCoreData.title else { return nil }

                    let trackers = (categoryCoreData.trackers as? Set<TrackerCoreData>)?.compactMap { trackerCoreData -> Tracker? in
                        guard let id = trackerCoreData.id,
                              let title = trackerCoreData.title,
                              let colorHex = trackerCoreData.color,
                              let emoji = trackerCoreData.emoji,
                              let scheduleData = trackerCoreData.schedule as? NSData,
                              let schedule = daysValueTransformer.reverseTransformedValue(scheduleData) as? [Weekday],
                              let color = uiColorMarshalling.color(from: colorHex) else { return nil }
                        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, type: .habbit)
                    } ?? []

                    return TrackerCategory(title: title, trackers: trackers)
                }
            }
        }
    }

    // Обновить категорию и её трекеры
    func updateCategory(_ category: TrackerCategory) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)

                guard let categoryCoreData = try context.fetch(fetchRequest).first else {
                    throw TrackerCategoryStoreError.categoryNotFound
                }
                categoryCoreData.trackers = nil

                // Добавляем новые трекеры
                for tracker in category.trackers {
                    let trackerCoreData = TrackerCoreData(context: context)
                    trackerCoreData.id = tracker.id
                    trackerCoreData.title = tracker.title
                    trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
                    trackerCoreData.emoji = tracker.emoji
                    trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
                    trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
                    trackerCoreData.category = categoryCoreData
                }

                try context.save()
            }
        }
    }

    // Удалить категорию по названию
    func deleteCategory(byTitle title: String) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "title == %@", title)

                guard let categoryCoreData = try context.fetch(fetchRequest).first else {
                    throw TrackerCategoryStoreError.categoryNotFound
                }

                context.delete(categoryCoreData)
                try context.save()
            }
        }
    }

    // Добавить трекер в существующую категорию
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        try performSync { context in
            Result {
                let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "title == %@", title)

                guard let categoryCoreData = try context.fetch(categoryFetchRequest).first else {
                    throw TrackerCategoryStoreError.categoryNotFound
                }

                let trackerCoreData = TrackerCoreData(context: context)
                trackerCoreData.id = tracker.id
                trackerCoreData.title = tracker.title
                trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
                trackerCoreData.emoji = tracker.emoji
                trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
                trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
                trackerCoreData.category = categoryCoreData

                try context.save()
            }
        }
    }

    // Добавить категорию к существующему трекеру
    func addCategory(_ categoryTitle: String, toTrackerWithId trackerId: UUID) throws {
        try performSync { context in
            Result {
                let trackerFetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
                trackerFetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)

                guard let trackerCoreData = try context.fetch(trackerFetchRequest).first else {
                    throw TrackerCategoryStoreError.trackerNotFound
                }

                let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
                categoryFetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)

                guard let categoryCoreData = try context.fetch(categoryFetchRequest).first else {
                    throw TrackerCategoryStoreError.categoryNotFound
                }
                trackerCoreData.category = categoryCoreData

                try context.save()
            }
        }
    }
}
