//
//  SearchCell.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    class var identifier: String {
        return String(describing: self)
    }

    class var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle(for: self))
    }

    @IBOutlet private(set) weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 8
            containerView.layer.masksToBounds = true
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    @IBOutlet private(set) weak var repositoryNameLabel: UILabel!
    @IBOutlet private(set) weak var descriptionLabel: UILabel!

    @IBOutlet private(set) weak var languageContainerView: UIView!
    @IBOutlet private(set) weak var languageLabel: UILabel!

    @IBOutlet private(set) weak var starLabel: UILabel!

    func configure(with repository: GitHub.Repository) {
        repositoryNameLabel.text = repository.fullName

        if let description = repository.description {
            descriptionLabel.isHidden = false
            descriptionLabel.text = description
        } else {
            descriptionLabel.isHidden = true
            descriptionLabel.text = nil
        }

        if let language = repository.language {
            languageContainerView.isHidden = false
            languageLabel.text = language
        } else {
            languageContainerView.isHidden = true
            languageLabel.text = nil
        }

        starLabel.text = "★ \(repository.stargazersCount)"
    }
}
