import UIKit

final class Colors {
    let viewBackground = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.blackNightYp
        } else {
            return UIColor.blackDayYp
        }
    }
    
    let buttonDisabledColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.blackDayYp
        } else {
            return UIColor.white
        }
    }
    
    let tableCellColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.backgroundDayYp
        } else {
            return UIColor.backgroundNightYp
        }
    }
}
