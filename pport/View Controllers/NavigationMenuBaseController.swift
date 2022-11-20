//
//  NavigationMenuBaseController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 26.01.2022.
//

import UIKit

class NavigationMenuBaseController: UITabBarController {
    
    var customTabBar: TabNavigationMenu!
    var tabBarHeight: CGFloat = 67.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
        delegate = self
        
        checkProfileInfo()
    }
    
    func loadTabBar() {
        let tabItems: [TabItem] = [.watchlist, .portfolio, .profile]
        self.setupCustomTabMenu(tabItems) { (controllers) in
            self.viewControllers = controllers
        }
        self.selectedIndex = 0 // default our selected index to the first item
    }
    
    func setupCustomTabMenu(_ menuItems: [TabItem], completion: @escaping ([UIViewController]) -> Void) {
        let frame = CGRect(x: tabBar.frame.origin.x, y: tabBar.frame.origin.x, width: tabBar.frame.width, height: tabBarHeight)
        var controllers = [UIViewController]()
        
        tabBar.isHidden = true
        
        self.customTabBar = TabNavigationMenu(menuItems: menuItems, frame: frame)
        self.customTabBar.translatesAutoresizingMaskIntoConstraints = false
        self.customTabBar.clipsToBounds = true
        self.customTabBar.itemTapped = self.changeTab
        self.view.addSubview(customTabBar)
        
        // Add positioning constraints to place the nav menu right where the tab bar should be
        self.customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor).isActive = true
        self.customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor).isActive = true
        self.customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width).isActive = true
        self.customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true
        self.customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        for i in 0 ..< menuItems.count {
            controllers.append(menuItems[i].viewController) // we fetch the matching view controller and append here
        }
        self.view.layoutIfNeeded() // important step
        completion(controllers) // setup complete. handoff here
    }
    
    func changeTab(tab: Int) {
        self.selectedIndex = tab
    }
}


extension NavigationMenuBaseController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.25

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart

        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }

    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}

extension NavigationMenuBaseController {
    
    func checkProfileInfo() {
        
        guard let session = KeyChainManager.shared.read(service: .session, type: Session.self) else {
            NSLog("NavigationMenuBaseController.checkProfileInfo: No session in KeyChain", "")
            return
        }
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.validateSession(session: session.session, onFailure: { _, _ in
                DispatchQueue.main.async {
                    UserDefaultsManager.shared.removeAll()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
                    return
                }
            }, onSuccess: {})
        }, notAvailable: {})
        
    }
}
