//
//  ImageCropperCropViewConfiguration.swift
//  Taber
//
//  Created by Roman Korolov on 11/7/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//



import UIKit

// Overlay view configuration struct.
public struct ImageCropperCropViewConfiguration {
    
    public init() {}
    
    //  MARK: Crop rectangle
    
    /// Delay before the crop rectangle will scale to fit cropper view frame edges.
    public var zoomingToFitDelay: TimeInterval = 1.0
    
    // Animation options for layout transitions.

    public var animation: (duration: TimeInterval, options: UIViewAnimationOptions) = (duration: 0.3, options: .curveEaseInOut)
    
    // Edges insets for crop rectangle. Static values for programmatically rotation.
    
    public var cropRectInsets = UIEdgeInsetsMake(20, 20, 20, 20)
    
    // The smallest value for the crop rectangle sizes. Initial value of this property is 60 pixels width and 60 pixels height.
    public var minCropRectSize: CGSize = CGSize(width: 60, height: 60)
    
    // Touch view where will be drawn the corner.
    public var cornerTouchSize: CGSize = CGSize(width: 30.0, height: 30.0)
    
    // Thickness for edges touch area. This touch view is centered on the edge line.

    public var edgeTouchThickness: (vertical: CGFloat, horizontal: CGFloat) = (vertical: 20.0, horizontal: 20.0)
    
    //  MARK: Visual Appearance
    
    // Overlay visual configuration.
    public var overlay = ImageCropperCropViewConfigurationOverlay()
    
    // Edges visual configuration.
    public var edge = ImageCropperCropViewConfigurationEdge()
    
    // Corners visual configuration.
    public var corner = ImageCropperCropViewConfigurationCorner()
    
    // Grid visual configuration.
    public var grid = ImageCropperCropViewConfigurationGrid()
}

