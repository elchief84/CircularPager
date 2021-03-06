//
//  CircularPageViewController.swift
//  CircularPager
//
//  Created by Vincenzo Romano on 24/01/2019.
//

import UIKit

open class CircularPageViewController: UIViewController {

    public var currentPageIndex : Int = 0;
    public var viewControllers : [UIViewController] {
        set{
            tmpViewControllers = newValue;
            self.invalidatePager();
        }
        get{
            return tmpViewControllers;
        }
    };
    
    @IBInspectable var primaryColor : UIColor = UIColor.yellow;
    @IBInspectable var secondaryColor : UIColor = UIColor.init(hexString: "#464646");
    @IBInspectable var titleColor : UIColor = UIColor.init(hexString: "#000000");
    @IBInspectable var titleFontName : String = "Exo-Bold";
    
    // private var titleLabel : UILabel = UILabel.init();
    private var tmpViewControllers : [UIViewController] = [];
    private var pagerControlView : UIView?;
    private var titlesView : UIView?;
    private var contentsContainerView : UIView?;
    private var radius : CGFloat = 0.0;
    private var bulletsOnCircle : Int = 12;
    private var angle : Double = 0.0;
    private var swipeLeft : UISwipeGestureRecognizer?;
    private var swipeRight : UISwipeGestureRecognizer?;
    
    private let opacity : Float = 0.6;
    private let minScale : CGFloat = 0.8;

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup();
        
