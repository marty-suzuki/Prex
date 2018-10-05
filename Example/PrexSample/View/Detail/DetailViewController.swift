//
//  DetailViewController.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Prex
import UIKit
import WebKit

final class DetailViewController: UIViewController {

    @IBOutlet private(set) weak var progressView: UIProgressView!
    @IBOutlet private(set) weak var webviewContainer: UIView! {
        didSet {
            webviewContainer.addSubview(webview)
            webview.frame = webviewContainer.bounds
            webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }

    let webview = WKWebView(frame: .zero, configuration: .init())

    private(set) lazy var presenter = DetailPresenter(view: self)

    init(repository: GitHub.Repository) {
        super.init(nibName: nil, bundle: nil)

        presenter.setRepository(repository)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.observeProgress(of: webview, for: \.estimatedProgress)
    }
}

extension DetailViewController: View {
    func refrect(change: ValueChange<DetailState>) {

        if case let url? = change.valueIfChanged(for: \.htmlURL) {
            webview.load(URLRequest(url: url))
        }

        if let progress = change.valueIfChanged(for: \.progress) {
            let params = presenter.progressUpdateParams(from: progress)
            UIView.animate(withDuration: 0.3) {
                self.progressView.alpha = params.alpha
                self.progressView.setProgress(params.progress, animated: params.animated)
            }
        }

        if let name = change.valueIfChanged(for: \.name) {
            navigationItem.title = name
        }
    }
}
