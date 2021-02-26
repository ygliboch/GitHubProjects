//
//  ViewedRepository+CoreDataProperties.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 26.02.2021.
//
//

import Foundation
import CoreData


extension ViewedRepository {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ViewedRepository> {
        return NSFetchRequest<ViewedRepository>(entityName: "ViewedRepository")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var htmlUrl: String?
    @NSManaged public var id: Double
    @NSManaged public var repositoryDescription: String?
    @NSManaged public var stargazersCount: Double
    @NSManaged public var date: Date?

}

extension ViewedRepository : Identifiable {

}
