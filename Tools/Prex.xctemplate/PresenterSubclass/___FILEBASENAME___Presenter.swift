//___FILEHEADER___

import Prex

final class ___VARIABLE_productName___Presenter: Presenter<___VARIABLE_productName___Action, ___VARIABLE_productName___State> {

    init<View: Prex.View>(view: View) where View.State == ___VARIABLE_productName___State {
        let flux = Flux(state: ___VARIABLE_productName___State(), mutation: ___VARIABLE_productName___Mutation())
        super.init(view: view, flux: flux)
    }

    // - FIXME: This is sample function. Please replace this.
    func setFixme(_ value: Int) {
        dispatch(.fixme(value))
    }
}
