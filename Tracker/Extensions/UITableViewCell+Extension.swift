import UIKit

extension UITableViewCell {
    
    func setCustomStyle(indexPath: IndexPath, cellCount: Int) {
        var position: Position
        switch indexPath.row {
        case 0:
            position = cellCount == 1 ? .alone : .first
        case cellCount - 1:
            position = .last
        default:
            position = .middle
        }
        
        setupCellDesign(position: position)
    }
    
    private func setupCellDesign(position: Position) {
        switch position {
        case .first:
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            self.layer.cornerRadius = 10
        case .middle:
            self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            self.layer.cornerRadius = 0
        case .last:
            self.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.width)
            self.layer.cornerRadius = 10
        case .alone:
            self.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner,
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            self.layer.cornerRadius = 10
            self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.width)
        }
    }
    
    private enum Position {
        case first, middle, last, alone
    }
}
