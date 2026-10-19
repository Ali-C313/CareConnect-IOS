//
//  ImagePicker.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import PhotosUI

/// Rundes Profilbild mit Fotoauswahl
struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    /// Vorhandenes Bild aus Firebase
    var currentImageURL: String?
    var size: CGFloat = 120

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                preview
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(CCDesign.accent, lineWidth: 2))

                Image(systemName: "camera.fill")
                    .font(.caption)
                    .padding(8)
                    .background(Circle().fill(CCDesign.accent))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tr("Bild auswählen"))
        .onChange(of: pickerItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }

    @ViewBuilder
    private var preview: some View {
        if let selectedImage {
            Image(uiImage: selectedImage).resizable().scaledToFill()
        } else if let currentImageURL, !currentImageURL.isEmpty, let url = URL(string: currentImageURL) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
        } else {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .overlay(Image(systemName: "person.fill").font(.largeTitle).foregroundColor(.gray))
        }
    }
}

#Preview {
    ImagePicker(selectedImage: .constant(nil))
}
