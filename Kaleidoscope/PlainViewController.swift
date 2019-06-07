//
//  PlainViewController.swift
//  Kaleidoscope
//
//  Created by Yamazaki Mitsuyoshi on 2019/06/07.
//  Copyright © 2019 Mitsuyoshi Yamazaki. All rights reserved.
//

import UIKit

class PlainViewController: UIViewController {
  
  @IBOutlet weak var kaleidoscopeView: KaleidoscopeView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    kaleidoscopeView.setUp()
    kaleidoscopeView.startAnimation()
  }
}

class KaleidoscopeView: UIView {
  
  internal var image = #imageLiteral(resourceName: "000")
  internal var otherImage = #imageLiteral(resourceName: "019")
  
  private var colorVar: CGFloat = 0.0
  private var colorAdd: CGFloat = 0.01
  
  private var fragments: [FragmentView] = []
  
  internal func setUp() {
    
    var center = CGPoint.zero
    let count = 8
    let size = self.frame.size.width / CGFloat(2.0)
    let halfSize = size / CGFloat(2.0)
    let myCenter = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
    
    func centerToFrame(c: CGPoint) -> CGRect {
      
      return CGRect(x: c.x - halfSize, y: c.y - halfSize, width: size, height: size)
    }
    
    for i in 0..<count {
      
      let radianUnit = (((Double.pi * 4.0) / Double(count)) / 2.0)
      let radian = (radianUnit * Double(i))
      let centerRadian = radian + (radianUnit / 2.0)
      
      center.x = (self.bounds.size.width / CGFloat(2.0)) + (CGFloat(cos(centerRadian)) * halfSize)
      center.y = (self.bounds.size.height / CGFloat(2.0)) + (CGFloat(sin(centerRadian)) * halfSize)
      
      let frame = centerToFrame(c: center)
      
      let containerView = UIView(frame: frame)
      containerView.backgroundColor = UIColor.clear
      containerView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, .flexibleHeight]
      
      self.addSubview(containerView)
      
      let fragmentView = FragmentView(frame: containerView.bounds, numberOfImages: 2)
      
      let angle = CGFloat((i / 2) * 90)
      let rotateRadian = angle * CGFloat.pi / 180.0
      
      containerView.transform = fragmentView.transform.rotated(by: rotateRadian)
      
      
      containerView.addSubview(fragmentView)
      self.fragments.append(fragmentView)
    }
    
    let clippingPath = UIBezierPath()
    
    clippingPath.addArc(withCenter: myCenter, radius: (self.frame.size.width / 2.0) - 10.0, startAngle: CGFloat(0.0), endAngle: 2.0 * CGFloat.pi, clockwise: true)
    clippingPath.close()
    
    let maskLayer = CAShapeLayer()
    maskLayer.path = clippingPath.cgPath
    
    self.layer.mask = maskLayer
    
    
    self.changeColor(timer: nil)
    
    self.startAnimation()
  }
  
  internal func startAnimation() {
    
    for (i, fragmentView) in self.fragments.enumerated() {
      
      let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
      rotateAnimation.toValue = (Double.pi * 2.0 * pow(-1.0, Double(i)))
      rotateAnimation.duration = 12.0
      rotateAnimation.repeatCount = 10000
      
      fragmentView.layer.add(rotateAnimation, forKey: "rotateAnimation")
    }
    
    _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.changeColor(timer:)), userInfo: nil, repeats: true)
  }
  
  @objc internal func changeColor(timer: Timer!) {
    
    //    println("change color: \(self.colorVar)")
    
    let newColor = UIColor(red: self.colorVar, green: 0.3, blue: 0.3, alpha: 0.8)
    let newImage = self.image.colorredImage(color: newColor)
    
    let otherColor = UIColor(red: 0.3, green: self.colorVar, blue: 0.3, alpha: 0.8)
    let otherImage = self.otherImage.colorredImage(color: otherColor)
    
    let images = [
      newImage,
      otherImage
    ]
    
    for fragmentView in self.fragments {
      fragmentView.images = images
    }
    
    self.colorVar += self.colorAdd
    
    if self.colorVar >= 0.8 {
      self.colorAdd = -0.01
    }
    else if self.colorVar <= 0.0 {
      self.colorAdd = 0.01
    }
  }
}

class FragmentView: UIView {
  
  internal var images: [UIImage] = [] {
    didSet {
      
      for (i, anImage) in self.images.enumerated() {
        self.imageViews[i].image = anImage
      }
    }
  }
  
  private var imageViews: [UIImageView] = []
  
  init(frame: CGRect, numberOfImages: Int) {
    
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clear
    
    for _ in 0..<numberOfImages {
      
      let imageView = UIImageView(frame: self.bounds)
      imageView.backgroundColor = UIColor.clear
      imageView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, .flexibleHeight]
      imageView.clipsToBounds = true
      imageView.contentMode = UIView.ContentMode.scaleAspectFit
      
      self.addSubview(imageView)
      self.imageViews.append(imageView)
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UIImage {  
  internal func colorredImage(color: UIColor) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    
    let context = UIGraphicsGetCurrentContext()!
    let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    context.clip(to: rect, mask: self.cgImage!)
    color.setFill()
    context.fill(rect)
    
    let colorredImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return colorredImage
  }
  
  internal func rotatedImage(orientation: UIImage.Orientation) -> UIImage {
    
    return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: orientation)
  }
}
