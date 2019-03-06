//___FILEHEADER___

import Prex

enum ___VARIABLE_productName___Action: Action {

    // - FIXME: This is sample case. Please replace this.
    case fixme(Int)
}

struct ___VARIABLE_productName___State: State {

    // - FIXME: This is sample property. Please replace this.
    fileprivate(set) var fixme: Int = 0
}

struct ___VARIABLE_productName___Mutation: Mutation {

    func mutate(action: ___VARIABLE_productName___Action, state: inout ___VARIABLE_productName___State) {
        switch action {

        // - FIXME: This is sample case. Please replace this.
        case let .fixme(value):
            state.fixme = value
        }
    }
}
