//
//  GitHubApi.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 23.02.2021.
//

import RxCocoa
import RxSwift

protocol GitHubApiProvider {
    func getRepositories(for query: String, page: Int) -> Observable<[Repository]?>
}

class GitHubApi: GitHubApiProvider {
    
    private var accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func getRepositories(for query: String, page: Int) -> Observable<[Repository]?> {
        return get(url: "https://api.github.com/search/repositories?per_page=15&page=\(page)&q=\(query)&sort=stars").map {data -> [Repository]? in
            guard data != nil,
                  let response = try? JSONDecoder().decode(SearchRepositories.self, from: data!) else {
                return nil
            }
            return response.items
        }
    }
    
    private func get(url: String) -> Observable<Data?> {
        guard let url = URL(string: url) else { return Observable.empty() }
        var request = URLRequest(url: url)
        request.setValue("token " + accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return URLSession.shared.rx.data(request: request)
            .map { Optional.init($0) }
            .catchErrorJustReturn(nil)
    }
}
