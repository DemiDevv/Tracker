import UIKit

@objc
final class TrackersValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let trackers = value as? [Tracker] else { return nil }
        
        do {
            let data = try JSONEncoder().encode(trackers)
            return data
        } catch {
            print("Error encoding trackers: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        
        do {
            let trackers = try JSONDecoder().decode([Tracker].self, from: data as Data)
            return trackers
        } catch {
            print("Error decoding trackers: \(error)")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            TrackersValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: TrackersValueTransformer.self))
        )
    }
}
