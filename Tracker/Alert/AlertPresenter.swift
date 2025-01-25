import UIKit

protocol AlertPresenterProtocol {
    func showAlert(with model: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol {
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
        
    func showAlert(with model: AlertModel) {
        guard let delegate else {
            assertionFailure("delegate is nullable")
            return
        }
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: model.buttonText, style: .destructive) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        
        if let cancelButtonText = model.cancelButtonText {
            let cancelAction = UIAlertAction(title: cancelButtonText, style: .cancel)
            alert.addAction(cancelAction)
            alert.preferredAction = cancelAction
        }
        
        alert.view.accessibilityIdentifier = "Alert"
        delegate.present(alert, animated: true, completion: nil)
    }
}
