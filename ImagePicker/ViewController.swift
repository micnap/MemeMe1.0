//
//  ViewController.swift
//  ImagePicker
//
//  Created by Michelle Williamson on 11/20/22.
//

import UIKit

// Meme structure.
struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextfield: UITextField!
    @IBOutlet weak var bottomTextfield: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navbarCamera: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // Textfield attributes.
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -2.0,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Only enable camera button in toolbar if camera is available on device.
        navbarCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        setupTextfield(textfield: topTextfield)
        setupTextfield(textfield: bottomTextfield)
        
        shareButton.isEnabled = false
        
        #if targetEnvironment(simulator)
            navbarCamera.isEnabled = false
        #else
            navbarCamera.isEnabled = true
        #endif
    }
    
    // Utility function for styling textfields.
    func setupTextfield(textfield: UITextField) {
        // Enable use of textfield delegate methods.
        textfield.delegate = self
        
        // Style text in textfields.
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe to notifications for when keyboard is shown/hidden.
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from notifications for when keyboard is shown/hidden.
        unsubscribeFromKeyboardNotifications()
    }
    
    // Presenting Activity VC for sharing meme.
    @IBAction func shareMeme(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        
        present(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
                if (success && error == nil){
                    self.dismiss(animated: true, completion: nil);
                } else if (error != nil){
                    print("Something went horribly wrong!")
                }
            };
    }
    
    // Take an image with the camera for the meme.
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    // Pick an image from the device photo library for the meme.
    @IBAction func pickAnImageFromLibrary(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    // Utility function for choosing an image.
    func pickImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Callback for when the image has been chosen or modal has been cancelled.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Display the chosen image and enable the Share button.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
        }
    }
    
    // Clear default text in textfields.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    // Dismiss keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Subscribe to keyboard show/hide notifications.
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe from keyboard show/hide notifications.
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Set bottom of view to make room for keyboard.
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextfield.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Return bottom of view to bottom of screen when keyboard is hidden.
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    // Calculate the height of the keyboard to determine how much the view frame Y axis needs to move.
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Save the meme.
    func saveMeme() {
        // Create the meme
        Meme(topText: topTextfield.text!, bottomText: bottomTextfield.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }
    
    // Generate the meme to be saved.
    func generateMemedImage() -> UIImage {
        
        // Hide items that shouldn't be in the saved image.
        toolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Restore hidden items to view.
        toolbar.isHidden = false

        return memedImage
    }
}




