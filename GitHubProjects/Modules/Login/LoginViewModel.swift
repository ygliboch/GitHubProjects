//
//  LoginViewModel.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 22.02.2021.
//

import RxSwift
import RxCocoa
import AuthenticationServices
import FirebaseAuth

enum LoginResult {
    case success
    case failure
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}


final class LoginViewModel: ViewModelType {
    
    //MARK: - Properties
    
    struct Input {
        let loginTaps: Driver<Void>
    }
    
    struct Output {
        let result: Driver<LoginResult>
        let disableButton: Driver<Void>
    }
    
    struct Dependencies {
        let navigator: LoginNavigator
    }
    
    private let bag = DisposeBag()
    private var provider: OAuthProvider?
    private var oauthCredential: BehaviorRelay<AuthCredential?> = BehaviorRelay(value: nil)
    private let accessToken = BehaviorRelay<String?>(value: "")
    
    private let dependencies: Dependencies
    
    //MARK: - Init
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    //MARK: - Bind rx
    
    func transform(input: Input) -> Output {
        provider = OAuthProvider(providerID: "github.com")
        
        let disableButton: Driver<Void> = input.loginTaps
            .do(onNext: {
                self.provider?.getCredentialWith(nil) { credential, error in
                    guard let oauthCredential = credential else { return }
                    self.oauthCredential.accept(oauthCredential)
                }
            }).map{ return ()}
        
        oauthCredential.asDriver()
            .drive(onNext: { credential in
                guard let oauthCredential = credential else { return }
                Auth.auth().signIn(with: oauthCredential) { authResult, error in
                    guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
                    self.accessToken.accept(oauthCredential.accessToken)
                }
            })
            .disposed(by: bag)
        
        let result: Driver<LoginResult> = accessToken
            .filter { $0 != ""}
            .map { $0 != nil ? .success : .failure }
            .asDriver(onErrorJustReturn: .failure)
            .do(onNext: { [weak self] loginResult in
                guard loginResult == LoginResult.success,
                      let strongSelf = self else { return }
                strongSelf.dependencies.navigator.toSearch(with: self?.accessToken.value ?? "")
            })
        
        
        
        return Output(result: result, disableButton: disableButton)
    }
}
