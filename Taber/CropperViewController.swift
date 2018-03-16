//
//  CropperViewController.swift
//  Taber
//
//  Created by Roman Korolov on 10/25/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//



import UIKit


final class CropperViewController: UIViewController {
    
    //  MARK: Properties
    
    var image: UIImage!
    
    @IBOutlet weak var cropView: ImageCropperView!

    private var cropViewProgrammatically: ImageCropperView!
    
    
   @IBOutlet weak var navigationView: UIView!
   
    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction func backAction(_ sender: AnyObject) {
        
        guard !cropView.isEdited else {
            
            let alertController = UIAlertController(title: "Achtung!", message:
                "All changes will be lost.", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.cancel, handler: { _ in
                
                _ = self.navigationController?.popViewController(animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cropImageAction(_ sender: AnyObject) {
        guard let image = cropView.croppedImage else {
            return
        }



        let imageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "edited") as! EditedImageViewController

        imageViewController.image = image

        //navigationController?.pushViewController(imageViewController, animated: true)

        self.present(imageViewController, animated: true, completion: nil)
    }
    
    
    
    func showOverlayAction() {
        cropView.showOverlayView()
    }
    
    
    @IBAction func showHideOverlayAction(_ sender: AnyObject) {
        if cropView.isOverlayViewActive {

            cropView.hideOverlayView(animationDuration: 0.3)

            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                //self.overlayActionView.alpha = 0

            }, completion: nil)

        } else {

            cropView.showOverlayView(animationDuration: 0.3)

            UIView.animate(withDuration: 0.3, delay: 0.3, options: UIViewAnimationOptions.curveLinear, animations: {
                //  self.overlayActionView.alpha = 1

            }, completion: nil)

        }
    }
    
    var angle: Double = 0.0
    
    @IBAction func rotateAction(_ sender: AnyObject) {

        angle += Double.pi/2

        cropView.rotate(angle, withDuration: 0.3, completion: { _ in

            if self.angle == 4 * Double.pi/2 {
                self.angle = 0.0
            }
        })
    }
    
    
    // MARK: -  Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        cropView.backgroundColor = UIColor.black
        cropView.delegate = self
        cropView.image = image
        showOverlayAction()
       
    }
}


extension CropperViewController: AKImageCropperViewDelegate {
    
    func imageCropperViewDidChangeCropRect(view: ImageCropperView, cropRect rect: CGRect) {
        //        print("New crop rectangle: \(rect)")
    }
    
}

