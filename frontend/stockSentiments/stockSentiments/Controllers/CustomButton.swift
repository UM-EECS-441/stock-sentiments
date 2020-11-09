//
//  CustomButton.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 11/9/20.
//

import Foundation
import UIKit


class CustomButton : UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        self.layer.cornerRadius = 10
    }

}
