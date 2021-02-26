//
//  ReactiveExtension.swift
//  GitHubProjects
//
//  Created by Yaroslava Hlibochko on 26.02.2021.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}
