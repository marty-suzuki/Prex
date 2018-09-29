//
//  Presenter.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

open class Presenter<Mutation: Prex.Mutation,
                     State,
                     Action>
                     where Action == Mutation.Action,
                           State == Mutation.State {

    private let view: WeakAnyView<State>
    private let store: Store<Mutation>

    public let actionCreator: ActionCreator<Action>

    open var state: State {
        return store.state
    }

    public init<View: Prex.View>(view: View,
                                 state: State,
                                 mutation: Mutation) where View.State == State {
        let dispatcher = Dispatcher<Action>()
        let actionCreator = ActionCreator(dispatcher: dispatcher)
        self.store = Store(dispatcher: dispatcher, state: state, mutation: mutation)
        self.actionCreator = actionCreator
        self.view = WeakAnyView(view)

        store.changed = { [weak self] change in
            self?.refrectInMain(change: change)
        }
    }

    public func refrect() {
        refrectInMain(change: ValueChange(new: state, old: nil))
    }

    private func refrectInMain(change: ValueChange<State>) {
        if Thread.isMainThread {
            view.refrect(change: change)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view.refrect(change: change)
            }
        }
    }
}

private struct WeakAnyView<State: Prex.State> {

    private let _refrect: (ValueChange<State>) -> ()

    init<View: Prex.View>(_ view: View) where View.State == State {
        self._refrect = { [weak view] in
            view?.refrect(change: $0)
        }
    }

    func refrect(change: ValueChange<State>) {
        _refrect(change)
    }
}
