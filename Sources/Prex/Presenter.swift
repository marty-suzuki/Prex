//
//  Presenter.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

open class Presenter<View: Prex.View,
                     Mutation: Prex.Mutation,
                     State,
                     Action>
                     where Mutation.State == View.State,
                           Action == Mutation.Action,
                           State == Mutation.State {

    private weak var view: View?
    private let store: Store<Mutation>

    public let actionCreator: ActionCreator<Action>

    public var state: State {
        return store.state
    }

    public init(view: View,
                state: State,
                mutation: Mutation) {
        let dispatcher = Dispatcher<Action>()
        let actionCreator = ActionCreator(dispatcher: dispatcher)
        self.store = Store(dispatcher: dispatcher, state: state, mutation: mutation)
        self.actionCreator = actionCreator
        self.view = view

        store.changed = { [weak self] change in
            self?.refrectInMain(change: change)
        }
    }

    public func refrect() {
        refrectInMain(change: ValueChange(new: state, old: nil))
    }

    private func refrectInMain(change: ValueChange<State>) {
        if Thread.isMainThread {
            view?.refrect(change: change)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.refrect(change: change)
            }
        }
    }
}
