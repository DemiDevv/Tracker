import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerStore = TrackerStore()
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: FUNCTIONS
    func addTrackerRecord(with trackerRecord: TrackerRecord) {
        let trackerRecordEntity = TrackerRecordCoreData(context: context)
        trackerRecordEntity.trackerID = trackerRecord.trackerID
        trackerRecordEntity.date = trackerRecord.date
        
        let trackerCoreData = trackerStore.getTrackerCoreData(by: trackerRecord.trackerID)
        trackerRecordEntity.tracker = trackerCoreData
        
        do {
            try context.save()
            print("✅ Record added: \(trackerRecord)")
        } catch {
            print("❌ Failed to save tracker record: \(error)")
        }
    }
    
    
    func fetchAllRecords() -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let trackerRecordsCoreDataArray = try context.fetch(fetchRequest)
            
            let trackerRecords = trackerRecordsCoreDataArray.compactMap { trackerRecordCoreData -> TrackerRecord? in
                guard
                    let trackerID = trackerRecordCoreData.trackerID,
                    let date = trackerRecordCoreData.date
                else {
                    return nil
                }
                
                return TrackerRecord(trackerID: trackerID, date: date)
            }
            
            return trackerRecords
        } catch {
            print("❌ Failed to fetch tracker records: \(error)")
            return []
        }
    }
    
    
    func deleteRecord(for trackerRecord: TrackerRecord) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerID),
            trackerRecord.trackerID as CVarArg,
            #keyPath(TrackerRecordCoreData.date),
            trackerRecord.date as CVarArg
        )

        do {
            let results = try context.fetch(fetchRequest)
            guard let recordToDelete = results.first else {
                print("❌ No record found to delete for: \(trackerRecord)")
                return
            }
            context.delete(recordToDelete)
            try context.save()
            print("✅ Record deleted: \(trackerRecord)")
        } catch {
            print("❌ Failed to delete record: \(error)")
        }
    }
}
