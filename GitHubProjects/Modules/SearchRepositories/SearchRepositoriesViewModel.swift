//
//  SearchRepositoriesViewModel.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 23.02.2021.
//

import Foundation
import RxSwift
import RxCocoa

class SearchRepositoriesViewModel: ViewModelType {
    
    //MARK: - Properties
    
    struct Input {
        let searchText: Driver<String>
        let selected: Observable<Int>
        let paginationTrigger: Observable<CGPoint>
        let viewedRepositoriesTrigger: Driver<Void>
    }
    
    struct Output {
        let loading: Driver<Bool>
        let results: BehaviorRelay<[Repository]>
        let selectedDone: Driver<Void>
        let viewedRepositories: Driver<Void>
    }
    
    struct Dependencies {
        let api: GitHubApiProvider
        let navigator: SearchNavigatable
    }
    
    private let dependencies: Dependencies
    private var repositoriesPage = 1
    private let query = BehaviorRelay(value: "")
    let bag = DisposeBag()
    
    //MARK: - Init
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    //MARK: - Bind rx
    
    func transform(input: SearchRepositoriesViewModel.Input) -> SearchRepositoriesViewModel.Output {
        let activityIndicator = ActivityIndicator()
        let loading = activityIndicator.asDriver()
        let results = BehaviorRelay<[Repository]>(value: [])
    
        
        input.searchText
            .skip(1)
            .asObservable()
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: query)
            .disposed(by: bag)
        
        query.asObservable()
            .distinctUntilChanged()
            .flatMapLatest {  _ ->  Observable<[Repository]> in
                self.repositoriesPage = 1
                return Observable.zip(self.dependencies.api.getRepositories(for: self.query.value, page: self.repositoriesPage),
                                      self.dependencies.api.getRepositories(for: self.query.value, page: self.repositoriesPage + 1))
                    .trackActivity(activityIndicator)
                    .map { ($0 ?? []) + ($1 ?? []) }
            }
            .subscribe { (repos) in
                results.accept(repos)
            }.disposed(by: bag)
        
        input.paginationTrigger.asObservable()
            .distinctUntilChanged()
            .flatMapFirst {  _ -> Observable<[Repository]> in
                self.repositoriesPage += 2
                return Observable.zip(self.dependencies.api.getRepositories(for: self.query.value, page: self.repositoriesPage),
                                      self.dependencies.api.getRepositories(for: self.query.value, page: self.repositoriesPage + 1))
                    .trackActivity(activityIndicator)
                    .map { ($0 ?? []) + ($1 ?? []) }
            }.subscribe { (repos) in
                results.accept(results.value + repos)
            }.disposed(by: bag)
        
        let selectedDone = input.selected
            .asObservable()
            .withLatestFrom(results) { [weak self] row, repositories in
                self?.dependencies.navigator.toRepositoryDetails(urlString: repositories[row].htmlUrl ?? "")
                CoreDataManager.instance.saveRepository(repositories[row])
            }
            .map { _ in
                results.accept(results.value)
                return ()
            }
            .asDriver(onErrorJustReturn: ())
        
        let viewedRepositories = input.viewedRepositoriesTrigger
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.dependencies.navigator.toViewedRepositories()
                
            })
            .asDriver()
        
        return SearchRepositoriesViewModel.Output(loading: loading,
                      results: results,
                      selectedDone: selectedDone, viewedRepositories: viewedRepositories)
    }
}
