import PhotosUI
import SwiftUI

struct PhotoPickerItem: View {

    let title: String

    var systemImage: String = "photo.badge.plus"

    var filter: PHPickerFilter = .images

    var isRecognizing: Bool = false

    @Binding var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection, matching: filter) {
            HStack(spacing: 12) {
                if isRecognizing {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: systemImage)
                        .font(.system(size: 22))
                }

                Text(isRecognizing ? "Reconhecendo texto..." : title)
                    .font(.custom("Nunito-SemiBold", size: 14))

                Spacer(minLength: 0)
            }
            .foregroundStyle(Color("PrimaryBlue"))
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("PrimaryBlue"))

                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .offset(x: -5, y: -5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("PrimaryBlue"), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isRecognizing)
    }
}

#Preview {
    PhotoPickerItem(
        title: "Adicionar imagem da vaga",
        selection: .constant(nil)
    )
    .padding()
}
