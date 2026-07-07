import SwiftUI
import UIKit

final class PhotoService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = PhotoService()

    private weak var presentationController: UIViewController?
    var onImagePicked: ((Data) -> Void)?

    func presentPicker(from controller: UIViewController, allowsEditing: Bool = true, sourceType: UIImagePickerController.SourceType? = nil) {
        self.presentationController = controller
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = allowsEditing

        if let sourceType = sourceType, UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        controller.present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        let data = image?.jpegData(compressionQuality: 0.8)
        picker.dismiss(animated: true) {
            if let data = data {
                self.onImagePicked?(data)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var allowsEditing: Bool = true
    var onImagePicked: (Data) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = allowsEditing
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onImagePicked: (Data) -> Void

        init(onImagePicked: @escaping (Data) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            let data = image?.jpegData(compressionQuality: 0.8)
            picker.dismiss(animated: true) {
                if let data = data {
                    self.onImagePicked(data)
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
