import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    enum TrackerCategoryStoreError: Error {
        case categoryNotFound
    }

    init(context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to retrieve AppDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }()) {
        self.context = context
    }

    func updateCategory(with data: TrackerCategory) {
        let category = getCategoryByTitle(data.title)
        category?.title = data.title
        do {
            try context.save()
        } catch {
            print("Ошибка при создании категории")
        }
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
    
    func deleteCategory(_ category: TrackerCategory) {
        guard let categoryToDelete = getCategoryByTitle(category.title) else {
            return
        }

        context.delete(categoryToDelete)
        
        do {
            try context.save()
        } catch {
            print("Ошибка при создании категории")
        }
    }
}

extension TrackerCategoryStore {
    private func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title else {
            print("❌ Failed to decode category: title is missing")
            return nil
        }
        guard let trackerCoreDataSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else {
            print("❌ Failed to decode category: trackers data is invalid")
            return nil
        }
        let trackers = trackerCoreDataSet.compactMap { Tracker(from: $0) }
        
        if trackers.isEmpty {
            print("⚠️ Decoded category with no trackers: \(title)")
        }
        return TrackerCategory(title: title, trackers: trackers)
    }
}
