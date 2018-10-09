//
//  Presenter.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

// MARK: - Presenter

/// Presenter recieves user actions and dispatchs them, finally notifies changes of state to `View`
open class Presenter<Action: Prex.Action, State: Prex.State> {

    /// Current state
    open var state: State {
        return store.state
    }

    private let dispatcher: Dispatcher<Action>
    private let store: Store<State>
    private let reflectInMain: (ValueChange<State>) -> ()
    private lazy var subscription: Subscription<State> = { fatalError("canceller has not initialized yet") }()

    deinit {
        store.removeListener(with: subscription)
    }

    /// Automatically creates Flux components with `State` and `Mutaion`
    public convenience init<View: Prex.View, Mutation: Prex.Mutation>(view: View, state: State, mutation: Mutation) where Mutation.State == State, Mutation.Action == Action, View.State == State {
        let flux = Flux(state: state, mutation: mutation)
        self.init(view: view, flux: flux)
    }

    /// Use this initializer when injects Flux components
    public init<View: Prex.View>(view: View, flux: Flux<Action, State>) where View.State == State {
        self.dispatcher = flux.dispatcher

        let _view = _WeakView(view)
        self.reflectInMain = { [_view] change in
            if Thread.isMainThread {
                _view.reflect(change: change)
            } else {
                DispatchQueue.main.async {
                    _view.reflect(change: change)
                }
            }
        }

        self.store = flux.store
        self.subscription = store.addListener(callback: { [reflectInMain] in reflectInMain($0) })
    }

    /// Dispatches an action
    public func dispatch(_ action: Action) {
        dispatcher.dispatch(action)
    }

    /// Reflects current state to `View` forcefully
    public func reflect() {
        reflectInMain(ValueChange(new: state, old: nil))
    }
}

// MARK: - _WeakView

private struct _WeakView<View: Prex.View> {

    private weak var view: View?

    init(_ view: View) {
        self.view = view
    }

    func reflect(change: ValueChange<View.State>) {
        view?.reflect(change: change)
    }
}
