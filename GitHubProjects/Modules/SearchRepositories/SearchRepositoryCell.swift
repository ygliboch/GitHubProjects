//
//  SearchRepositoryCell.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 23.02.2021.
//

import UIKit
import RxSwift
import RxCocoa

class SearchRepositoryCell: UITableViewCell {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var isViewedIcon: UIImageView!
    @IBOutlet weak var repositoryStarsCount: UILabel!
    @IBOutlet weak var repositoryDescription: UILabel!
    @IBOutlet weak var repositoryName: UILabel!
    
    //MARK: - Properties
    
    let tapGesture = UITapGestureRecognizer()
    private var bag = DisposeBag()
    
    //MARK: - Cell life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGestureRepositoryName()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    //MARK: - Bind ui
    
    private func addTapGestureRepositoryName() {
        repositoryName.addGestureRecognizer(tapGesture)
        repositoryName.isUserInteractionEnabled = true
    }

    func configure(with repository: Repository) {
        repositoryStarsCount.text = "\(repository.stargazersCount ?? 0)"
        repositoryName.text = repository.fullName ?? ""
        repositoryDescription.text = repository.description
        let isViewed = CoreDataManager.instance.isRepositorySaved(repositoryId: repository.id ?? 0)
        isViewedIcon.isHidden = !(isViewed)
    }
    
    func configure(with repository: ViewedRepository) {
        repositoryStarsCount.text = "\(Int(repository.stargazersCount))"
        repositoryName.text = repository.fullName ?? ""
        repositoryDescription.text = repository.repositoryDescription
        let isViewed = CoreDataManager.instance.isRepositorySaved(repositoryId: Int(repository.id))
        isViewedIcon.isHidden = !(isViewed)
        isViewedIcon.isHidden = true
        
    }
    
    //MARK: - Bind rx
    
    func bindViewModel<O>(row: Int, repositoryNameSelected: O) where O: ObserverType, O.Element == Int {
        tapGesture.rx.event
            .map { _ in row }
            .bind(to: repositoryNameSelected)
            .disposed(by: bag)
    }
}
