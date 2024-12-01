import Foundation

@objc final class TrackerTypeValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    // Преобразование enum в String для хранения
    override func transformedValue(_ value: Any?) -> Any? {
        guard let type = value as? TrackerType else { return nil }
        switch type {
        case .habbit:
            return "habbit"
        case .event:
            return "event"
        }
    }

    // Преобразование String обратно в enum
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let typeString = value as? String else { return nil }
        switch typeString {
        case "habbit":
            return TrackerType.habbit
        case "event":
            return TrackerType.event
        default:
            return nil
        }
    }

    // Регистрация трансформера
    static func register() {
        ValueTransformer.setValueTransformer(
            TrackerTypeValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: TrackerTypeValueTransformer.self))
        )
    }
}
