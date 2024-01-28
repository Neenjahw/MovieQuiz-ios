//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Pavel Popov on 15.01.2024.
//

import UIKit

class AlertPresenter {
    
     var view: UIViewController
    
    init(view: UIViewController) {
        self.view = view
    }
    
    func show(data: AlertModel) {
        let alert = UIAlertController(
            title: data.title,
            message: data.message,
            preferredStyle: .alert)
        alert.view?.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(title: data.buttonText, style: .default) { _ in
            data.buttonAction!()
        }
        
        alert.addAction(action)
        
        view.present(alert, animated: true, completion: nil)
    }
}

