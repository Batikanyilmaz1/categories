import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    @IBAction func buttonPressed(_ sender: Any) {
        dismissKeyboardFrom(view: textField)
    }

    @objc func dismissKeyboardFrom(view: UIView) {
        view.resignFirstResponder()
        // or view.endEditing()
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
