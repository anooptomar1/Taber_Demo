//
//  ImageCropperCropViewConfigurationEdge.swift
//  Taber
//
//  Created by Roman Korolov on 11/7/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//


import UIKit

// Edges configuration struct.
public struct ImageCropperCropViewConfigurationEdge {
    
    // A Boolean value that determines whether the edge view is hidden.
    public var isHidden: Bool = false
    
    // Line width for normal edge state.
    public var normalLineWidth: CGFloat = 1.0
    
    // Line width for highlighted edge state.
    public var highlightedLineWidth: CGFloat = 3.0
    
    // Line color for normal edge state.
    public var normalLineColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
    
    
    // Line color for highlighted edge state.
    public var highlightedLineColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
}

