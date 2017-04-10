//
//  LaunchAnimation.swift
//  VueiPhoneApp
//
//  Created by 海底捞lzx on 2017/4/8.
//  Copyright © 2017年 海底捞. All rights reserved.
//

import UIKit

protocol SkipToHomeDelegate {
    func skipToHomeVc()
}

class LaunchAnimation: UIViewController {

    @IBOutlet weak var launchImage1: UIImageView!
    @IBOutlet weak var launchImage2: UIImageView!
    
    var pageData: [String] = []
    
    var _featureStoryboard: UIStoryboard?
    var featureStoryboard: UIStoryboard {
        get {
            if _featureStoryboard == nil {
                _featureStoryboard = self.storyboard
            }
            return _featureStoryboard!
        }
        set {
            _featureStoryboard = newValue
        }
    }
    
    var homeVc: UIViewController?
    
    var _pageViewController: UIPageViewController?
    var pageViewController: UIPageViewController {
        get {
            if _pageViewController == nil {
                _pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
            }
            return _pageViewController!
        }
        set {
            _pageViewController = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func configPageVc() {
            
            self.pageViewController.delegate = self
            
            self.addChildViewController(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            
            let pageViewRect = self.view.bounds
            self.pageViewController.view.frame = pageViewRect
            
            self.pageViewController.didMove(toParentViewController: self)
            
            self.pageViewController.dataSource = self
            self.pageViewController.view.alpha = 0
            
        }

        // Do any additional setup after loading the view.
        configPageVc()
        
        // TODO: 设置主页
        self.homeVc = self.featureStoryboard.instantiateViewController(withIdentifier: "ViewController")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: 渐变动画
        UIView.animate(withDuration: 0.5, animations: {
            self.launchImage1.alpha = 0
        }) { (finish: Bool) in
            self.showFeatureAndHome()
        }
        
    }
    
    func showFeatureAndHome() {
        
        self.pageData = ["1", "2", "3"]
        let startingViewController: UIViewController = self.featureVc(atIndex: 0)!
        let viewControllers = [startingViewController]
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        UIView.animate(withDuration: 0.5, animations: {
            self.launchImage2.alpha = 0
            self.pageViewController.view.alpha = 1
        }, completion: { (finish2) in
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LaunchAnimation: UIPageViewControllerDelegate {
    
}

extension LaunchAnimation: UIPageViewControllerDataSource, SkipToHomeDelegate {
    
    func featureVc(atIndex index: Int) -> UIViewController? {
        guard index <= self.pageData.count || index >= 0 else {
            return nil
        }
        
        // MARK: 设置最后一个控制器
        if index == self.pageData.count {
            self.pageData = []
            return self.homeVc
        }
        
        let featureVc = self.featureStoryboard.instantiateViewController(withIdentifier: "NewFeature") as! NewFeatureVc
        featureVc.featureData = pageData[index]
        featureVc.delegate = self
        
        return featureVc
    }
    
    func index(ofFeatureVc viewController: UIViewController) -> Int {
        guard let viewController = viewController as? NewFeatureVc else {
            return NSNotFound
        }
        return self.pageData.index(of: viewController.featureData) ?? NSNotFound
    }
    
    // MARK:- 跳过
    func skipToHomeVc() {
        self.pageData = []
        self.pageViewController.setViewControllers([self.homeVc!], direction: .forward, animated: true) { (done) in
            
        }
    }
    
    // MARK:- dataSource
    /// 前一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = self.index(ofFeatureVc: viewController)
        
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.featureVc(atIndex: index)
    }
    
    /// 后一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.index(ofFeatureVc: viewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count + 1 {
            return nil
        }
        return self.featureVc(atIndex: index)
    }
}

class NewFeatureVc: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var _featureData: String = ""
    var featureData: String {
        get {
            return _featureData
        }
        set {
            _featureData = newValue
            let c = [UIColor.red, UIColor.brown, UIColor.cyan, UIColor.darkGray]
            
            self.view.backgroundColor = c[Int(newValue)!]
            if let url = URL(string: newValue), let imgData = try? Data(contentsOf: url) {
                self.imgView.image = UIImage(data: imgData)
            }
        }
    }
    
    var delegate: SkipToHomeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func skipAction(_ sender: UIButton) {
        self.delegate?.skipToHomeVc()
    }
    
}













