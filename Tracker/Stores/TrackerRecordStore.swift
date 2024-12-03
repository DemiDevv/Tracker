import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Добавить новый трекер
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try performSync { context in
            Result {
                let trackerRecordCoreData = TrackerRecordCoreData(context: context)
                updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
                try context.save()
            }
        }
    }
    
    // Обновить существующую запись
    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with record: TrackerRecord) {
        trackerRecordCoreData.date = record.date
        trackerRecordCoreData.trackerID = record.trackerID
    }

    // Получить все записи трекеров
    func fetchAllTrackerRecords() throws -> [TrackerRecord] {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                let trackerRecordCoreDataList = try context.fetch(fetchRequest)
                
                return trackerRecordCoreDataList.compactMap { trackerRecordCoreData in
                    guard let date = trackerRecordCoreData.date,
                          let trackerID = trackerRecordCoreData.trackerID else { return nil }
                    return TrackerRecord(trackerID: trackerID, date: date)
                }
            }
        }
    }

    // Получить запись по ID трекера
    func fetchTrackerRecord(by trackerID: UUID) throws -> TrackerRecord? {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)
                
                guard let trackerRecordCoreData = try context.fetch(fetchRequest).first else {
                    return nil
                }

                guard let date = trackerRecordCoreData.date,
                      let trackerID = trackerRecordCoreData.trackerID else { return nil }

                return TrackerRecord(trackerID: trackerID, date: date)
            }
        }
    }

    // Удалить запись по ID трекера
    func deleteTrackerRecord(by trackerID: UUID) throws {
        try performSync { context in
            Result {
                let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)

                if let trackerRecordCoreData = try context.fetch(fetchRequest).first {
                    context.delete(trackerRecordCoreData)
                    try context.save()
                }
            }
        }
    }
    
    // Вспомогательная функция для выполнения синхронных операций с контекстом
    private func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
}
