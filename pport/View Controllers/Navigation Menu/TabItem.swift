//
//  TabItem.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2021.
//
import UIKit

enum TabItem: String, CaseIterable {
    case watchlist = "watchlist"
    case portfolio = "portfolio"
    case profile = "profile"
    
    
    var viewController: UIViewController {
        switch self {
        case .watchlist:
            return UIStoryboard(name: "TabControllers", bundle: nil).instantiateViewController(identifier: "WatchlistViewController") as! WatchlistViewController
        case .portfolio:
            return UIStoryboard(name: "TabControllers", bundle: nil).instantiateViewController(identifier: "PortfolioViewController") as! PortfolioViewController
        case .profile:
            return UIStoryboard(name: "TabControllers", bundle: nil).instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .watchlist:
            return UIImage(systemName: "star.circle")!
        case .portfolio:
            return UIImage(systemName: "dollarsign.circle")!
        case .profile:
            return UIImage(systemName: "person.circle")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
