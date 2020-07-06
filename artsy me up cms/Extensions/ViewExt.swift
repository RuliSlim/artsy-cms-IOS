//
//  UIViewExt.swift
//  artsy me up cms
//
//  Created by Ruli on 05/07/20.
//

import UIKit

fileprivate var defaultFrame: [ObjectIdentifier: CGFloat] = [:]

/// extension to bind any object to keyboard when it shows up
extension UIView {
    var storedProperty: CGFloat? {
        get {return defaultFrame[ObjectIdentifier(self)]}
        set {defaultFrame[ObjectIdentifier(self)] = newValue}
    }
    
    /// function to move any object if the object overlapping with keyboard when its showed up
    func bindToKeyboard() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let startingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endFrame.origin.y - startingFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: KeyframeAnimationOptions.init(rawValue: curve), animations: {
            if (self.frame.origin.y + self.frame.size.height) > endFrame.origin.y {
                self.storedProperty = self.frame.origin.y
                self.frame.origin.y += deltaY
            }
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let initialFrame = self.storedProperty {
            self.frame.origin.y = initialFrame
        }
    }
}
