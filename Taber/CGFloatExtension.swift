//
//  CGFloatExtension.swift
//  Taber
//
//  Created by Roman Korolov on 11/7/17.
//  Copyright © 2017 Escaliber LLC. All rights reserved.
//

import UIKit

// Rounds the value to the nearest with certain precision

extension CGFloat {
    public func cropperRoundTo(precision: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(precision))
        return (self * divisor).rounded() / divisor
    }
}
// Rounds the value to the nearest with certain multiplier

public func cropperRound(x: CGFloat, multiplier: CGFloat) -> CGFloat {
    return multiplier * Darwin.round(x / multiplier)
}
    

