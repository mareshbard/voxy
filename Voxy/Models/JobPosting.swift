//
//  Untitled.swift
//  Voxy
//
//  Created by Voxy Team on 28/08/26.
//

import Foundation
import SwiftData

// assina com @Model - class que represetan o obejto "vaga" que será persistido
@Model
final class JobPosting { // o que é uma vaga? modelo
    var title: String // a vaga tem título
    var descriptionText: String? // a vaga tem uma descrição em text que no Figma parece opcional
    var imageData: Data? // a vaga pode ser através de imagem, que parece opcional no Figma
    // ver com a Ivna a questão dos dois aparecem como não obrigatórios na tela
    init(
        title: String,
        imageData: Data? = nil,
        descriptionText: String? = nil
        
    ) {
        self.title = title
        self.imageData = imageData
        self.descriptionText = descriptionText
        
    }
}
