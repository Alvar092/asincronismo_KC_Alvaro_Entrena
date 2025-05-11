//
//  TransformationCardView.swift
//  asincronismo_aentrena
//
//  Created by Álvaro Entrena Casas on 11/5/25.
//

import UIKit

class TransformationCardView: UIView {

    @IBOutlet weak var transformationImageView: UIImageView!
    
    @IBOutlet weak var transformationNameLabel: UILabel!
    
    required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
    
    private func commonInit() {
            // Carga la vista desde el xib
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "TransformationCardView", bundle: bundle)
            guard let view = nib.instantiate(withOwner: self).first as? UIView else { return }
            
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(view)
        }

        // MARK: - Método para configurar la vista
        func configure(with transformation: TransformationModel) {
            transformationNameLabel.text = transformation.name
            // Aquí puedes cargar la imagen real desde URL si hace falta
            transformationImageView.image = UIImage(named: transformation.photo)
        }
    
    
    
}