        let frameworkBundle = Bundle(identifier: "org.cocoapods.CircularPager");
        let resourcePath = frameworkBundle?.resourcePath?.appending("/CircularPager.bundle");
        let resourceBundle = Bundle(path: resourcePath!);
        let _ : Bool = UIFont.registerFont(bundle: resourceBundle!, fontName: "Exo-Bold", fontExtension: "ttf");
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft?.direction = .left
        self.view.addGestureRecognizer(swipeLeft!)
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight?.direction = .right
        self.view.addGestureRecognizer(swipeRight!)
    }
    
    private func setup() -> Void {
        self.currentPageIndex = 0;
        self.drawCirclePager();
        self.drawCircleTitles();
        self.drawBullets();
        
        /*titleLabel.frame = CGRect.init(x: 30, y: (pagerControlView?.frame.origin.y)! - 90, width: self.view.frame.size.width - 60, height: 80);
        titleLabel.textAlignment = NSTextAlignment.center;
        
        titleLabel.textColor = titleColor;
        titleLabel.font = UIFont.init(name: titleFontName, size: 24.0);
        self.view.addSubview(titleLabel);
        
        if(viewControllers.count > 0){
            titleLabel.text = viewControllers[currentPageIndex].title;
        }*/
        
        contentsContainerView = UIView.init(frame: self.view.bounds);
        self.contentsContainerView!.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 2.5));
        self.view.insertSubview(contentsContainerView!, at: 0);
        var tmpView : UIView?;
        for index : Int in 0..<bulletsOnCircle {
            tmpView = UIView.init(frame: self.view.bounds);
            tmpView!.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 2.5));
            tmpView!.transform = self.view.transform.rotated(by: CGFloat(NSNumber.init(value: Double.init(index) * angle).floatValue));
            tmpView!.tag = index + 1;
            contentsContainerView!.insertSubview(tmpView!, at: 0);
        }
        
        self.arrangeControllers();
    }
    
    private func arrangeControllers() {
        if self.viewControllers.count == 0 {
            return;
        }
        
        let currentView : UIView = contentsContainerView!.viewWithTag(1 + currentPageIndex)!;
        let nextView : UIView = contentsContainerView!.viewWithTag(1 + ((currentPageIndex + 1) % bulletsOnCircle))!;
        let prevView : UIView = contentsContainerView!.viewWithTag(1 + (((currentPageIndex - 1) < 0) ? bulletsOnCircle-1 : currentPageIndex - 1))!;
        
        let currentController : UIViewController = self.viewControllers[currentPageIndex % self.viewControllers.count];
        for tmp : UIView in currentView.subviews {
            tmp.removeFromSuperview();
        }
        currentView.addSubview(currentController.view);
        
        let nextController : UIViewController = self.viewControllers[(currentPageIndex + 1) % self.viewControllers.count];
        for tmp : UIView in nextView.subviews {
            tmp.removeFromSuperview();
        }
        nextView.addSubview(nextController.view);
        
        let prevController : UIViewController = self.viewControllers[((currentPageIndex - 1) < 0) ? self.viewControllers.count-1 : (currentPageIndex - 1) % self.viewControllers.count];
        for tmp : UIView in prevView.subviews {
            tmp.removeFromSuperview();
        }
        prevView.addSubview(prevController.view);
        
        
        let currentTitle : UILabel = titlesView!.viewWithTag(101 + (currentPageIndex % 4))! as! UILabel;
        let nextTitle : UILabel = titlesView!.viewWithTag(101 + ((currentPageIndex + 1) % 4))! as! UILabel;
        let prevTitle : UILabel = titlesView!.viewWithTag(101 + (((currentPageIndex - 1) < 0) ? 3 : (currentPageIndex - 1)%4))! as! UILabel;
        
        currentTitle.text = currentController.title;
        nextTitle.text = nextController.title;
        prevTitle.text = prevController.title;
    }
    
    private func invalidatePager() -> Void {
        pagerControlView?.removeFromSuperview();
        contentsContainerView?.removeFromSuperview();
        titlesView?.removeFromSuperview();
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
        shapeLayer.strokeColor = secondaryColor.cgColor;
        shapeLayer.lineWidth = 1.0
        
        pagerControlView!.layer.addSublayer(shapeLayer)
        self.pagerControlView!.transform = self.pagerControlView!.transform.rotated(by: CGFloat(NSNumber.init(value: (-1 * Double.pi/2)).floatValue));
    }
    
    private func drawCircleTitles() {
        titlesView = UIView(frame: CGRect(x: -100, y: self.view.frame.size.height - 170, width: self.view.frame.size.width + 200, height: self.view.frame.size.width + 200));
        self.view.addSubview(titlesView!);
        
        var tmpLabel : UILabel?;
        for index : Int in 0..<4 {
            
            let width : CGFloat = titlesView!.frame.size.width;
            var xVal :CGFloat = 0;
            var yVal :CGFloat = 0;
            
            switch index {
            case 0:
                xVal = 0; yVal = 0; break;
            case 1:
                xVal = width; yVal = 0; break;
            case 2:
                xVal = width; yVal = width; break;
            case 3:
                xVal = 0; yVal = width; break;
            default:
                xVal = 0; yVal = 0; break;
            }
            
            tmpLabel = UILabel.init(frame: CGRect.init(
                x: xVal,
                y: yVal,
                width: width,
                height: 40)
            );
            tmpLabel!.setAnchorPoint(anchorPoint: CGPoint(x: 0, y: 0));
            tmpLabel!.font = UIFont.init(name: titleFontName, size: 24.0);
            tmpLabel!.textColor = primaryColor;
            tmpLabel!.textAlignment = NSTextAlignment.center;
            tmpLabel!.transform = self.view.transform.rotated(by: CGFloat(NSNumber.init(value: Double.init(index) * (Double.pi/2)).floatValue));
            tmpLabel!.tag = index + 101;
            
            self.titlesView!.insertSubview(tmpLabel!, at: 0);
        }
    }
    
    private func getBulletAtIndex(index : Int) -> CAShapeLayer? {
        let count : Int = (pagerControlView?.layer.sublayers?.count)!;
        for i in 0..<count {
            let tmp : CALayer = (pagerControlView?.layer.sublayers?[i])!;
            if tmp.name != nil {
                if tmp.name == String.init(format: "bullet_%d", index) {
                    return tmp as? CAShapeLayer;
                }
            }
        }
        return nil;
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
                bullet.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            }else{
                bullet.opacity = opacity;
                bullet.transform = CATransform3DMakeScale(minScale, minScale, 1.0);
            }
            
            pagerControlView!.layer.addSublayer(bullet);
        }
    }
    
    private func createBullet() -> CAShapeLayer {
        var circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: 15, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true);
        
        let shapeLayer = CAShapeLayer();
        shapeLayer.path = circlePath.cgPath;
        shapeLayer.fillColor = UIColor.clear.cgColor;
        shapeLayer.strokeColor = secondaryColor.cgColor;
        shapeLayer.lineWidth = 1;
        shapeLayer.lineDashPattern = [3, 3];
        
        circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: 10, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true);
        let disc = CAShapeLayer();
        disc.path = circlePath.cgPath;
        disc.fillColor = primaryColor.cgColor;
        disc.strokeColor = UIColor.clear.cgColor;
        
        shapeLayer.shadowColor = primaryColor.cgColor
        shapeLayer.shadowRadius = 10.0
        shapeLayer.shadowOpacity = 0.6
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0)

        shapeLayer.addSublayer(disc);
        
        return shapeLayer;
    }
    
    private func pointOnCircle(index : Int, count : Int) -> CGPoint {
        angle = (Double.pi * 2) / Double(count);
        let x : Double = Double(radius) * cos(Double(index) * angle) + Double(pagerControlView!.frame.size.width / 2);
        let y : Double = Double(radius) * sin(Double(index) * angle) + Double(pagerControlView!.frame.size.height / 2);
    
        return CGPoint(x: x, y: y);
    }

    @objc private func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        var direction : Int = 1;
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            self.rotate(direction: CircularPagerDirection.Right);
            let index = (currentPageIndex > 0) ? currentPageIndex - 1 : (bulletsOnCircle - 1);
            self.changeSelectedPage(index: index);
            direction = 1;
        }else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            self.rotate(direction: CircularPagerDirection.Left);
            let index = (currentPageIndex + 1) % bulletsOnCircle;
            self.changeSelectedPage(index: index);
            direction = -1;
        }

        /*UIView.animate(withDuration: 0.15, animations: {
            self.titleLabel.alpha = 0.0;
        }) { (success) in
            if(self.viewControllers.count > 0){
                self.titleLabel.text = self.viewControllers[self.currentPageIndex % self.viewControllers.count].title;
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.titleLabel.alpha = 1.0;
            })
        }*/
        self.arrangeControllers();
    }
    
    private func rotate(direction : CircularPagerDirection) {
        var rotAngle : Double = angle;
        var rotAngleTitle : Double = Double.pi/2;
        
        switch direction {
        case CircularPagerDirection.Right:
            rotAngle = angle * 1 ;
            rotAngleTitle = Double.pi/2;
            break;
        case CircularPagerDirection.Left:
            rotAngle = angle * -1;
            rotAngleTitle = Double.pi/2 * -1;
            break;
        }
        
        UIView.animate(withDuration: 0.3) {
            self.pagerControlView!.transform = self.pagerControlView!.transform.rotated(by: CGFloat(NSNumber.init(value: rotAngle).floatValue));
            self.contentsContainerView!.transform = self.contentsContainerView!.transform.rotated(by: CGFloat(NSNumber.init(value: rotAngle).floatValue));
            self.titlesView!.transform = self.titlesView!.transform.rotated(by: CGFloat(NSNumber.init(value: rotAngleTitle).floatValue));
        }
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
    
    private func setSelected(bullet : CAShapeLayer, isSelected : Bool){
        bullet.opacity = (isSelected) ? 1.0 : opacity;
        bullet.transform = CATransform3DMakeScale((isSelected) ? 1.0 : minScale, (isSelected) ? 1.0 : minScale, 1.0);
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
