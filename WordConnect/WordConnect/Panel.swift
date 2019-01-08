//
//  Panel.swift
//  WordConnect
//
//  Created by GEORGE QUENTIN on 08/01/2019.
//  Copyright © 2019 GEORGE QUENTIN. All rights reserved.
//

import UIKit

//Write the protocol declaration here:
protocol WordPanelDelegate {
    func wordPanel(tiles: [WordTile])
    func wordPanel(wordFound: String)
}

@IBDesignable
public final class Panel: UIView {
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    private var _numberOfTiles: Int = 4
    @IBInspectable
    public var numberOfTiles: Int {
        get {
            return _numberOfTiles
        }
        set {
            if newValue >= 0 {
                _numberOfTiles = newValue
            }
            updateLayout()
        }
        
    }
    
    
    @IBInspectable
    public var tilesCornerRadius: CGFloat = 2 {
        didSet {
            updateLayout()
        }
    }
    
    @IBInspectable
    public var tilesSize: CGFloat = 20 {
        didSet {
            updateLayout()
        }
    }
    
    @IBInspectable
    public var tilesLineSize: CGFloat = 5.0 {
        didSet {
            updateLayout()
        }
    }
    
    @IBInspectable
    public var tilesColor: UIColor = UIColor.red {
        didSet {
            updateLayout()
        }
    }
    
    @IBInspectable
    public var tilesSelectedColor: UIColor = UIColor.green {
        didSet {
            updateLayout()
        }
    }
    
    @IBInspectable
    public var tilesOffset: CGFloat = 0.75 {
        didSet {
            updateLayout()
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            updateCircle()
            updateLayout()
        }
    }
    
    //Declare the delegate variable here:
    var delegate : WordPanelDelegate?
    var buttons: [WordTile] = []
    var recentSelectedTile: Int?
    var selectedTiled: [Int] = []
    var panGesture : UIPanGestureRecognizer!
    var line = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialLayout()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialLayout()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initialLayout()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateLayout()
        if let delegate = self.delegate {
            delegate.wordPanel(tiles: buttons)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        updateLayout()
    }
    
    func updateCircle() {
        layer.cornerRadius = frame.size.width / 2
    }
    
    func initialLayout() {
        removeSubviewsAndConstraints()
        removePanGestures()
        addPanGesture()
        addLine()
        updateCircle()
        calculateTiles(amount: numberOfTiles)
    }
    
    func updateLayout() {
        for subUIView in self.subviews as [UIView] {
            if let button = buttons.first(where: { $0 == subUIView }),
                button.index >= numberOfTiles  {
                subUIView.removeSubviewsAndConstraints()
                subUIView.removeFromSuperview()
                buttons.remove(at: button.index)
            }
        }
        calculateTiles(amount: numberOfTiles)
    }
    
    func calculateTiles(amount: Int) {
        //calculate the initial start point, this should be the top of pond
        //let xOffset: CGFloat = 0.35
        //let yOffset: CGFloat = 0.35
        let origin = CGPoint(x: bounds.midX, //- xOffset,
                             y: bounds.midY) //- yOffset)
        
        let radius: CGFloat = bounds.width / 2.0  //radius of background view
        let scaledRadius: CGFloat = radius * tilesOffset
        var theta: CGFloat = 1.0
        
        for index in 0..<amount {
            //let ratios: [CGFloat] = [3/6, 5/6, 3/6, 1/6, 5/6, 2/6, 4/6, 2/6, 4/6, 4/6, 4/6, 4/6, 3/6]
            theta = CGFloat(index) / CGFloat(amount) * (CGFloat.pi * 2)
            let point = CGPoint(x: origin.x + cos(theta) * scaledRadius,// * ratio,
                                y: origin.y + sin(theta) * scaledRadius)// * ratio)
            if let button = buttons.first(where: { $0.index == index }) {
                // update button
                button.frame = CGRect(center: point, size: CGSize(width: tilesSize, height: tilesSize))
                button.backgroundColor = tilesColor
                button.cornerRadius = tilesCornerRadius
                //print("updated tile: ", index)
            } else {
                // create new button
                let button = WordTile(type: .system)
                button.frame = CGRect(center: point, size: CGSize(width: tilesSize, height: tilesSize))
                button.backgroundColor = tilesColor
                button.cornerRadius = tilesCornerRadius
                button.index = index
                addSubview(button)
                buttons.append(button)
                //print("new added: ", index)
            }
        }
        
        print("update ",bounds, ", tilesCount", amount, ", number of tiles", buttons.count, ", number of subviews", self.subviews.count)
        
    }
    
