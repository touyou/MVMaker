//
//  TutorialPageViewController.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/03.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {

    var pageData: [UIImage]!
    var currentIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageData = [UIImage(named: "tutorial1")!, UIImage(named: "tutorial2")!, UIImage(named: "tutorial3")!]
        currentIndex = 0
        
        self.delegate = self
        
        let startViewController: PageViewController = viewControllerAtIndex(0, storyboard: UIStoryboard(name: "MainViewController", bundle: nil))!
        let viewControllers = [startViewController]
        self.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        
        self.dataSource = self
        self.view.backgroundColor = UIColor.darkGray
        self.view.gestureRecognizers = self.gestureRecognizers
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Utility
    func indexOfViewController(_ viewController: PageViewController) -> Int {
        
        if let dataObject = viewController.image {
            
            return self.pageData.index(of: dataObject)!
        } else {
            
            return NSNotFound
        }
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> PageViewController? {
        
        if self.pageData.count == 0 || index >= self.pageData.count {
            
            return nil
        }
        let infoViewController = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
        infoViewController.image = self.pageData[index]
        return infoViewController
    }
}

extension TutorialPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOfViewController(viewController as! PageViewController)
        if index == 0 || index == NSNotFound {
            
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOfViewController(viewController as! PageViewController)
        if index == self.pageData.count - 1 || index == NSNotFound {
            
            return nil
        }
        index += 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    // MARK: 向きはPortrait限定なので常に表示されるページは一個
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        
        let currentViewController = self.viewControllers![0]
        let viewControllers = [currentViewController]
        self.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        self.isDoubleSided = false
        return .min
    }
    // MARK: 現在地
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let viewController = pageViewController.viewControllers?.first as? PageViewController {
            
            currentIndex = indexOfViewController(viewController)
        }
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return currentIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return 3
    }

}
