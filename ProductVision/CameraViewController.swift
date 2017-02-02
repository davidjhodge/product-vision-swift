//
//  CameraViewController.swift
//  ProductVision
//
//  Created by David Hodge on 2/1/17.
//  Copyright © 2017 Genesis Apps. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let picker = UIImagePickerController()
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Product Vision"
        
        picker.delegate = self
        
        spinner.isHidden = true
        spinner.color = UIColor.lightGray
        spinner.hidesWhenStopped = true
        
        showCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = view.center
    }
    
    // MARK: Actions
    @IBAction func showCameraPressed(_ sender: Any)
    {
        showCamera()
    }

    
    //MARK: - Delegates
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        // Here's the image we picked
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            PVSessionManager.sharedManager.analyzeImage(image: chosenImage, completionHandler: { (success, error, response) -> Void in
                
                if (success) {
                    // SUCCESS! Proceed
                }
                else {
                    if let errorMessage = error?.localizedCapitalized
                    {
                        print(errorMessage)
                    }
                }
                
            })

        }
        
        dismiss(animated:true, completion: nil)
    }
    
    func showCamera() {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        present(picker,animated: true,completion: nil)
    }
}
