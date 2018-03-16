//
//  ImageCropperCropViewConfigurationGrid.swift
//  Taber
//
//  Created by Roman Korolov on 11/7/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//


import UIKit

// Grid visual configuration struct.
public struct ImageCropperCropViewConfigurationGrid {
    
    // A Boolean value that determines whether the edge view is hidden.
    public var isHidden: Bool = false
    
    /// Hide grid after user interaction.
    public var alwaysShowGrid: Bool = false
    
    // The number of vertical and horizontal lines inside the crop rectangle.
 
    public var linesCount: (vertical: Int, horizontal: Int) = (vertical: 2, horizontal: 2)
    
    // Vertical and horizontal lines width.
    public var linesWidth: CGFloat = 1.0
    
    // Vertical and horizontal lines color.
    public var linesColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.5)
}

