//
//  View Extensions.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 30/05/2024.
//

import UIKit

extension UIViewController {
    
    func createStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    func createIconImage(sfSymbol: String) -> UIImageView {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let iconImage = UIImage(systemName: sfSymbol)?.withTintColor(.gray).withConfiguration(largeConfig).withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: iconImage)
        return imageView
    }
    
    func createNoPhotosLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = UIColor(named: "Label Color")
        label.textAlignment = .center
        return label
    }
    
    func noContentAvailableView(sfSymbol: String, text: String) {
        let stack = createStackView()
        self.view.addSubview(stack)
        stack.addArrangedSubview(createIconImage(sfSymbol: sfSymbol))
        stack.addArrangedSubview(createNoPhotosLabel(text: text))
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}
