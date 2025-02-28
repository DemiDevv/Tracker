import UIKit

extension UIDatePicker {
    func updateAppearance() {
        self.overrideUserInterfaceStyle = .light // Оставляем цифры черными
        self.setValue(UIColor.black, forKey: "textColor") // Устанавливаем черный цвет цифр
        self.backgroundColor = Colors.datePickerColor
    }
}
