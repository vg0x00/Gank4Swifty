//
//  PostViewController.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/24/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var articleTypePickerView: UIPickerView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneIndicator: UIButton! {
        didSet { doneIndicator.alpha = 0 }
    }
    @IBOutlet weak var failureIndicator: UIButton! {
        didSet { failureIndicator.alpha = 0 }
    }
    
    // NOTE: disable android and meizi post
    let types = ["iOS", "休息视频", "拓展资源", "前端", "瞎推荐", "App"]
    lazy var selectedArticleType = types[defaultPickerIndex]
    weak var sourceViewController: UIViewController?
    var shouldDismiss = false
    let apiManager = APIManager()
    let defaultPickerIndex = 2
    override func viewDidLoad() {
        super.viewDidLoad()

        addShowDimViewFromSourceViewController()
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        shouldDismiss = true
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tapGestureTriggered(_ sender: UITapGestureRecognizer) {
        shouldDismiss = true
        dismiss(animated: true, completion: nil)
    }

    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let url = urlTextField.text,
            let desc = descTextField.text,
            let author = authorTextField.text else { return }

        loadingIndicator.startAnimating()
        apiManager.postGankAriticle(url: url, desc: desc, who: author, type: selectedArticleType, failureHandler: { (error) in
            DispatchQueue.main.async { [unowned self] in
                self.loadingIndicator.stopAnimating()
                UIView.animate(withDuration: 1.5, animations: {
                    self.failureIndicator.alpha = 1
                }, completion: { (completed) in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }) { (data) in
            DispatchQueue.main.async { [unowned self] in
                self.loadingIndicator.stopAnimating()
                let jsonDecoder = JSONDecoder()
                guard let result = try? jsonDecoder.decode(PostResponse.self, from: data) else {
                    UIView.animate(withDuration: 1.5, animations: {
                        self.failureIndicator.alpha = 1
                    }, completion: { (completed) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    return
                }
                if result.error {
                    UIView.animate(withDuration: 1.5, animations: {
                        self.failureIndicator.alpha = 1
                    }, completion: { (completed) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    return
                }
                UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.transitionCurlUp, animations: {
                    self.doneIndicator.alpha = 1
                }, completion: { (completed) in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }

    private func addShowDimViewFromSourceViewController() {
        guard let sourceViewController = sourceViewController else { return }
        let dimView = IBDesignableView(frame: sourceViewController.view.frame)
        dimView.backgroundColor = UIColor(hex: 0x595959, alpha: 0.7)
        dimView.alpha = 0
        sourceViewController.view.addSubview(dimView)
        UIView.animate(withDuration: 0.3) {
            dimView.alpha = 1
        }
    }

    private func removeHideDimViewFromSourceViewController() {
        guard let sourceViewController = sourceViewController else { return }
        let dimViews = sourceViewController.view.subviews.filter{ $0 is IBDesignableView }
        dimViews.first?.removeFromSuperview()
    }

    private func validateUrl(string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        urlTextField.becomeFirstResponder()
        articleTypePickerView.selectRow(defaultPickerIndex, inComponent: 0, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeHideDimViewFromSourceViewController()
        view.endEditing(true)
    }

}

extension PostViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
}

extension PostViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedArticleType = types[row]
    }
}

extension PostViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("debug text field did end editing")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            urlTextField.resignFirstResponder()
            authorTextField.resignFirstResponder()
            descTextField.becomeFirstResponder()
            descTextField.backgroundColor = .white
        case 1:
            urlTextField.resignFirstResponder()
            authorTextField.becomeFirstResponder()
            authorTextField.backgroundColor = .white
            descTextField.resignFirstResponder()
        default:
            urlTextField.resignFirstResponder()
            authorTextField.resignFirstResponder()
            descTextField.resignFirstResponder()
        }
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("debug ------ \(textField.tag): url: \(urlTextField.isEditing) - \(urlTextField.isEnabled) - \(urlTextField.isFocused)")

        if textField.tag == 0 && !shouldDismiss { // NOTE: url textField validation
            guard let contentString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !contentString.isEmpty  else { return false }
            if validateUrl(string: contentString) {
                return true
            }
            textField.layer.borderColor = UIColor(hex: 0xFF8B94).cgColor
            textField.layer.borderWidth = 2
            textField.layer.cornerRadius = 5
            textField.layer.masksToBounds = true
            textField.text = "url 输入有误, 请重新输入"
            textField.textColor = UIColor(hex: 0xB4BABA)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                textField.layer.borderColor = nil
                textField.layer.cornerRadius = 0
                textField.layer.borderWidth = 0
                textField.textColor = .black
                textField.text = nil
            }
            return false
        }
        return true
    }
}
