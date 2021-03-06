//
//  BackgroundShapesView.swift
//  StoryView
//
//  Created by GEORGE QUENTIN on 05/06/2018.
//  Copyright © 2018 LEXI LABS. All rights reserved.
//

import UIKit

@IBDesignable
public class BackgroundShapesView: UIButton {

    @IBInspectable open var color: UIColor = UIColor.blue {
        didSet {
            updateBackground()
        }
    }

    @IBInspectable open var samples: Int = 20 {
        didSet {
            updateBackground()
        }
    }

    @IBInspectable open var spacing: CGFloat = 20 {
        didSet {
            updateBackground()
        }
    }

    @IBInspectable open var size: CGFloat = 40 {
        didSet {
            updateBackground()
        }
    }

    @IBInspectable open var image: UIImage? = nil {
        didSet {
            updateBackground()
        }
    }

    @IBInspectable open var imageColor: UIColor = UIColor.white {
        didSet {
            updateBackground()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateBackground()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateBackground()
    }

    func updateBackground() {
        subviews.forEach({ $0.removeFromSuperview() })
        let backgroundSquares = CGRect
            .freeSpaces(in: frame, minSize: size * 0.2, maxSize: size, spacing: spacing, attempts: samples)
            .map({ rect -> UIView in
                let rotation = CGFloat.random(min: 0, max: 360)
                if image != nil {
                    let newImage = UIImageView(frame: rect)
                    newImage.image = image?.withRenderingMode(.alwaysOriginal)
                    newImage.tintColor = imageColor
                    newImage.transform = CGAffineTransform(rotationAngle: rotation.toRadians)
                    return newImage
                } else {
                    let newView = UIView(frame: rect)
                    newView.frame = rect
                    newView.backgroundColor = color
                    newView.transform = CGAffineTransform(rotationAngle: rotation.toRadians)
                    return newView
                }
            })
        backgroundSquares.forEach { addSubview($0) }
    }

}
