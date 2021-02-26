//
//  UIStoryboardExtension.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 25.02.2021.
//

import UIKit

extension UIStoryboard {
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIStoryboard {
    var searchRepositoriesViewController: SearchRepositoriesViewController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "SearchRepositoriesViewController") as? SearchRepositoriesViewController else {
            fatalError("LoginViewController couldn't be found in Storyboard file")
        }
        return vc
    }
    
    var viewedRepositoriesController: ViewedRepositoriesController {
        guard let vc = UIStoryboard.main.instantiateViewController(withIdentifier: "ViewedRepositoriesController") as? ViewedRepositoriesController else {
            fatalError("LoginViewController couldn't be found in Storyboard file")
        }
        return vc
    }
    
}
