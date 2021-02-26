//
//  LoginNavigator.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 26.02.2021.
//

import UIKit

protocol LoginNavigatable {
    func toSearch(with token: String)
}

final class LoginNavigator: LoginNavigatable {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func toSearch(with token: String) {
        let vc = UIStoryboard.main.searchRepositoriesViewController
        let viewModel = SearchRepositoriesViewModel(dependencies: SearchRepositoriesViewModel.Dependencies(api: GitHubApi(accessToken: token), navigator: SearchNavigator(navigationController: navigationController)))
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
