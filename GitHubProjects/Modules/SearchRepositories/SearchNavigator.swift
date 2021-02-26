//
//  SearchNavigator.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 26.02.2021.
//

import UIKit

protocol SearchNavigatable {
    func toRepositoryDetails(urlString: String)
    func toViewedRepositories()
}

final class SearchNavigator: SearchNavigatable {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toRepositoryDetails(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    func toViewedRepositories() {
        let vc = UIStoryboard.main.viewedRepositoriesController
        let viewModel = ViewedRepositoriesViewModel(dependencies: ViewedRepositoriesViewModel.Dependencies(navigator: ViewedRepositoriesNavigator(navigationController: navigationController)))
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
