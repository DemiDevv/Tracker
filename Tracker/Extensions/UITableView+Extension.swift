import UIKit

extension UITableView {

  @IBInspectable
  var isEmptyHeaderHidden: Bool {
        get {
          return tableHeaderView != nil
        }
        set {
          if newValue {
              tableHeaderView = UIView(frame: .zero)
          } else {
              tableHeaderView = nil
          }
       }
    }
}
