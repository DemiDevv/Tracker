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
    
    func performContextOperation(_ operation: (NSManagedObjectContext) -> Void) {
        operation(context)
    }
    
    func createCategory(with category: TrackerCategory) {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = category.title
        categoryEntity.trackers = NSSet()

        do {
            try context.save()
        } catch {
            print("Ошибка при создании категории")
        }
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
        trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSArray
        trackerCoreData.type = trackerTyperValueTransformer.transformedValue(tracker.type) as? String
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
