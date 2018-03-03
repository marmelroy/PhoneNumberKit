//
//  ViewController.swift
//  Example
//
//  Created by Hugo Fouquet on 03/03/2018.
//  Copyright © 2018 Roy Marmelstein. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ViewController: UIViewController, PhoneNumberValidationCodeDataSource, PhoneNumberValidationCodeDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var validationCodeView: PhoneNumberValidationCode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validationCodeView.defaultText = "-"
        validationCodeView.delegate = self
        validationCodeView.dataSource = self
        self.setStatus("started", .gray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: PhoneNumber Validation Code DataSource
    
    func validationCode(_ validationCode: PhoneNumberValidationCode, labelAtIndex index: UInt) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        label.textAlignment = .center
        label.backgroundColor = .white
        label.textColor = .red
        return label
    }
    
    // MARK: PhoneNumber Validation Code Delegate
    
    func validationCode(_ validationCode: PhoneNumberValidationCode, willEnter text: String) -> Bool {
        print("willEnter:", text)
        return text != "1"
    }
    
    func validationCode(_ validationCode: PhoneNumberValidationCode, didEnter text: String) {
        print("didEnter:", text)
        self.setStatus("waiting", .darkGray)
    }
    
    func validationCode(_ validationCode: PhoneNumberValidationCode, didFinish text: String) {
        print("Finish:", text)
        let alertController = self.createAlert()
        self.present(alertController, animated: true) {
            self.loadData { success in
                if !success {
                    self.validationCodeView.reset()
                    self.setStatus("reseted", .red)
                } else {
                    self.setStatus("fnished", .green)
                }
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Methods
    
    func createAlert() -> UIAlertController {
        let alert = UIAlertController(title: "", message: "Loading...", preferredStyle: .alert)
        return alert
    }
    
    func loadData(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // in half a second...
            completion(self.validationCodeView.text.range(of: "2") != nil)
        }
    }

    func setStatus(_ text: String, _ color: UIColor) {
        self.statusLabel.text = text.uppercased()
        self.statusLabel.textColor = color
    }
    
}