    func removePanGestures(){
        // Clean up existing pan recognizers
        if panGesture != nil {
            panGesture.isEnabled = false
            removeGestureRecognizer(panGesture)
        }
        panGesture = nil
    }
    
    func addPanGesture(){
        // Add slide to open or close
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture?.cancelsTouchesInView = false
        isUserInteractionEnabled = true
        addGestureRecognizer(panGesture)
        
    }
    
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        
        let location = pan.location(in: self)
        
        switch pan.state {
        case .began:
            onBeganEvents(with: location)
            //print("began at", location, ", touched view: ", dragview)
            break
        case .changed:
            
            //print("changed at", location, ", touched view: ", dragview)
            onChangedEvents(with: location)
            break
        case .ended:
            //print("ended at", location, ", touched view: ", dragview)
            onEndedEvents(with: location)
            break
        default:
            break
        }
        
        updatePanel(with: location)
    }
    
    func onBeganEvents(with location: CGPoint) {
        if let firstView = self.hitTest(location, with: nil),
            let wordTile = firstView as? WordTile {
            selectedTiled.removeAll()
            selectedTiled.append(wordTile.index)
            recentSelectedTile = wordTile.index
        }
    }
    
    func onChangedEvents(with location: CGPoint) {
        if selectedTiled.count < 1 {
            onBeganEvents(with: location)
        } else {
            if selectedTiled.count > 0,
                let selectedView = self.hitTest(location, with: nil),
                let wordTile = selectedView as? WordTile {
                
                if selectedTiled.contains(wordTile.index) {
                    if selectedTiled.count > 1,
                        let recent = selectedTiled[safe: selectedTiled.count - 2],
                        recent == wordTile.index {
                        
                        selectedTiled.removeLast()
                        recentSelectedTile = selectedTiled.last
                    }
                    
                } else {
                    selectedTiled.append(wordTile.index)
                    recentSelectedTile = wordTile.index
                }
            }
        }
    }
    
    func onEndedEvents(with location: CGPoint) {
        recentSelectedTile = nil
        selectedTiled = []
    }
    
    func updatePanel(with location: CGPoint) {
        let selectedWordTiles = selectedTiled
            .compactMap({ index -> WordTile? in
                return buttons.first(where: { $0.index == index })
            })
        selectedWordTiles.forEach {
            $0.backgroundColor = tilesSelectedColor
            $0.frame.size = CGSize(width: tilesSize + 5, height: tilesSize + 5)
        }
        for tile in buttons where selectedWordTiles.contains(tile) == false {
            tile.backgroundColor = tilesColor
            tile.frame.size = CGSize(width: tilesSize, height: tilesSize)
        }
        drawLine(from: selectedWordTiles.map({ $0.center }), currentLocation: location)
    }
    
    func addLine() {
        if let subLayers = layer.sublayers {
            for sublayer in subLayers where sublayer is CAShapeLayer {
                sublayer.removeFromSuperlayer()
            }
        }
        
        line = CAShapeLayer()
        line.lineJoin = CAShapeLayerLineJoin.round
        layer.addSublayer(line)
    }
    
    func drawLine(from points: [CGPoint], currentLocation: CGPoint) {
        let linePath = UIBezierPath()
        if points.count > 0 {
            for (index, point) in points.enumerated() {
                if index == 0 {
                    linePath.move(to: point)
                } else {
                    linePath.addLine(to: point)
                }
            }
            linePath.addLine(to: currentLocation)
        }
        
        line.path = linePath.cgPath
        line.strokeColor = tilesSelectedColor.cgColor
        line.fillColor = UIColor.clear.cgColor
        line.lineWidth = tilesLineSize
        line.lineJoin = CAShapeLayerLineJoin.round
        //layer.addSublayer(line)
        //print(layer.sublayers!.count)
    }
}
