//
//  ImageCropperScrollView.swift
//  Taber
//
//  Created by Roman Korolov on 10/31/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//

import UIKit

final class ImageCropperScrollView: UIScrollView {
    
    // MARK: Properties
    
    var visibleRectangle: CGRect {
        return CGRect(
            x: contentInset.left,
            y: contentInset.top,
            width: frame.size.width - contentInset.left - contentInset.right,
            height: frame.size.height - contentInset.top - contentInset.bottom)
    }
    
    open var scaledVisibleRectangle: CGRect {
        return CGRect(
            x: (contentOffset.x - contentInset.left) / zoomScale,
            y: (contentOffset.y - contentInset.top) / zoomScale,
            width: self.visibleRectangle.size.width / zoomScale,
            height: self.visibleRectangle.size.height / zoomScale)
    }
    
    // MARK: Initialization of objects and their parameters
    
    lazy var imageView: UIImageView! = {
        let view = UIImageView()
        return view
    }()
    
    var image: UIImage! {
        didSet {
            
            // Prepare scrollView for changing the image
            
            maximumZoomScale = 1.0
            minimumZoomScale = 1.0
            zoomScale = 1.0
            
            // Update an imageView
            
            imageView.image = image
            imageView.frame.size = image.size
            
        }
    }
    
    // MARK: Initialization
    
    // Returns an initialized Scroll View
    
    init() {
        super.init(frame: .zero)
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
