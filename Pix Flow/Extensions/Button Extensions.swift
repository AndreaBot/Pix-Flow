//
//  Button Extensions.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 01/06/2024.
//

import UIKit

extension UIButton {
    func asBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self)
    }
}
