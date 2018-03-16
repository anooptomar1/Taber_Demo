//
//  mageCropperCropViewConfigurationOverlay.swift
//  Taber
//
//  Created by Roman Korolov on 11/7/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//

import UIKit

// Overlay configuration struct.
public struct ImageCropperCropViewConfigurationOverlay {
    
    // The view’s background color.
    public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)

    public var isBlurEnabled: Bool = true
    
    // The intensity of the blur effect.
    public var blurStyle: UIBlurEffectStyle = .dark
    
    // The blur effect alpha value.
    public var blurAlpha: CGFloat = 0.6
}
