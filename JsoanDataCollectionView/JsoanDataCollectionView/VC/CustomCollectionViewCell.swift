//
//  CustomCollectionViewCell.swift
//  JsoanDataCollectionView
//  Created by Вячеслав Лойе on 25.01.2018.
//  Copyright © 2018 Вячеслав Лойе. All rights reserved.

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelCl: UILabel!
    
    func loadCell() {
        imageView.tintColor = UIColor.black
        imageView.tintColorDidChange()
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.contentMode = .scaleAspectFill
    }
}


