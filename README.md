
<p align="center">
  <img src="./Images/prex.png">
</p>
<p align="center">
  <img src="http://img.shields.io/badge/platform-iOS%20|%20tvOS%20|%20macOS%20|%20watchOS-blue.svg?style=flat" alt="Platform" />
  <a href="https://developer.apple.com/swift">
    <img src="http://img.shields.io/badge/Swift-4.1%20|%204.2-brightgreen.svg?style=flat" alt="Language">
  </a>
  <a href="https://github.com/Carthage/Carthage">
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage">
  </a>
  <a href="https://cocoapods.org/pods/Prex">
    <img src="https://img.shields.io/cocoapods/v/Prex.svg?style=flat" alt="Version">
  </a>
  <a href="https://cocoapods.org/pods/Prex">
    <img src="https://img.shields.io/cocoapods/l/Prex.svg?style=flat" alt="License">
  </a>
  <a href="https://travis-ci.org/marty-suzuki/Prex">
    <img src="https://img.shields.io/travis/marty-suzuki/Prex.svg?style=flat" alt="CI Status">
  </a>
</p>

Prex is a framework which makes an unidirectional data flow application possible with MVP architecture.

# Concept

![](./Images/data-flow.png)

- [State](#state)
- [Action](#action)
- [Mutation](#mutation)
- [Presenter](#presenter)
- [View](#view)

## State

```swift
struct CounterState: State {
    var count: Int = 0
}
```

## Action

```swift
enum CounterAction: Action {
    case increment
    case decrement
}
```

## Mutation

```swift
struct CounterMutation: Mutation {
    func mutate(action: CounterAction, state: inout CounterState) {
        switch action {
        case .increment:
            state.count += 1

        case .decrement:
            state.count -= 1
        }
    }
}
```

## Presenter

```swift
extension Presenter where Action == CounterAction, State == CounterState {
    func increment() {
        dispatch(.increment)
    }

    func decrement() {
        if state.count > 0 {
            dispatch(.decrement)
        }
    }
}
```

## View

```swift
final class CounterViewController: UIViewController {
    private let counterLabel: UILabel
    private lazy var presenter = Presenter(view: self,
                                           state: CounterState(),
                                           mutation: CounterMutation())

    @objc private func incrementButtonTap(_ button: UIButton) {
        presenter.increment()
    }

    @objc private func decrementButtonTap(_ button: UIButton) {
        presenter.decrement()
    }
}

extension CounterViewController: View {
    func refrect(change: ValueChange<CounterState>) {
        if let count = change.valueIfChanged(for: \.count) {
            counterLabel.text = "\(count)"
        }
    }
}
```

# Example

## Project

[Example](./Example)

## Playground

![](./Images/playground.png)
