//
//  Presenter.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

// MARK: - Presenter

open class Presenter<Mutation: Prex.Mutation, State, Action> where Action == Mutation.Action, State == Mutation.State {

    open var state: State {
        return store.state
    }

    private let weakView: _WeakAnyView<State>
    private let dispatcher: Dispatcher<Action>
    private let store: Store<Mutation>
    private let refrectInMain: (ValueChange<State>) -> ()

    public init<View: Prex.View>(view: View, state: State, mutation: Mutation, dispatcher: Dispatcher<Action> = .init()) where View.State == State {

        self.weakView = _WeakAnyView(view)
        self.dispatcher = dispatcher

        self.refrectInMain = { [weakView] change in
            if Thread.isMainThread {
                weakView.refrect(change: change)
            } else {
                DispatchQueue.main.async {
                    weakView.refrect(change: change)
                }
            }
        }
        self.store = Store(dispatcher: dispatcher, state: state, mutation: mutation) { [refrectInMain] in refrectInMain($0) }
    }

    public func dispatch(_ action: Action) {
        dispatcher.dispatch(action)
    }

    public func refrect() {
        refrectInMain(ValueChange(new: state, old: nil))
    }
}

// MARK: - _WeakAnyView

private struct _WeakAnyView<State: Prex.State> {

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
