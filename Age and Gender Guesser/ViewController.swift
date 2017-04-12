//
//  ViewController.swift
//  Age and Gender Guesser
//
//  Created by Shane Jackson on 2017-04-11.
//  Copyright © 2017 Shane Jackson. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var image: UIImage? = nil
    var categories: [String]? = nil
    
    @IBOutlet weak var myImageView: UIImageView!

    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    
    @IBOutlet weak var stepOneButton: UIButton!
    @IBOutlet weak var stepTwoButton: UIButton!
    @IBOutlet weak var stepThreeButton: UIButton!
    
    
    @IBOutlet weak var stepOneLabel: UILabel!
    @IBOutlet weak var stepTwoLabel: UILabel!
    @IBOutlet weak var stepThreeLabel: UILabel!
    
    @IBOutlet weak var stepOneSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var stepTwoSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var stepThreeSpinner: UIActivityIndicatorView!
    
    
    @IBAction func chooseImage(_ sender: AnyObject) {
        self.image = nil
        self.categories = nil
        
        self.validateCurrentStep()
        
        self.stepOneLabel.text = ""
        self.stepTwoLabel.text = ""
        self.stepThreeLabel.text = ""
        self.stepOneSpinner.startAnimating()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        self.present(
            imagePickerController,
            animated: true,
            completion: nil
        )
    }
    
    
    @IBAction func categoriseImage(_ sender: AnyObject) {
        self.categories = nil
        
        self.validateCurrentStep()
        
        self.stepTwoLabel.text = ""
        self.stepTwoSpinner.startAnimating()
        
        let manager = CognitiveServicesManager()
        manager.retrievePlausibleTagsForImage(self.image!) { (result, error) -> (Void) in
            DispatchQueue.main.async(execute: {
                self.stepTwoSpinner.stopAnimating()
                
                if let _ = error {
                    self.stepTwoLabel.text = "❌"
                    return
                }
                
                self.categories = result
                self.validateCurrentStep()
            })
        }
        
        myImageView.image = image
        var imageWidth = image?.size.width
        var imageHeight = image?.size.height
        var aspectRatio = imageWidth!/imageHeight!
        
        myImageView.frame.size.width = self.view.frame.width * 0.7
        myImageView.frame.size.height = myImageView.frame.size.width/aspectRatio
        var midX = self.view.frame.midX
        var ypos = myImageView.frame.origin.y
        myImageView.frame.origin = CGPoint(x: midX - myImageView.frame.size.width/2 , y: self.view.frame.height * 0.6)

    }
    
    
    @IBAction func getDetails(_ sender: AnyObject) {
        
        self.stepThreeLabel.text = ""
        self.stepThreeSpinner.startAnimating()
        
        if(self.categories?.count == 0) {
            genderLabel.text = " "
            ageLabel.text =  "There is no face in the picture"
        } else  {
            genderLabel.text = "Gender: \(self.categories![0])"
            ageLabel.text = "Age: \(self.categories![1])"
        }
        
        self.stepThreeSpinner.stopAnimating()
        self.stepThreeLabel.text = "✅"

    }
    
    
    // MARK: Private Methods
    
    private func validateCurrentStep() {
        self.stepOneSpinner.stopAnimating()
        self.stepTwoSpinner.stopAnimating()
        self.stepThreeSpinner.stopAnimating()
        
        if let _ = self.image {
            self.stepOneLabel.text = "✅"
            self.stepTwoButton.isEnabled = true
        } else {
            self.stepTwoLabel.text = ""
            self.stepThreeLabel.text = ""
            self.stepTwoButton.isEnabled = false
            self.stepThreeButton.isEnabled = false
        }
        
        if let _ = self.categories {
            self.stepTwoLabel.text = "✅"
            self.stepThreeButton.isEnabled = true
        } else {
            self.stepThreeLabel.text = ""
            self.stepThreeButton.isEnabled = false
        }
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        self.stepOneLabel.text = "❌"
        self.validateCurrentStep()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismiss(animated: true, completion: nil)
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            self.image = image
        }
        self.validateCurrentStep()
    }


}

