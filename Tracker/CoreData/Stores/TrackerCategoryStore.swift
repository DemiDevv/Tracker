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
    
    func getCategoryByTitle(_ title: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title),
            title
        )
        request.fetchLimit = 1
        
        do {
            let category = try context.fetch(request)
            return category.first
        } catch {
            print("Failed to find category by title: \(error)")
            return nil
        }
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        do {
            let categoriesCoreDataArray = try context.fetch(fetchRequest)
            let categories = categoriesCoreDataArray
                .compactMap { categoriesCoreData -> TrackerCategory? in
                    decodingCategory(from: categoriesCoreData)
                }
            return categories
        } catch {
            print("❌ Failed to fetch categories: \(error)")
            return []
        }
    }


    // Добавить категорию и связанные с ней трекеры
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        categoryCoreData.trackers = NSSet()

        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.title = tracker.title
            trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
            trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String

            trackerCoreData.category = categoryCoreData
            categoryCoreData.addToTracker(trackerCoreData)
        }

        try context.save()
    }

    // Обновить категорию и её трекеры
    func updateCategory(_ category: TrackerCategory) throws {
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

    // Удалить категорию по названию
    func deleteCategory(byTitle title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)

        guard let categoryCoreData = try context.fetch(fetchRequest).first else {
            throw TrackerCategoryStoreError.categoryNotFound
        }

        context.delete(categoryCoreData)
        try context.save()
    }

    // Добавить трекер в существующую категорию
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
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

    // Добавить категорию к существующему трекеру
    func addCategory(_ categoryTitle: String, toTrackerWithId trackerId: UUID) throws {
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

        // Устанавливаем категорию для трекера
        trackerCoreData.category = categoryCoreData

        try context.save()
    }
}

extension TrackerCategoryStore {
    private func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard
            let title = trackerCategoryCoreData.title,
            let trackerCoreDataSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData>
        else {
            return nil
        }
        
        let trackers = trackerCoreDataSet.compactMap { trackerCoreData -> Tracker? in
            return Tracker(from: trackerCoreData)
        }
        
        return TrackerCategory(title: title, trackers: trackers)
    }
}
