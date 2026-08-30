import PhotosUI
import SwiftUI

/// Item do design system para importar uma imagem da galeria.
///
/// Encapsula o `PhotosPicker` do PhotosUI com uma aparência padronizada
/// (ícone + título), para ser reutilizado em formulários e telas do app.
struct PhotoPickerItem: View {
    /// Texto exibido ao lado do ícone.
    let title: String

    /// Símbolo SF Symbols exibido à esquerda do título.
    var systemImage: String = "photo.on.rectangle.angled"

    /// Tipos de mídia que o seletor aceita.
    var filter: PHPickerFilter = .images

    /// Item selecionado pelo usuário.
    @Binding var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection, matching: filter) {
            Label(title, systemImage: systemImage)
                .labelStyle(.titleAndIcon)
        }
    }
}

#Preview {
    @Previewable @State var selection: PhotosPickerItem?

    Form {
        PhotoPickerItem(title: "Importar requisitos de uma imagem",
                        selection: $selection)
    }
}
