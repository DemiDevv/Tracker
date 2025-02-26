import Foundation

@objc final class TrackerTypeValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let type = value as? TrackerType else { return nil }
        switch type {
        case .habit:
            return "habit"
        case .event:
            return "event"
        case .editHabit:
            return "editHabit"
        case .editEvent:
            return "editEvent"
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let typeString = value as? String else { return nil }
        switch typeString {
        case "habit":
            return TrackerType.habit
        case "event":
            return TrackerType.event
        default:
            return nil
        }
    }

    static func register() {
        ValueTransformer.setValueTransformer(
            TrackerTypeValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: TrackerTypeValueTransformer.self))
        )
    }
}
