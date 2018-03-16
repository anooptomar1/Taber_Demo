//
//  EditedViewController.swift
//  Taber
//
//  Created by Roman Korolov on 11/7/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//



import UIKit
import Alamofire

final class EditedImageViewController: UIViewController {
    
    // MARK: Properties
    
    var image: UIImage!
    
    var colors: [String]?
    var tags: [String]?
    
    @IBOutlet weak var imageView: UIImageView!


    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var progressIndicator: UIProgressView!

    
    
    // MARK: Actions
    
    @IBAction func backAction(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showListAction(_ sender: UIButton) {
        
        if presentingViewController != nil {
            
            _ = navigationController?.popToRootViewController(animated: true)
            
        } else {
            
            _ = navigationController?.popToViewController(navigationController!.viewControllers[1], animated: true)
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.backgroundColor = .black
        imageView.image = image
        progressIndicator.progress = 0.0
        progressIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        
        upload(image: image,
               progressCompletion: { [unowned self] (percent) -> Float in
                self.progressIndicator.setProgress(percent, animated: true)
                return percent
            },
               completion: { [unowned self] (tags, colors) in
                self.progressIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.tags = tags
                self.colors = colors
                
        })
        
    }
}

// MARK: Networking call

extension EditedImageViewController {
    
    func upload(image: UIImage,
                progressCompletion: @escaping (_ percent: Float) -> Float,
                completion: @escaping (_ coordinates: [String],_ size: [String]) -> Void) {
        guard let imageData = UIImagePNGRepresentation(image) else {
            print("Can't get PNG representation of UIImage")
            return
        }
        

        
        
        // TODO: Move the networking part to Router
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(imageData, withName: "file", fileName: "image.png", mimeType: "file/jpeg")
        }, to: "http://66.70.186.204:18080/api/v1/documents/upload",
           headers: ["Content-Type" : "file/png"]) { (encodingResults) in
            switch encodingResults {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    progressCompletion(Float(progress.fractionCompleted))
                })
                upload.validate()
                upload.responseJSON(completionHandler: { (response) in
                    guard response.result.isSuccess else {
                        print("Error while uploading file: \(String(describing: response.result.error))")
                        completion([String](), [String]())
                        return
                    }
                    guard let responseJSON = response.result.value as? [String : Any], let imageId = responseJSON["id"] as? String
                        
                        else {
                            print("Invalid information received from server")
                            completion([String](), [String]())
                            return
                    }
                    print("ImageID is: \(imageId)")
                    //completion()
                    self.downloadCoordinates(imageID: imageId, completion: { (data) in
                        completion(data, [String]())
                    })
                    
                    //completion([String](), [String]())
                })
            case .failure(let encodingError):
                print(encodingError)
                completion([String](), [String]())
            }
        }
    }
    
    
    
    func downloadCoordinates(imageID: String,completion:  @escaping ([String]) -> Void) {
        Alamofire.request("http://66.70.186.204:18080/api/data/v1/documentPages/search/documentIdAndPageNumber", method: .get, parameters: ["documentId" : imageID, "pageNumber" : 1], headers: ["Content-Type" : "application/json"])
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching data: \(String(describing: response.result.error))")
                    completion([String]())
                    return
                }
                
                guard let responseJSON = response.result.value as? [String : Any], let arrayOfDictionaries = responseJSON["_embedded"] as? [String : Any], let documentPages = arrayOfDictionaries["documentPages"] as? [[String : Any]], let firstPageId = documentPages.first, let pageId = firstPageId["id"] as? String else {
                    print("Invalid information received from the server")
                    completion([String]())
                    return
                }
                print("Page ID is: \(pageId)")
                //completion([String]())
                self.getTheBlocks(pageID: pageId, completion: { (data) in
                    completion([String]())
                })
        }
    }
    
    
    
    
    func getTheBlocks(pageID: String, completion: @escaping ([String]) -> Void) {
        Alamofire.request("http://66.70.186.204:18080/api/data/v1/blocks/search/pageId", method: .get, parameters: ["pageId" : pageID], headers: ["Content-Type" : "application/json"])
            .responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching data \(String(describing: response.result.error))")
                    completion([String]())
                    return
                }
                
                
                
                guard let responseJSON = response.result.value as? [String : Any] else {
                    print("Invalid information received from the server")
                    completion([String]())
                    return
                }
                print(responseJSON)
                completion([String]())
        }
    }
    
}


