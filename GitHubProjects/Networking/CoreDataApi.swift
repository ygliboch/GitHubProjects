//
//  CoreDataApi.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 25.02.2021.
//

import CoreData
import RxSwift
import RxCocoa


class CoreDataManager {
    
    static let instance = CoreDataManager()
        
    private init() {}
    
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: persistentContainer.viewContext)!
    }
    
    func saveRepository(_ repository: Repository) {
        let viewedRepository = ViewedRepository()
        viewedRepository.fullName = repository.fullName
        viewedRepository.repositoryDescription = repository.description
        viewedRepository.id = Double(repository.id ?? 0)
        viewedRepository.htmlUrl = repository.htmlUrl
        viewedRepository.stargazersCount = Double(repository.stargazersCount ?? 0)
        viewedRepository.date = Date()
        saveContext()
    }
    
    func getRepositories() -> BehaviorRelay<[ViewedRepository]> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ViewedRepository")
        fetchRequest.fetchLimit = 20
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as? [ViewedRepository]
            let behaviorResults = BehaviorRelay<[ViewedRepository]>(value: results ?? [])
            return behaviorResults
        } catch {
            return BehaviorRelay<[ViewedRepository]>(value: [])
        }
    }
    
    func isRepositorySaved(repositoryId: Int) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ViewedRepository")
        fetchRequest.fetchLimit = 1
        let predicate = NSPredicate(format: "id = \(repositoryId)")
        fetchRequest.predicate = predicate
        
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as? [ViewedRepository]
            
            return results?.first != nil
        } catch {
            return false
        }
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubProjects")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
