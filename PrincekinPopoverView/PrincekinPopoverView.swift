//
//  PrincekinPopoverView.swift
//
//
//  Created by LEE on 6/20/18.
//  Copyright © 2018 LEE. All rights reserved.
//


import UIKit

public enum PopoverViewOption {
    case arrowSize(CGSize)
    case animationIn(TimeInterval)
    case animationOut(TimeInterval)
    case cornerRadius(CGFloat)
    case sideEdge(CGFloat)
    case blackOverlayColor(UIColor)
    case overlayBlur(UIBlurEffectStyle)
    case type(PopoverViewType)
    case color(UIColor)
    case dismissOnBlackOverlayTap(Bool)
    case showBlackOverlay(Bool)
    //是否有阴影
    case showShadowy(Bool)
    //尖角位置比例
    case arrowPositionRatio(CGFloat)
    case springDamping(CGFloat)
    case initialSpringVelocity(CGFloat)
}

@objc public enum PopoverViewType: Int {
    case up
    case down
    case left
    case right
    case auto
}
open class PrincekinPopoverView: UIView {
    var popoverViewOptions : [PopoverViewOption]?{
        didSet{
            if let options = popoverViewOptions {
                for option in options {
                    switch option {
                    case let .arrowSize(value):
                        self.arrowSize = value
                    case let .animationIn(value):
                        self.animationIn = value
                    case let .animationOut(value):
                        self.animationOut = value
                    case let .cornerRadius(value):
                        self.cornerRadius = value
                    case let .sideEdge(value):
                        self.sideEdge = value
                    case let .blackOverlayColor(value):
                        self.blackOverlayColor = value
                    case let .overlayBlur(style):
                        self.overlayBlur = UIBlurEffect(style: style)
                    case let .type(value):
                        self.popoverType = value
                    case let .color(value):
                        self.popoverColor = value
                    case let .dismissOnBlackOverlayTap(value):
                        self.dismissOnBlackOverlayTap = value
                    case let .showBlackOverlay(value):
                        self.showBlackOverlay = value
                    case let .springDamping(value):
                        self.springDamping = value
                    case let .initialSpringVelocity(value):
                        self.initialSpringVelocity = value
                    case let .showShadowy(value):
                        self.showShadowy = value
                    case let .arrowPositionRatio(value):
                        self.arrowPositionRatio = value
                    }
                }
            }
        }
    }
    
    // custom property
    private var arrowSize: CGSize = CGSize(width: 16.0, height: 10.0)
    private var animationIn: TimeInterval = 0.6
    private var animationOut: TimeInterval = 0.3
    private var cornerRadius: CGFloat = 6.0
    private var sideEdge: CGFloat = 0
    private var popoverType: PopoverViewType = .down
    private var blackOverlayColor: UIColor = UIColor(white: 0.0, alpha: 0.2)
    private var overlayBlur: UIBlurEffect?
    private var popoverColor: UIColor = UIColor.white
    private var dismissOnBlackOverlayTap: Bool = true
    private var showBlackOverlay: Bool = true
    private var highlightFromView: Bool = false
    //是否有阴影
    private var showShadowy: Bool = false
    //尖角的位置比例
    private var arrowPositionRatio: CGFloat = 0.5
    private var highlightCornerRadius: CGFloat = 0
    private var springDamping: CGFloat = 0.7
    private var initialSpringVelocity: CGFloat = 3
    
    // custom closure
    open var willShowHandler: (() -> ())?
    open var willDismissHandler: (() -> ())?
    open var didShowHandler: (() -> ())?
    open var didDismissHandler: (() -> ())?
    
    public fileprivate(set) var blackOverlay: UIControl = UIControl()
    
    fileprivate var containerView: UIView!
    
    open var contentView: UIView!
    fileprivate var contentViewFrame: CGRect!
    fileprivate var arrowShowPoint: CGPoint!
    
    private convenience init() {
        self.init(frame: .zero)
        self.backgroundColor = .clear
        self.accessibilityViewIsModal = true
    }
    
    convenience init(showHandler: (() -> ())?, dismissHandler: (() -> ())?) {
        self.init(frame: .zero)
        self.backgroundColor = .clear
        self.didShowHandler = showHandler
        self.didDismissHandler = dismissHandler
        self.accessibilityViewIsModal = true
    }
    
    public  convenience init(options: [PopoverViewOption]?, showHandler: (() -> ())? = nil, dismissHandler: (() -> ())? = nil) {
        self.init(frame: .zero)
        self.backgroundColor = .clear
        self.setOptions(options)
        self.didShowHandler = showHandler
        self.didDismissHandler = dismissHandler
        self.accessibilityViewIsModal = true
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        //    setUPUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        //   self.contentView.frame = self.bounds
    }
    
