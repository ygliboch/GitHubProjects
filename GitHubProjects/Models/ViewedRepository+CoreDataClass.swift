//
//  ViewedRepository+CoreDataClass.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 26.02.2021.
//
//

import Foundation
import CoreData

@objc(ViewedRepository)
public class ViewedRepository: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "ViewedRepository"), insertInto: CoreDataManager.instance.persistentContainer.viewContext)
    }
}
