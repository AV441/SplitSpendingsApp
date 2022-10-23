//
//  ShakeAnimation.swift
//  SplitSpendings
//
//  Created by Андрей on 18.10.2022.
//

import UIKit

func createItemShakeAnimation() -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "transform.rotation.z")
    animation.autoreverses = true
    animation.repeatCount = Float.greatestFiniteMagnitude
    animation.duration = 0.15
    animation.fromValue = -0.02
    animation.toValue = 0.02
    return animation
}

func createViewShakeAnimation(center: CGPoint) -> CABasicAnimation {
    let animation = CABasicAnimation(keyPath: "transform.move.x")
    animation.autoreverses = true
    animation.repeatCount = 3
    animation.duration = 0.07
    animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5,
                                                   y: center.y))
    animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5,
                                                 y: center.y))
    return animation
}