    open func showAsDialog(_ contentView: UIView) {
        guard let rootView = UIApplication.shared.keyWindow else {
            return
        }
        self.showAsDialog(contentView, inView: rootView)
    }
    
    open func showAsDialog(_ contentView: UIView, inView: UIView) {
        self.arrowSize = .zero
        let point = CGPoint(x: inView.center.x,
                            y: inView.center.y - contentView.frame.height / 2)
        self.show(contentView, point: point, inView: inView)
    }
    
    open func show(_ contentView: UIView, fromView: UIView) {
        guard let rootView = UIApplication.shared.keyWindow else {
            return
        }
        self.show(contentView, fromView: fromView, inView: rootView)
    }
    
    open func show(_ contentView: UIView, fromView: UIView, inView: UIView) {
        let point: CGPoint
        
        if self.popoverType == .auto {
            if let point = fromView.superview?.convert(fromView.frame.origin, to: nil),
                point.y + fromView.frame.height + self.arrowSize.height + contentView.frame.height > inView.frame.height {
                self.popoverType = .up
            } else {
                self.popoverType = .down
            }
        }
        
        switch self.popoverType {
        case .up:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + (fromView.frame.size.width / 2),
                    y: fromView.frame.origin.y
            ), from: fromView.superview)
            break
        case .down, .auto:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + (fromView.frame.size.width / 2),
                    y: fromView.frame.origin.y + fromView.frame.size.height
            ), from: fromView.superview)
            break
        case .left:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x,
                    y: fromView.frame.origin.y + fromView.frame.height / 2.0
            ), from: fromView.superview)
            break
        case .right:
            point = inView.convert(
                CGPoint(
                    x: fromView.frame.origin.x + fromView.frame.size.width,
                    y: fromView.frame.origin.y + fromView.frame.height / 2.0
            ), from: fromView.superview)
            break
        }
        
        if self.highlightFromView {
            self.createHighlightLayer(fromView: fromView, inView: inView)
        }
        
        self.show(contentView, point: point, inView: inView)
    }
    
    open func show(_ contentView: UIView, point: CGPoint) {
        guard let rootView = UIApplication.shared.keyWindow else {
            return
        }
        self.show(contentView, point: point, inView: rootView)
    }
    
    open func show(_ contentView: UIView, point: CGPoint, inView: UIView) {
        if self.dismissOnBlackOverlayTap || self.showBlackOverlay {
            self.blackOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.blackOverlay.frame = inView.bounds
            inView.addSubview(self.blackOverlay)
            
            if showBlackOverlay {
                if let overlayBlur = self.overlayBlur {
                    let effectView = UIVisualEffectView(effect: overlayBlur)
                    effectView.frame = self.blackOverlay.bounds
                    effectView.isUserInteractionEnabled = false
                    self.blackOverlay.addSubview(effectView)
                } else {
                    if !self.highlightFromView {
                        self.blackOverlay.backgroundColor = self.blackOverlayColor
                    }
                    self.blackOverlay.alpha = 0
                }
            }
            
            if self.dismissOnBlackOverlayTap {
                self.blackOverlay.addTarget(self, action: #selector(PrincekinPopoverView.dismiss), for: .touchUpInside)
            }
        }
        self.containerView = inView
        self.contentView = contentView
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.layer.cornerRadius = self.cornerRadius
        self.contentView.layer.masksToBounds = true
        self.arrowShowPoint = point
        self.show()
    }
    open func showAgain()  {
        show()
    }
    
    open override func accessibilityPerformEscape() -> Bool {
        self.dismiss()
        return true
    }
    
    @objc open func dismiss() {
        if self.superview != nil {
            self.willDismissHandler?()
            UIView.animate(withDuration: self.animationOut, delay: 0,
                           options: UIViewAnimationOptions(),
                           animations: {
                            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                            self.blackOverlay.alpha = 0
            }){ _ in
                self.contentView.removeFromSuperview()
                self.blackOverlay.removeFromSuperview()
                self.removeFromSuperview()
                self.transform = CGAffineTransform.identity
                self.didDismissHandler?()
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let arrow = UIBezierPath()
        let color = self.popoverColor
        //箭头的起点
        let arrowPoint = self.containerView.convert(self.arrowShowPoint, to: self)
        switch self.popoverType {
        //一个简单的画线操作
        case .up:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: self.bounds.height))
            arrow.addLine(
                to: CGPoint(
                    //箭头的x中点
                    x: arrowPoint.x - self.arrowSize.width * 0.5,
                    //根据箭头是否在self的最左侧，修改y
                    y: self.isCornerLeftArrow ? self.arrowSize.height : self.bounds.height - self.arrowSize.height
                )
            )
            
            arrow.addLine(to: CGPoint(x: self.cornerRadius, y: self.bounds.height - self.arrowSize.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.bounds.height - self.arrowSize.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius, y: 0))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.arrowSize.height - self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.bounds.height - self.arrowSize.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            arrow.addLine(
                to: CGPoint(
                    x: arrowPoint.x + self.arrowSize.width * 0.5,
                    y: self.isCornerRightArrow ? self.arrowSize.height : self.bounds.height - self.arrowSize.height
                )
            )
            break
        case .down, .auto:
            arrow.move(to: CGPoint(x: arrowPoint.x, y: 0))
            arrow.addLine(
                to: CGPoint(
                    x: arrowPoint.x + self.arrowSize.width * 0.5,
                    y: self.isCornerRightArrow ? self.arrowSize.height + self.bounds.height : self.arrowSize.height
                )
            )
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius, y: self.arrowSize.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.arrowSize.height + self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(270.0),
                endAngle: self.radians(0),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: self.bounds.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: 0, y: self.arrowSize.height + self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.arrowSize.height + self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(
                x: arrowPoint.x - self.arrowSize.width * 0.5,
                y: self.isCornerLeftArrow ? self.arrowSize.height + self.bounds.height : self.arrowSize.height))
            break
        case .left:
            
            arrow.move(to: CGPoint(x: self.bounds.width, y: arrowPoint.y))
            arrow.addLine(
                to: CGPoint(
                    x: self.bounds.width - self.arrowSize.width,
                    y: arrowPoint.y + self.arrowSize.height * 0.5
                )
            )
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.arrowSize.width, y: self.bounds.height - self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.arrowSize.width - self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.cornerRadius, y: self.bounds.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            arrow.addLine(to: CGPoint(x: 0, y: self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x:self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius - arrowSize.width, y: 0))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius - arrowSize.width,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            
            arrow.addLine(
                to: CGPoint(
                    x: self.bounds.width - arrowSize.width,
                    y: arrowPoint.y - self.arrowSize.height * 0.5
                )
            )
            
            break
        case .right:
            arrow.move(to: CGPoint(x: 0, y: arrowPoint.y))
            arrow.addLine(
                to: CGPoint(
                    x: self.arrowSize.width,
                    y: arrowPoint.y - self.arrowSize.height * 0.5
                )
            )
            
            arrow.addLine(to: CGPoint(x: self.arrowSize.width, y: self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x:self.arrowSize.width + self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(180),
                endAngle: self.radians(270),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.bounds.width - self.cornerRadius, y: 0))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(270),
                endAngle: self.radians(0),
                clockwise: true)
            arrow.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.cornerRadius))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.bounds.width - self.cornerRadius,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(0),
                endAngle: self.radians(90),
                clockwise: true)
            
            arrow.addLine(to: CGPoint(x: self.cornerRadius, y: self.bounds.height))
            arrow.addArc(
                withCenter: CGPoint(
                    x: self.cornerRadius + self.arrowSize.width,
                    y: self.bounds.height - self.cornerRadius
                ),
                radius: self.cornerRadius,
                startAngle: self.radians(90),
                endAngle: self.radians(180),
                clockwise: true)
            
            arrow.addLine(
                to: CGPoint(
                    x: self.arrowSize.width,
                    y: arrowPoint.y + self.arrowSize.height * 0.5
                )
            )
            
            break
        }
        
        color.setFill()
        arrow.fill()
    }

}
public extension PrincekinPopoverView {
    func setOptions(_ options: [PopoverViewOption]?){
        popoverViewOptions = options
    }
    func createHighlightLayer(fromView: UIView, inView: UIView) {
        let path = UIBezierPath(rect: inView.bounds)
        let highlightRect = inView.convert(fromView.frame, from: fromView.superview)
        let highlightPath = UIBezierPath(roundedRect: highlightRect, cornerRadius: self.highlightCornerRadius)
        path.append(highlightPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = self.blackOverlayColor.cgColor
        self.blackOverlay.layer.addSublayer(fillLayer)
    }
    func setUPUI()  {
        
        switch self.popoverType {
        case .up:
            self.contentView.frame.origin.y = 0.0
        case .down, .auto:
            self.contentView.frame.origin.y = self.arrowSize.height
        case .left:
            self.contentView.frame.origin.x = 0.0
        case .right:
            self.contentView.frame.origin.x = self.arrowSize.width
        }
        self.addSubview(self.contentView)
        self.containerView.addSubview(self)
        self.create()
        
    }
    
    func show() {
        self.setNeedsDisplay()
        setUPUI()
        
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.willShowHandler?()
        UIView.animate(
            withDuration: self.animationIn,
            delay: 0,
            usingSpringWithDamping: self.springDamping,
            initialSpringVelocity: self.initialSpringVelocity,
            options: UIViewAnimationOptions(),
            animations: {
                self.transform = CGAffineTransform.identity
        }){ _ in
            self.didShowHandler?()
        }
        UIView.animate(
            withDuration: self.animationIn / 3,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.blackOverlay.alpha = 1
        }, completion: nil)
    }
    
