import UIKit

extension UITableView {

  @IBInspectable
  var isEmptyHeaderHidden: Bool {
        get {
          tableHeaderView != nil
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
