//
//  CircularPageViewController.swift
//  CircularPager
//
//  Created by Vincenzo Romano on 24/01/2019.
//

import UIKit

open class CircularPageViewController: UIViewController {

    public var currentPageIndex : Int = 0;
    public var viewControllers : NSArray {
        set{
            tmpViewControllers = newValue;
            self.invalidatePager();
        }
        get{
            return tmpViewControllers;
        }
    };
    
    private var tmpViewControllers : NSArray = [];
    private var pagerControlView : UIView?;
    private var radius : CGFloat = 0.0;
    private var bulletsOnCircle : Int = 12;
    private var angle : Double = 0.0;

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup();
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    private func setup() -> Void {
        self.currentPageIndex = 0;
        self.drawCirclePager();
        self.drawBullets();
    }
    
    private func invalidatePager() -> Void {
        pagerControlView?.removeFromSuperview();
        self.setup();
    }
    
    private func drawCirclePager() {
        pagerControlView = UIView(frame: CGRect(x: -100, y: self.view.frame.size.height - 100, width: self.view.frame.size.width + 200, height: self.view.frame.size.width + 200));
        self.view.addSubview(pagerControlView!);
        
        radius = pagerControlView!.frame.size.width/2;
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: pagerControlView!.frame.size.width/2, y: pagerControlView!.frame.size.height/2), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true);
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(hexString: "#464646").cgColor;
        shapeLayer.lineWidth = 2.0
        
        pagerControlView!.layer.addSublayer(shapeLayer)
        self.pagerControlView!.transform = self.pagerControlView!.transform.rotated(by: CGFloat(NSNumber.init(value: (-1 * Double.pi/2)).floatValue));
    }
    
    @objc private func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            self.rotate(direction: CircularPagerDirection.Right);
            self.changeSelectedPage(index: currentPageIndex - 1);
        }else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            self.rotate(direction: CircularPagerDirection.Left);
            self.changeSelectedPage(index: currentPageIndex + 1);
        }
    }
    
    private func rotate(direction : CircularPagerDirection) {
        var rotAngle : Double = angle;
        switch direction {
            case CircularPagerDirection.Right:
                rotAngle = angle * 1 ; break;
            case CircularPagerDirection.Left:
                rotAngle = angle * -1; break;
        }
        
        UIView.animate(withDuration: 0.3) {
            self.pagerControlView!.transform = self.pagerControlView!.transform.rotated(by: CGFloat(NSNumber.init(value: rotAngle).floatValue));
        };
    }
    
    private func changeSelectedPage(index : Int) -> Void{
        var tmp : CAShapeLayer? = self.getBulletAtIndex(index: currentPageIndex);
        if tmp != nil {
            self.setSelected(bullet: tmp!, isSelected: false);
        }
        currentPageIndex = index;
        tmp = self.getBulletAtIndex(index: currentPageIndex);
        if tmp != nil{
            self.setSelected(bullet: tmp!, isSelected: true);
        }
    }
    
    private func getBulletAtIndex(index : Int) -> CAShapeLayer? {
        let count : Int = (pagerControlView?.layer.sublayers?.count)!;
        for i in 0..<count {
            let tmp : CALayer = (pagerControlView?.layer.sublayers?[i])!;
            if tmp.name != nil {
                NSLog("%@ == %@", tmp.name!, String.init(format: "bullet_%d", i));
                if tmp.name == String.init(format: "bullet_%d", i) {
                    return tmp as? CAShapeLayer;
                }
            }
        }
        return nil;
    }
    
    private func setSelected(bullet : CAShapeLayer, isSelected : Bool){
        bullet.opacity = (isSelected) ? 1.0 : 0.3;
    }
    
    private func drawBullets() {
        var tmpBulletsOnCircle = bulletsOnCircle;
        if(viewControllers.count < 3){
            tmpBulletsOnCircle = 4;
        }
        
        for index in 0..<bulletsOnCircle {
            let bullet : CAShapeLayer = self.createBullet();
            bullet.name = String.init(format: "bullet_%d", index);
            let origin : CGPoint = self.pointOnCircle(index: index, count: tmpBulletsOnCircle);
            var rect : CGRect = bullet.frame;
            rect.origin.x = origin.x;
            rect.origin.y = origin.y;
            bullet.frame = rect;
            
            if(index == currentPageIndex){
                bullet.opacity = 1.0;
            }else{
                bullet.opacity = 0.3;
            }
            
            pagerControlView!.layer.addSublayer(bullet);
        }
    }
    
    private func createBullet() -> CAShapeLayer {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: 10, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true);
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.yellow.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor;
        
        return shapeLayer;
    }
    
    private func pointOnCircle(index : Int, count : Int) -> CGPoint {
        angle = (Double.pi * 2) / Double(count);
        let x : Double = Double(radius) * cos(Double(index) * angle) + Double(pagerControlView!.frame.size.width / 2);
        let y : Double = Double(radius) * sin(Double(index) * angle) + Double(pagerControlView!.frame.size.height / 2);
    
        return CGPoint(x: x, y: y);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
