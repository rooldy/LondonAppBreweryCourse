//
//  PaddingLabel.swift
//  StoryExercise
//
//  Created by Daniel Asher on 10/12/2017.
//  Copyright © 2017 LEXI LABS. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
final public class PaddingLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor ?? UIColor.clear.cgColor
        }
    }
    
    // MARK: IBInspectables
    @IBInspectable public var viewShadowColor: UIColor = .darkGray {
        didSet { setNeedsLayout() }
    }
    @IBInspectable public var viewShadowRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    @IBInspectable public var viewShadowOpacity: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    @IBInspectable public var viewShadowOffset: CGPoint = CGPoint(x: 0, y: 0) {
        didSet { setNeedsLayout() }
    }
    @IBInspectable public var topInset: CGFloat = 5.0 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable public var bottomInset: CGFloat = 5.0 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable public var leftInset: CGFloat = 5.0 {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable public var rightInset: CGFloat = 5.0 {
        didSet { setNeedsDisplay() }
    }
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    public override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += topInset + bottomInset
        contentSize.width += leftInset + rightInset
        return contentSize
    }
    var shadowView: UIView?
    func configureShadowView() {
        guard let shadowView = shadowView else { return }
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = viewShadowColor.cgColor
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowView.layer.shadowOffset = CGSize(width: viewShadowOffset.x, height: viewShadowOffset.y)
        shadowView.layer.shadowOpacity = Float(viewShadowOpacity)
        shadowView.layer.shadowRadius = viewShadowRadius
        shadowView.layer.masksToBounds = false
        shadowView.clipsToBounds = false
    }
    public override func layoutSubviews() {
        super.layoutSubviews()

        if viewShadowOpacity > 0 {
            if shadowView == nil {
                let shadowView = UIView(frame: frame)
                self.shadowView = shadowView
                configureShadowView()
                superview?.addSubview(shadowView)
                superview?.bringSubviewToFront(self)
                
                
                // All edges of the item. This property affects top, bottom, leading and trailing.
                // edges = top, bottom, left, right
                //                constrain(self, shadowView) { this, shadow in
                //                    shadow.edges == this.edges
                //                }
                
                // Add the constraint to the view
                shadowView.translatesAutoresizingMaskIntoConstraints = false
                let topConstraint = NSLayoutConstraint(item: shadowView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
                let bottomConstraint = NSLayoutConstraint(item: shadowView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
                let leadingConstraint = NSLayoutConstraint(item: shadowView, attribute: .leading, relatedBy: .equal, toItem: nil, attribute: .leading, multiplier: 1, constant: 0)
                let trailingConstraint = NSLayoutConstraint(item: shadowView, attribute: .trailing, relatedBy: .equal, toItem: nil, attribute: .trailing, multiplier: 1, constant: 0)
                shadowView.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
                self.layoutIfNeeded()
            } else {
                configureShadowView()
            }
        }
    }
}
