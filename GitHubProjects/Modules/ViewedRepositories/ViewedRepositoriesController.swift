//
//  ViewedRepositoriesController.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 25.02.2021.
//

import UIKit
import RxCocoa
import RxSwift

class ViewedRepositoriesController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    private let backButton = UIButton()
    private let bag = DisposeBag()
    var viewModel: ViewedRepositoriesViewModel!
    
    //MARK: - Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configureBackButton()
    }
    
    //MARK: - Bind ui
    
    private func configureBackButton() {
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    //MARK: - Bind rx

    private func bindViewModel() {
        let repositoryNameSelected = PublishSubject<Int>()
        
        let input = ViewedRepositoriesViewModel.Input(trigger: rx.viewWillAppear.asDriver(),
                                                      selected: repositoryNameSelected,
                                                      backButtonTrigger: backButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
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
        
        output.backDone
            .drive()
            .disposed(by: bag)
    }
}
