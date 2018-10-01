//
//  Presenter.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

// MARK: - Presenter

open class Presenter<Action: Prex.Action, State: Prex.State> {

    open var state: State {
        return store.state
    }

    private let dispatcher: Dispatcher<Action>
    private let store: Store<State>
    private let refrectInMain: (ValueChange<State>) -> ()

    public init<View: Prex.View, Mutation: Prex.Mutation>(view: View, state: State, mutation: Mutation, dispatcher: Dispatcher<Action> = .init()) where Mutation.State == State, Mutation.Action == Action, View.State == State {

        self.dispatcher = dispatcher

        let _view = _WeakView(view)
        self.refrectInMain = { [_view] change in
            if Thread.isMainThread {
                _view.refrect(change: change)
            } else {
                DispatchQueue.main.async {
                    _view.refrect(change: change)
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

// MARK: - _WeakView

private struct _WeakView<View: Prex.View> {

    private weak var view: View?

    init(_ view: View) {
        self.view = view
    }

    func refrect(change: ValueChange<View.State>) {
        view?.refrect(change: change)
    }
}
