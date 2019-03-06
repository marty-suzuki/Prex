//___FILEHEADER___

import Prex
import UIKit

final class ___VARIABLE_productName___ViewController: UIViewController {

    private(set) lazy var presenter = Presenter(view: self,
                                                state: ___VARIABLE_productName___State(),
                                                mutation: ___VARIABLE_productName___Mutation())

    override func viewDidLoad() {
        super.viewDidLoad()

        // - FIXME: This is sample function call. Please replace this.
        presenter.setFixme(12345)
    }
}

extension ___VARIABLE_productName___ViewController: View {

    func reflect(change: StateChange<___VARIABLE_productName___State>) {

        // - FIXME: This is sample if statement. Please replace this.
        if let value = change.changedProperty(for: \.fixme)?.value {
            print(value)
        }
    }
}
