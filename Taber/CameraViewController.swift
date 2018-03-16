//
//  ViewController.swift
//  Taber
//
//  Created by Roman Korolov on 9/25/17.


import UIKit
import AVFoundation
import Photos
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        setupVision()
        
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] (granted) in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default: setupResult = .notAuthorized
        }
        
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            
            switch self.setupResult {
            case .success:
                self.previewView.session = self.session
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("Tbler doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "Tbler", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { (_) in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                
                
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "Tbler", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
        
    }
    
    
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private static let rectangleDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
    
    @IBOutlet weak var previewView: PreviewView!
    private let session = AVCaptureSession()
    var videoInput: AVCaptureDeviceInput!
    private var videoOutput = AVCaptureVideoDataOutput()
    private var photoSettings: AVCapturePhotoSettings!
    private var photoOutput = AVCapturePhotoOutput()
    private var photoData: Data?
    private var setupResult: SessionSetupResult = .success
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var image: UIImage?
    private var renderContext: CIContext?
    private var outputImage: CIImage!
    private var visionRequests =  [VNRequest]()
    private var devicePosition: AVCaptureDevice.Position = .back

    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        
        // Add video input
        
        do {
            var defaultVideoDevide: AVCaptureDevice?
            guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            defaultVideoDevide = videoDevice
            let videoInput = try AVCaptureDeviceInput(device: defaultVideoDevide!)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                self.videoInput = videoInput
            } else {
                print("Could not add video device to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            // TODO: Setup auto-focus
            // TODO: Setup orientation
        } catch {
            print("Cound not create video device input")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add video data output
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        session.commitConfiguration()
        
    }
    
    // MARK: AVCaptureVideoDataSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        var requestOptions:[VNImageOption:Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        
        let exifOrientation = self.exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue:UInt32(exifOrientation))!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.visionRequests)
        }catch {
            print(error)
        }
        
        
    }
    
    
    // MARK: AVCapturePhotoCaptureDelegate
    
    
    //    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    //        if let error = error {
    //            print("Error capturing photo: \(error)")
    //        } else {
    //
    //            photoData = photo.fileDataRepresentation()
    //            var sourceImage = CIImage(data: photoData!)
    //            if  !visionRequests.isEmpty {
    //                guard let rectangleFeatures = findBiggestRectangle(visionRequests.first!.results as! [VNRectangleObservation]) else { return }
    //                sourceImage = self.perspectiveCorrectedImage(image: sourceImage!, observationResult: rectangleFeatures)
    //            print(rectangleFeatures.topRight)
    //            }
    //
    ////            if let rectangleFeatures = findBiggestRectangle(visionRequests.) as![VNRectangleObservation]
    ////            if let rectangleFeature = biggestRectangle(rectangles: CameraViewController.rectangleDetector?.features(in: sourceImage!) as! [CIRectangleFeature]) {
    ////                sourceImage = self.perspectiveCorrectedImage(image: sourceImage!, feature: rectangleFeature)
    //
    //
    //            UIGraphicsBeginImageContext(CGSize(width: (sourceImage?.extent.size.height)!, height: (sourceImage?.extent.size.width)!))
    //            UIImage(ciImage: sourceImage!, scale: 1.0, orientation: .right).draw(in: CGRect(x: 0, y: 0, width: (sourceImage?.extent.size.height)!, height: (sourceImage?.extent.size.width)!))
    //            image = UIGraphicsGetImageFromCurrentImageContext()
    //            UIGraphicsEndImageContext()
    //
    //        }
    //    }
    
    
    //    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
    //        if let error = error {
    //            print("Error capturing photo: \(error)")
    //            return
    //        }
    //        self.performSegue(withIdentifier: "showImage", sender: nil)
    //    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let cropperViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cropView") as! CropperViewController
            cropperViewController.image = pickedImage
            picker.pushViewController(cropperViewController, animated: true)
        }
        
    }
    
    
    // Setup Vision Rectangle Detector
        // And what if CIRectangleDetector ???
    
    func setupVision() {
        let rectangleDetectionRequest = VNDetectRectanglesRequest(completionHandler: self.handleRectangles)
        rectangleDetectionRequest.minimumSize = 0.12
        rectangleDetectionRequest.maximumObservations = 0
        rectangleDetectionRequest.minimumAspectRatio = 0.1
        rectangleDetectionRequest.maximumAspectRatio = 0.9
        rectangleDetectionRequest.minimumConfidence = 1
        self.visionRequests = [rectangleDetectionRequest]
    }
    
    func handleRectangles(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let observations = request.results as? [VNRectangleObservation] else {
                print("No results")
                return
            }
            self.drawVisionRequestResults(observations)
        }
    }
    
    func drawVisionRequestResults(_ results: [VNRectangleObservation]) {
        previewView.removeRectangleOverlay()
        if !results.isEmpty {
            
            guard let rectangleFeatures = findBiggestRectangle(visionRequests.first!.results as! [VNRectangleObservation]) else { return }
            let biggestRectangle  = rectangleFeatures
            let biggestRectanglePoints = [biggestRectangle.topLeft, biggestRectangle.topRight, biggestRectangle.bottomRight, biggestRectangle.bottomLeft]
            let convertedPoints = biggestRectanglePoints.map {self.view.convertFromCamera($0)}
            previewView.drawRectangleOverlay(convertedPoints)
        }
    }
    
    
    //Find biggest rectangle
    
    func findBiggestRectangle(_ rectangles: [VNRectangleObservation]) -> VNRectangleObservation? {
        var halfPerimeter = 0.0
        if rectangles.isEmpty {
            print("No rectangles")
            return nil
        }
        for rectangle in rectangles {
            var biggestRectangle = rectangles.first!
            let topLeft = biggestRectangle.topLeft
            let topRight = biggestRectangle.topRight
            let bottomLeft = biggestRectangle.bottomLeft
            let width = hypotf(Float(topLeft.x - topRight.x), Float(topLeft.y - topRight.y))
            let height = hypotf(Float(topLeft.x - bottomLeft.x), Float(topLeft.y - bottomLeft.y))
            let currentHalfPerimeter = Double(height + width)
            if currentHalfPerimeter > halfPerimeter {
                halfPerimeter = currentHalfPerimeter
                biggestRectangle = rectangle
            }
            return biggestRectangle
        }
        
        return nil
    }
    
    
    
    private func perspectiveCorrectedImage(image: CIImage, observationResult: VNRectangleObservation) -> CIImage {
        return image.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft":    CIVector(cgPoint: observationResult.topLeft),
            "inputTopRight":   CIVector(cgPoint: observationResult.topRight),
            "inputBottomLeft": CIVector(cgPoint: observationResult.bottomLeft),
            "inputBottomRight":CIVector(cgPoint: observationResult.bottomRight)])
    }
    
    // Setup unwind segue
    
    @IBAction func unwindToCameraView(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: Actions
    
    // Capture Photo Button Pressed
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        if self.videoInput.device.isFlashAvailable {
            photoSettings.flashMode = .auto
        }
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    // Photo Gallery Button Pressed
    
    @IBAction func photoGalleryButtonPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    
    // MARK: Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            (segue.destination as! CropperViewController).image = image
        }
    }
    
    // MARK: ExifOrientation
    
    func exifOrientationFromDeviceOrientation() -> Int32 {
        enum DeviceOrientation: Int32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        var exifOrientation: DeviceOrientation
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = devicePosition == .front ? .bottom0ColRight : .top0ColLeft
        case .landscapeRight:
            exifOrientation = devicePosition == .front ? .top0ColLeft : .bottom0ColRight
        default:
            exifOrientation = .right0ColTop
        }
        return exifOrientation.rawValue
    }
    
}







extension UIView {
    
    
    func convertFromCamera(_ point: CGPoint) -> CGPoint {
        
        return CGPoint(x: point.x * frame.width, y: (1 - point.y) * frame.height)
        
    }
    
    
}
