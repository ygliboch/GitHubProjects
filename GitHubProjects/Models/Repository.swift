//
//  Repository.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 26.02.2021.
//

import Foundation

struct SearchRepositories: Codable {
    var items: [Repository]?
}

struct Repository: Codable {
    var id: Int?
    var fullName: String?
    var stargazersCount: Int?
    var description: String?
    var htmlUrl: String?
    
    private enum CodingKeys : String, CodingKey {
        case id, fullName = "full_name", stargazersCount = "stargazers_count", description, htmlUrl = "html_url"
    }
}
