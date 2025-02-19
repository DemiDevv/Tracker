import UIKit

enum Colors {
    static let viewBackground = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.blackNightYp
        } else {
            return UIColor.blackDayYp
        }
    }
    
    static let fontColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.blackDayYp
        } else {
            return UIColor.blackNightYp
        }
    }
    
    static let buttonDisabledColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.blackDayYp
        } else {
            return UIColor.white
        }
    }
    
    static let tableCellColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.backgroundDayYp
        } else {
            return UIColor.backgroundNightYp
        }
    }
}