    var isCornerLeftArrow: Bool {
        return self.arrowShowPoint.x == self.frame.origin.x
    }
    
    var isCornerRightArrow: Bool {
        return self.arrowShowPoint.x == self.frame.origin.x + self.bounds.width
    }
    
    func radians(_ degrees: CGFloat) -> CGFloat {
        return CGFloat.pi * degrees / 180
    }
    
    //设置弹窗的位置形状及尖角的位置
    func create() {
        var frame = self.contentView.frame
        
        
        switch self.popoverType {
        case .up:
            frame = dealPopoverViewFrameInHorizontal(frame)
            break
        case .down, .auto:
            frame = dealPopoverViewFrameInHorizontal(frame)
            break
        case .left:
            
            
            //默认情况下  尖角处于y中间
            frame.origin.y = self.arrowShowPoint.y - frame.size.height * arrowPositionRatio
            break
            
        case .right:
            frame.origin.y = self.arrowShowPoint.y - frame.size.height * arrowPositionRatio
            break
        }
        
        self.frame = frame
        
        let arrowPoint = self.containerView.convert(self.arrowShowPoint, to: self)
        var anchorPoint: CGPoint
        var tShadowOffset : CGSize?
        
        switch self.popoverType {
        case .up:
            frame.origin.y = self.arrowShowPoint.y - frame.height - self.arrowSize.height
            anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 1)
            frame.size.height += self.arrowSize.height
            tShadowOffset = CGSize(width: 2, height: 0)
            break
        case .down, .auto:
            frame.origin.y = self.arrowShowPoint.y
            anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 0)
            frame.size.height += self.arrowSize.height
            tShadowOffset = CGSize(width: 2, height: 0)
            break
        case .left:
            frame.origin.x = self.arrowShowPoint.x - frame.width - self.arrowSize.width
            anchorPoint = CGPoint(x: 1, y: arrowPoint.y / frame.size.height)
            frame.size.width += self.arrowSize.width
            tShadowOffset = CGSize(width: 0, height: 2)
            break
        case .right:
            frame.origin.x = self.arrowShowPoint.x
            anchorPoint = CGPoint(x: 0, y: arrowPoint.y / frame.size.height)
            print("---====\(anchorPoint)")
            frame.size.width += self.arrowSize.width
            tShadowOffset = CGSize(width: 0, height: 2)
            break
        }
        
        if self.arrowSize == .zero {
            anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        let lastAnchor = self.layer.anchorPoint
        self.layer.anchorPoint = anchorPoint
        let x = self.layer.position.x + (anchorPoint.x - lastAnchor.x) * self.layer.bounds.size.width
        let y = self.layer.position.y + (anchorPoint.y - lastAnchor.y) * self.layer.bounds.size.height
        self.layer.position = CGPoint(x: x, y: y)
        
        //    frame.size.height += self.arrowSize.height
        
        self.frame = frame
        if showShadowy{
            layer.cornerRadius = 4
            layer.shadowColor = UIColor.init(red: 32.0 / 256.0 , green: 32.0 / 256.0, blue: 32.0 / 256.0, alpha: 0.5).cgColor
            layer.shadowOffset = tShadowOffset!
            layer.shadowOpacity = 1
            layer.shadowRadius = 4
        }
    }
    //当弹窗处于水平方向时，处理frame
    func dealPopoverViewFrameInHorizontal(_ frame : CGRect) -> CGRect {
        var tFrame = frame
        
        tFrame.origin.x = self.arrowShowPoint.x - tFrame.size.width * arrowPositionRatio
        
        var sideEdge: CGFloat = 0.0
        self.sideEdge = 0
        if tFrame.size.width < self.containerView.frame.size.width {
            sideEdge = self.sideEdge
        }
        
        let outerSideEdge = tFrame.maxX - self.containerView.bounds.size.width
        if outerSideEdge > 0 {
            tFrame.origin.x -= (outerSideEdge + sideEdge)
        } else {
            if tFrame.minX < 0 {
                tFrame.origin.x += abs(frame.minX) + sideEdge
            }
        }
        return tFrame
    }
}

