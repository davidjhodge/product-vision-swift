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
    
    var firstLaunch = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Product Vision"
        
        picker.delegate = self
        
        spinner.color = UIColor.lightGray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLaunch
        {
            showCamera()

            firstLaunch = false
        }
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
            spinner.startAnimating()
            
            PVSessionManager.sharedManager.findSimilarProducts(image: chosenImage, completionBlock: { (success, error, response) -> Void in
                
                if (success) {
                    // SUCCESS! Proceed
                    if let products = response as? Array<Product>
                    {
                        // Show products on next screen
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        
                        if let vc = storyboard.instantiateViewController(withIdentifier: "ResultsViewController") as? ResultsViewController
                        {
                            vc.products = products
                            
                            vc.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: self, action: nil)
                            
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
                else {
                    if let errorMessage = error
                    {
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    
                        print(errorMessage)
                    }
                }
                
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
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
