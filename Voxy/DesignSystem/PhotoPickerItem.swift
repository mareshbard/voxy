import PhotosUI
import SwiftUI

struct PhotoPickerItem: View {

    let title: String

    var systemImage: String = "photo.on.rectangle.angled"

    var filter: PHPickerFilter = .images

    @Binding var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection, matching: filter) {
            Label(title, systemImage: systemImage)
                .labelStyle(.titleAndIcon)
        }
    }
}

