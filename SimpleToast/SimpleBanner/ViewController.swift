//
//  ViewController.swift
//  SimpleBanner
//
//  Created by Glenn Posadas on 9/16/21.
//

import UIKit

class ViewController: UIViewController {
  
  // MARK: - Properties
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var animated: UISwitch!
  
  // MARK: - Functions
  // MARK: Overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  // MARK: - Events
  
  @IBAction func showToast(_ sender: Any) {
    guard let message = textField.text else { return }
    
    if animated.isOn {
      SimpleToast(text: message, delegate: self, data: message)
        .show()
    } else {
      SimpleToast(text: message, delegate: self, data: message)
        .show(animated: false)
    }
  }
}

// MARK: - SimpleToastDelegate

extension ViewController: SimpleToastDelegate {
  func userdidTapToast(_ toast: SimpleToast, withData data: Any?) {
    print("userdidTapToast with data: \(String(describing: data))")
  }
}
