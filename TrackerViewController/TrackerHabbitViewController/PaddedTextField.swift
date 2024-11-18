import UIKit

class PaddedTextField: UITextField {
    
    private let textPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41)

    // Метод для отображения текста
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    // Метод для редактирования текста
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    // Метод для позиции крестика (clear button)
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let clearButtonSize = super.clearButtonRect(forBounds: bounds).size
        // Позиционирование крестика: от правого края 12 пикселей
        let clearButtonX = bounds.width - clearButtonSize.width - 12
        return CGRect(
            x: clearButtonX,
            y: (bounds.height - clearButtonSize.height) / 2,
            width: clearButtonSize.width,
            height: clearButtonSize.height
        )
    }
}


