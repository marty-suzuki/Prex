import PlaygroundSupport
import Prex
import UIKit

// MARK: - ViewController

final class CounterViewController: UIViewController {

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private(set) lazy var incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Increment +", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(self.incrementButtonTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private(set) lazy var decrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Decrement -", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(self.decrementButtonTap(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var presenter = Presenter(view: self,
                                           state: CounterState(),
                                           mutation: CounterMutation())

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        presenter.reflect()

        // setup stackView
        do {
            let rootStackView = UIStackView(arrangedSubviews: [counterLabel])
            rootStackView.translatesAutoresizingMaskIntoConstraints = false
            rootStackView.alignment = .center
            rootStackView.axis = .vertical
            rootStackView.spacing = 10

            let buttonStackView = UIStackView(arrangedSubviews: [incrementButton, decrementButton])
            buttonStackView.alignment = .center
            buttonStackView.axis = .vertical
            buttonStackView.translatesAutoresizingMaskIntoConstraints = false
            rootStackView.addArrangedSubview(buttonStackView)

            view.addSubview(rootStackView)
            view.centerXAnchor.constraint(equalTo: rootStackView.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: rootStackView.centerYAnchor).isActive = true
        }
    }

    @objc private func incrementButtonTap(_ button: UIButton) {
        presenter.increment()
    }

    @objc private func decrementButtonTap(_ button: UIButton) {
        presenter.decrement()
    }
}

// MARK: - Prex implementation

extension CounterViewController: View {
    func reflect(change: ValueChange<CounterState>) {

        if let count = change.valueIfChanged(for: \.count) {
            counterLabel.text = "\(count)"
        }
    }
}

enum CounterAction: Action {
    case increment
    case decrement
}

struct CounterState: State {
    var count: Int = 0
}

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

// MARK: - Playground

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = CounterViewController()
