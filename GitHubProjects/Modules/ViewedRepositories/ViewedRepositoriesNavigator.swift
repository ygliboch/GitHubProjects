//
//  ViewedRepositoriesNavigator.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 26.02.2021.
//

import UIKit

protocol ViewedRepositoriesNavigatable {
    func toRepositoryDetails(urlString: String)
    func back()
}

final class ViewedRepositoriesNavigator: ViewedRepositoriesNavigatable {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toRepositoryDetails(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
}
