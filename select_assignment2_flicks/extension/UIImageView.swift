//
//  UIImageView.swift
//  select_assignment2_flicks
//
//  Created by Hoa Tran on 7/10/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageWithFadingIn(image: UIImage) {
        alpha = 0
        self.image = image
        UIView.animateWithDuration(1.5) {
            self.alpha = 1
        }
    }
    
    func setWithImageWithVerticalFlipping(image: UIImage) {
        UIView.transitionWithView(self, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft , animations: {
            self.image = image
            }, completion: nil)
    }
}
