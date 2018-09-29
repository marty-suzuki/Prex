//
//  DetailViewController.Prex.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import UIKit

enum DetailAction: Action {
    case setHTMLURL(URL?)
    case setObservation(NSKeyValueObservation?)
    case setProgress(Double)
    case setName(String)
}

struct DetailState: State {
    fileprivate(set) var htmlURL: URL?
    fileprivate(set) var observation: NSKeyValueObservation?
    fileprivate(set) var progress: Double = 0
    fileprivate(set) var name = ""
}

struct DetailMutation: Mutation {
    func mutate(action: DetailAction, state: inout DetailState) {
        switch action {
        case let .setHTMLURL(url):
            state.htmlURL = url

        case let .setObservation(observation):
            state.observation = observation

        case let .setProgress(progress):
            state.progress = progress
            
        case let .setName(name):
            state.name = name
        }
    }
}

extension Presenter where Action == DetailAction, State == DetailState {
    func progressUpdateParams(from progress: Double) -> ProgressUpdateParams {
        let isShown = 0.0..<1.0 ~= progress
        return ProgressUpdateParams(animated: isShown,
                                    alpha: isShown ? 1 : 0,
                                    progress: Float(progress))
    }

    func observeProgress<Root: NSObject>(of object: Root, for keyPath: KeyPath<Root, Double>) {
        let observation = object.observe(keyPath, options: .new) { [weak self] _, change in
            guard let progress = change.newValue else {
                return
            }
            self?.actionCreator.dispatch(action: .setProgress(progress))
        }
        actionCreator.dispatch(action: .setObservation(observation))
    }

    func setRepository(_ repository: GitHub.Repository) {
        actionCreator.dispatch(action: .setHTMLURL(repository.htmlURL))
        actionCreator.dispatch(action: .setName(repository.name))
    }
}

struct ProgressUpdateParams {
    let animated: Bool
    let alpha: CGFloat
    let progress: Float
}
