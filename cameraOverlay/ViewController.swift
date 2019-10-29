//
//  ViewController.swift
//  cameraOverlay
//
//  Created by Yadav, Sahil on 22/10/19.
//  Copyright © 2019 Yadav, Sahil. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Camera overlay view
    var cameraView: UIView!
    
    // Camera object
    let myCamera = UIImagePickerController()
    
    // Image object used to pass the captured image for previewing
    var image: UIImage! = nil
    
    @IBAction func captureBtnWasPressed(_ sender: Any) {
        cameraView = UIView()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            if UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera) != nil{
                // Use front camera and add overlay on it
                myCamera.sourceType = .camera
                myCamera.cameraDevice = .front
                myCamera.delegate = self
                myCamera.showsCameraControls = false
                myCamera.cameraOverlayView = self.addOverlay()
                self.present(myCamera, animated: false, completion: nil)
            }
        }else{
            print("no camera device found")
        }
    }
    
    @IBAction func usedPhoto(){
        self.performSegue(withIdentifier: "nextPageSegue", sender: nil)
    }
    
    // Capture the image and show it on PreviewImageViewController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        myCamera.dismiss(animated: false, completion: {
            // Remove the camera
            for each in self.view.subviews{
                if each.tag == 101{
                    each.removeFromSuperview()
                }
            }
            
            // Add the preview
            let view: UIImageView = UIImageView()
            view.image = info[.originalImage] as? UIImage
//            self.image = view.image

            
            // Add retake button
            let button: UIButton = UIButton(type: .custom)
            button.setTitle("Retake Photo", for: .normal)
            button.frame = CGRect(x: self.view.frame.minX + 70, y: self.view.frame.maxY - 101, width: 246, height: 53)
            button.layer.cornerRadius = 25
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.addTarget(self, action: #selector(self.captureBtnWasPressed), for: .touchUpInside)
            
            // Add use photo button
            let qbutton: UIButton = UIButton(type: .custom)
            qbutton.setTitle("Save and Continue", for: .normal)
            qbutton.frame = CGRect(x: self.view.frame.maxX - 316, y: self.view.frame.maxY - 101, width: 246, height: 53)
            qbutton.layer.cornerRadius = 25
            qbutton.layer.borderWidth = 1
            qbutton.layer.borderColor = UIColor.white.cgColor
            qbutton.addTarget(self, action: #selector(self.usedPhoto), for: .touchUpInside)
            
            // The base of transparent view
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: self.view.frame.maxY - 149, width: self.view.bounds.width, height: 149), cornerRadius: 0)
            path.usesEvenOddFillRule = false
            
            // Adding the canvas as a sublayer
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = .evenOdd
            fillLayer.opacity = 0.7
            
            // Add everything
            self.view.addSubview(view)
            self.view.addSubview(button)
            self.view.addSubview(qbutton)
            
            
            view.layer.addSublayer(fillLayer)
            view.frame = self.view.frame
        })
    }
    
    
    // Shoot the camera!
    @IBAction func didPressShootButton(){
        myCamera.takePicture()
    }
    
    // Used to skip the taking picture step when the camera is open
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        myCamera.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "nextPageSegue", sender: nil)
        })
    }
    

    // Deg2Rad. Meh
    func deg2rad(_ number: Double) -> CGFloat{
        return CGFloat(number * Double.pi/180)
    }
    
    // Meh
    func addCameraButton(_ cameraView: UIView){
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "camera"), for: .normal)
        button.isUserInteractionEnabled = true
        button.frame = CGRect(x: self.view.center.x-45, y: self.view.center.y + 355, width: 90, height: 90)
        button.addTarget(self, action: #selector(self.didPressShootButton), for: .touchUpInside)
        cameraView.addSubview(button)
        
    }
    
    // Meh
    func addSkipButton(_ cameraView: UIView){
        let skipButton = UIButton(type: .custom)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.isUserInteractionEnabled = true
        skipButton.frame = CGRect(x: self.view.frame.minX, y: self.view.frame.maxY - 50, width: 70, height: 50)
        skipButton.addTarget(self, action: #selector(self.imagePickerControllerDidCancel), for: .touchUpInside)
        cameraView.addSubview(skipButton)
    }
    
    // Combination of Meh
    func addSilhouette(_ cameraView: UIView){
        // The base canvas on which everything else is put
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), cornerRadius: 0)
        
        // Semicircle for the silhouette
        let semicircle = UIBezierPath(arcCenter: CGPoint(x: self.view.center.x, y: self.view.center.y), radius: 200.0, startAngle: deg2rad(0), endAngle: deg2rad(180), clockwise: false)
        
        // Chin area of the silhouette
        let freeform = UIBezierPath()
        freeform.move(to: CGPoint(x: self.view.center.x - 200, y: self.view.center.y))
        freeform.addCurve(to: CGPoint(x: self.view.center.x + 200, y: self.view.center.y), controlPoint1: CGPoint(x: self.view.center.x - 180, y: self.view.center.y + 450), controlPoint2: CGPoint(x: self.view.center.x + 180, y: self.view.center.y + 450))
        
        path.append(semicircle)
        path.append(freeform)
        path.usesEvenOddFillRule = true
        
        // Adding the canvas as a sublayer
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.opacity = 0.7
        
        
        cameraView.layer.addSublayer(fillLayer)
    }
    
    // Compile all the above Mehs.
    func addOverlay() -> UIView? {
        self.addSilhouette(cameraView)
        self.addCameraButton(cameraView)
        self.addSkipButton(cameraView)
        
        cameraView.frame = self.view.frame
        cameraView.tag = 101
        return cameraView
    }
}


// <a target="_blank" href="https://icons8.com/icons/set/camera">Camera</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>
