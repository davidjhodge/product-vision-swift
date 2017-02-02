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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        shootPhoto()
    }
    
    //MARK: - Delegates
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        // Here's the image we picked
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2

        
        dismiss(animated:true, completion: nil) //5
    }
    
    func shootPhoto() {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        present(picker,animated: true,completion: nil)
    }
}
