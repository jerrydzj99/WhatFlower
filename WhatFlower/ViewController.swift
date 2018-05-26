//
//  ViewController.swift
//  WhatFlower
//
//  Created by Jerry Ding on 2018-05-25.
//  Copyright © 2018 Jerry Ding. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userPickedImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            userPickedImageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("could not convert to ciimage") }
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("loading coreml model failed") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            let classification = request.results?.first as? VNClassificationObservation
            
            self.navigationItem.title = classification?.identifier.capitalized
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("error performing request \(error)")
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

