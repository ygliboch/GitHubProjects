//
//  SearchRepositoriesViewController.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 23.02.2021.
//

import UIKit
import RxSwift
import RxCocoa

class SearchRepositoriesViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    private let viewedRepositoriesButton = UIButton()
    private let bag = DisposeBag()
    var viewModel: SearchRepositoriesViewModel!
    
    //MARK: - Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItems()
        bindViewModel()
    }
    
    //MARK: - Bind ui
    
    private func configureNavigationItems() {
        viewedRepositoriesButton.setImage(#imageLiteral(resourceName: "glassesButton"), for: .normal)
        viewedRepositoriesButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: viewedRepositoriesButton)
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    //MARK: - Bind rx
    
    private func bindViewModel() {
        
        let paginationTrigger = tableView.rx.contentOffset
            .filter {
                return $0.y > self.tableView.contentSize.height - (self.tableView.frame.height * 2)
            }
            .asObservable()
        let repositoryNameSelected = PublishSubject<Int>()
        
        let input = SearchRepositoriesViewModel.Input(searchText: searchBar.rx.text.orEmpty.asDriver(),
                                                      selected: repositoryNameSelected,
                                                      paginationTrigger: paginationTrigger,
                                                      viewedRepositoriesTrigger: viewedRepositoriesButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.loading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: bag)
        
        
        output.results
            .asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: SearchRepositoryCell.self), cellType: SearchRepositoryCell.self)) { (row, element, cell) in
                cell.configure(with: element)
                cell.bindViewModel(row: row, repositoryNameSelected: repositoryNameSelected)
            }
            .disposed(by: bag)
        
        output.selectedDone
            .drive()
            .disposed(by: bag)
        output.viewedRepositories
            .drive()
            .disposed(by: bag)
        
        searchBar.rx.searchButtonClicked.subscribe { (_) in
            self.view.endEditing(true)
        }
        .disposed(by: bag)

    }

}
