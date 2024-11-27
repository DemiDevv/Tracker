import UIKit

@objc
class ColorTransformer: ValueTransformer {
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
        
            if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                return color
            }
        } catch {
            print("Error unarchiving UIColor: \(error)")
        }
        return nil
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            ColorTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: ColorTransformer.self))
        )
    }
}
