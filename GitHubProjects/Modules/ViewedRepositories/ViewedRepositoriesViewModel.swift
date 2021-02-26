//
//  ViewedRepositoriesViewModel.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 25.02.2021.
//

import RxSwift
import RxCocoa

class ViewedRepositoriesViewModel: ViewModelType {
    
    //MARK: - Properties
    
    struct Input {
        let trigger: Driver<Void>
        let selected: Observable<Int>
        let backButtonTrigger: Driver<Void>
    }
    
    struct Output {
        let results: Driver<[ViewedRepository]>
        let selectedDone: Driver<Void>
        let backDone: Driver<Void>
    }
    
    struct Dependencies {
        let navigator: ViewedRepositoriesNavigatable
    }
    
    private let dependencies: Dependencies
    
    //MARK: - Init
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    //MARK: - Bind rx
    
    func transform(input: ViewedRepositoriesViewModel.Input) -> ViewedRepositoriesViewModel.Output {
        
        let results = input.trigger
            .asObservable()
            .flatMap({ _  -> BehaviorRelay<[ViewedRepository]> in
                CoreDataManager.instance.getRepositories()
            })
            .asDriver(onErrorJustReturn: [])

        
        let selectedDone = input.selected
            .asObservable()
            .withLatestFrom(results) { [weak self] row, repositories in
                self?.dependencies.navigator.toRepositoryDetails(urlString: repositories[row].htmlUrl ?? "")
            }
            .map { _ in return () }
            .asDriver(onErrorJustReturn: ())
        
        let backDone = input.backButtonTrigger
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dependencies.navigator.back()
            }).asDriver()
        
        return ViewedRepositoriesViewModel.Output(results: results,
                      selectedDone: selectedDone,
                      backDone: backDone)
    }
}
