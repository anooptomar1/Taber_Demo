//
//  PreviewView.swift
//  Taber
//
//  Created by Roman Korolov on 2/27/18.
//  Copyright © 2018 Escaliber LLC. All rights reserved.

import UIKit
import AVFoundation

class PreviewView: UIView {
    
    private var maskLayer = [CAShapeLayer]()
    
    
    // MARK: AV capture properties
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
        fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
    return layer
    }
    
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    func drawRectangleOverlay(_ points: [CGPoint]) {
        let overlay = CAShapeLayer()
        overlay.fillColor = UIColor.red.cgColor
        overlay.strokeColor = UIColor.black.cgColor
        overlay.opacity = 0.6
        let drawingPath = UIBezierPath()
        drawingPath.move(to: points.first!)
        points.forEach { (point) in
            drawingPath.addLine(to: point)
        }
        drawingPath.close()
        overlay.path = drawingPath.cgPath
        maskLayer.append(overlay)
        layer.insertSublayer(overlay, at: 1)
    }
    
    
    
    func removeRectangleOverlay() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
    
}


