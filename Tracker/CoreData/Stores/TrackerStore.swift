import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfTrackers: Int { get }
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func addNewTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker)
    func getTrackerCoreData(by id: UUID) -> TrackerCoreData?
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    private let uiColorMarshalling = UIColorMarshalling()
    private let daysValueTransformer = DaysValueTransformer()
    private let trackerTypeValueTransformer = TrackerTypeValueTransformer()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    weak var delegate: TrackerStoreDelegate?
    
    enum TrackerStoreError: Error {
        case trackerNotFound
    }
    
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
}
    
extension TrackerStore: TrackerStoreProtocol {
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func addNewTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws {
        guard let categoryCoreData = trackerCategoryStore.getCategoryByTitle(category.title) else {
            return
        }
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        trackerCoreData.category = categoryCoreData
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении контекста: \(error.localizedDescription)")
        }
    }


    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = daysValueTransformer.transformedValue(tracker.schedule) as? NSData
        trackerCoreData.type = trackerTypeValueTransformer.transformedValue(trackerCoreData.type) as? String
    }
    
    func getTrackerCoreData(by id: UUID) -> TrackerCoreData? {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "id == %@", id as CVarArg
        )
        
        do {
            try fetchedResultsController.performFetch()
            guard let tracker = fetchedResultsController.fetchedObjects?.first else {
                throw StoreErrors.fetchTrackerError
            }
            
            fetchedResultsController.fetchRequest.predicate = nil
            return tracker
        } catch {
            print("❌ Failed to fetch tracker by UUID: \(error)")
            return nil
        }
    }

    func fetchAllTrackers() throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackerCoreDataList = try context.fetch(fetchRequest)
        return trackerCoreDataList.compactMap { trackerCoreData in
            self.mapToTracker(trackerCoreData)
        }
    }

    func updateTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            updateExistingTracker(trackerCoreData, with: tracker)
            try context.save()
        } else {
            throw TrackerStoreError.trackerNotFound
        }
    }

    func deleteTracker(by id: UUID) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            context.delete(trackerCoreData)
            try context.save()
        } else {
            throw TrackerStoreError.trackerNotFound
        }
    }

    private func mapToTracker(_ trackerCoreData: TrackerCoreData) -> Tracker? {
        guard
            let id = trackerCoreData.id,
            let title = trackerCoreData.title,
            let colorHex = trackerCoreData.color,
            let emoji = trackerCoreData.emoji,
            let scheduleData = trackerCoreData.schedule as? NSData,
            let schedule = daysValueTransformer.reverseTransformedValue(scheduleData) as? [Weekday],
            let color = uiColorMarshalling.color(from: colorHex),
            let type = trackerTypeValueTransformer.reverseTransformedValue(trackerCoreData.type) as? TrackerType
        else { return nil }
        
        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule, type: type)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
