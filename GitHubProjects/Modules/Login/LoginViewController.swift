//
//  LoginViewController.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 22.02.2021.
//

import UIKit

import FirebaseAuth
import RxSwift
import RxCocoa
import AuthenticationServices

var AccessToken = ""

class LoginViewController: UIViewController{

    //MARK: - IBOutlets
    
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - Properties
    
    private let bag = DisposeBag()
    private var viewModel: LoginViewModel!
    
    //MARK: - Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarShadowImage()
        bindViewModel()
    }
    
    //MARK: - Bind ui

    private func configureNavigationBarShadowImage() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    //MARK: - Bind rx
    
    private func bindViewModel() {
        viewModel = LoginViewModel(dependencies: LoginViewModel.Dependencies(navigator: LoginNavigator(navigationController: navigationController ?? UINavigationController())))
        let output = viewModel.transform(input: LoginViewModel.Input(loginTaps: loginButton.rx.tap.asDriver()))
        output.result
            .drive(onNext: { [weak self] result in
                guard let strongSelf = self else { return }
                if result == .failure {
                    let alert = UIAlertController(title: "Oops!", message: "Login failed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                    strongSelf.present(alert, animated: true, completion: nil)
                }
                strongSelf.loginButton.isUserInteractionEnabled = false
            })
            .disposed(by: bag)
        
        output.disableButton
            .drive(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.loginButton.isUserInteractionEnabled = false
            })
            .disposed(by: bag)
    }

}
