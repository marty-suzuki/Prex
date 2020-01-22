
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

## Concept

Prex represents **Pre**senter + Flu**x**, therefore it is a combination of Flux and MVP architecture.
In addition, Reactive frameworks are not used in Prex.
To reflect a state to a view, using **Passive View Pattern**.
Flux are used behind of the Presenter.
Data flow is unidirectional that like a below figure.

![](./Images/data-flow.png)

If you use Prex, you have to implement those components.

- [State](#state)
- [Action](#action)
- [Mutation](#mutation)
- [Presenter](#presenter)
- [View](#view)

### State

The State has properties to use in the View and the Presenter.

```swift
struct CounterState: State {
    var count: Int = 0
}
```

### Action

The Action represents internal API of your application.
For example, if you want to increment the count of CounterState, dispatch Action.increment to Dispatcher.

```swift
enum CounterAction: Action {
    case increment
    case decrement
}
```

### Mutation

The Mutation is allowed to mutate the State with the Action.

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

### Presenter

The Presenter has a role to connect between View and Flux components.
If you want to access side effect (API access and so on), you must access them in the Presenter.
Finally, you dispatch those results with `Presenter.dispatch(_:)`.

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

### View

The View displays the State with `View.reflect(change:)`.
It is called by the Presenter when the State has changed.
In addition, it calls the Presenter methods by User interactions.

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
    func reflect(change: StateChange<CounterState>) {
        if let count = change.count?.value {
            counterLabel.text = "\(count)"
        }
    }
}
```

You can get only specified value that has changed in the State from `StateChange.changedProperty(for:)`.

## Advanced Usage

### Shared Store

Initializers of the Store and the Dispatcher are not public access level.
But you can initialize them with `Flux` and inject them with `Presenter.init(view:flux:)`.

This is shared Flux components example.

```swift
extension Flux where Action == CounterAction, State == CounterState {
    static let shared = Flux(state: CounterState(), mutation: CounterMutation())
}
```

or

```swift
enum SharedFlux {
    static let counter = Flux(state: CounterState(), mutation: CounterMutation())
}
```

Inject `Flux` like this.

```swift
final class CounterViewController: UIViewController {
    private lazy var presenter = {
        let flux =  Flux<CounterAction, CounterState>.shared
        return Presenter(view: self, flux: flux)
    }()
}
```

### Presenter Subclass

The Presenter is class that has generic parameters.
You can create the Presenter subclass like this.

```swift
final class CounterPresenter: Presenter<CounterAction, CounterState> {
    init<T: View>(view: T) where T.State == CounterState {
        let flux = Flux(state: CounterState(), mutation: CounterMutation())
        super.init(view: view, flux: flux)
    }

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

### Testing

I'll explain how to test with Prex.
Focus on two test cases in this document.

| 1. Reflection state testing | 2. Create actions testing |
| :-: | :-: |
| ![](./Images/reflection-test.png) | ![](./Images/func-test.png) |

Both tests need the View to initialize a Presenter.
You can create **MockView** like this.

```swift
final class MockView: View {
    var refrectParameters: ((StateChange<CounterState>) -> ())?

    func reflect(change: StateChange<CounterState>) {
        refrectParameters?(change)
    }
}
```



#### 1. Reflection state testing

This test starts with dispatching an Action.
An action is passed to Mutation, and Mutation mutates state with a received action.
The Store notifies changes of state, and the Presenter calls reflect method of the View to reflects state.
Finally, receives state via reflect method parameters of the View.

This is a sample test code.

```swift
func test_presenter_calls_reflect_of_view_when_state_changed() {
    let view = MockView()
    let flux = Flux(state: CounterState(), mutation: CounterMutation())
    let presenter = Presenter(view: view, flux: flux)

    let expect = expectation(description: "wait receiving ValueChange")
    view.refrectParameters = { change in
        let count = change.changedProperty(for: \.count)?.value
        XCTAssertEqual(count, 1)
        expect.fulfill()
    }

    flux.dispatcher.dispatch(.increment)
    wait(for: [expect], timeout: 0.1)
}
```

#### 2. Create actions testing

This test starts with calling the Presenter method as dummy user interaction.
The Presenter accesses side-effect and finally creates an action from that result.
That action is dispatched to the Dispatcher.
Finally, receives action via register callback of the Dispatcher.

This is a sample test code.

```swift
func test_increment_method_of_presenter() {
    let view = MockView()
    let flux = Flux(state: CounterState(), mutation: CounterMutation())
    let presenter = Presenter(view: view, flux: flux)

    let expect = expectation(description: "wait receiving ValueChange")
    let subscription = flux.dispatcher.register { action in
        XCTAssertEqual(action, .increment)
        expect.fulfill()
    }

    presenter.increment()
    wait(for: [expect], timeout: 0.1)
    flux.dispatcher.unregister(subscription)
}
```

#### An addition

You can test mutating state like this.

```swift
func test_mutation() {
    var state = CounterState()
    let mutation = CounterMutation()

    mutation.mutate(action: .increment, state: &state)
    XCTAssertEqual(state.count, 1)

    mutation.mutate(action: .decrement, state: &state)
    XCTAssertEqual(state.count, 0)
}
```

## Example

### Project

You can try Prex with GitHub Repository Search Application [Example](./Example).
Open PrexSample.xcworkspace and run it!

### Playground

You can try Prex counter sample with Playground!
Open Prex.xcworkspace and build `Prex-iOS`.
Finally, you can run manually in Playground.

![](./Images/playground.png)

## Requirements
- Xcode 9.4.1 or greater
- iOS 10.0 or greater
- tvOS 10.0 or greater
- macOS 10.10 or greater
- watchOS 3.0 or greater
- Swift 4.1 or greater

## Installation

### Carthage

If you’re using [Carthage](https://github.com/Carthage/Carthage), simply add Prex to your `Cartfile`:

```ruby
github "marty-suzuki/Prex"
```

### CocoaPods

Prex is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Prex'
```

### Swift Package Manager

Prex is available through `Swift Package Manager`. Just add the url of this repository to your `Package.swift`.

```Package.swift
dependencies: [
    .package(url: "https://github.com/marty-suzuki/Prex.git", from: "0.2.0")
]
```

## Inspired by these unidirectional data flow frameworks

- [VueFlux](https://github.com/ra1028/VueFlux) by [@ra1028](https://github.com/ra1028/VueFlux)
- [ReactorKit](https://github.com/ReactorKit/ReactorKit) by [@devxoul](https://github.com/devxoul)

## Author

marty-suzuki, s1180183@gmail.com

## License

Prex is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
