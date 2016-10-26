//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Varun Rathi on 24/10/16.
//  Copyright © 2016 vrat28. All rights reserved.
//

import UIKit


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var barBtnAlbum:UIBarButtonItem!
    @IBOutlet weak var barBtnCamera:UIBarButtonItem!
    @IBOutlet weak var tfTop:UITextField!
    @IBOutlet weak var tfBottom:UITextField!
    var selectedImage:UIImage?
    
    // MARK : - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftBarButton:UIBarButtonItem=UIBarButtonItem.init(barButtonSystemItem: .action, target: self, action: #selector(showActivityView))
        
         let rightBarButton:UIBarButtonItem=UIBarButtonItem.init(title: "Cancel", style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItem=rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName :UIColor.black,  //TODO: Fill in appropriate UIColor,
            NSForegroundColorAttributeName :UIColor.white , //TODO: Fill in UIColor,
            NSFontAttributeName : UIFont(name: "impact", size: 42)!,
            NSStrokeWidthAttributeName :-5.0 //TODO: Fill in appropriate Float
        ] as [String : Any]
        
        tfTop.defaultTextAttributes = memeTextAttributes
        tfBottom.defaultTextAttributes = memeTextAttributes
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfCameraIsAvailable()              // to enable/disable camera button
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterKeyboardNotifications()
    }
    
    func checkIfCameraIsAvailable()
    {
        barBtnCamera.isEnabled=UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }

    // MARK :- IBActions
    
    
    @IBAction func pickImage(sender:AnyObject)
    {
       openImagePickerController(source: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func clickCamera(sender:AnyObject)
    {
         openImagePickerController(source: UIImagePickerControllerSourceType.camera)
    }
    
    func openImagePickerController(source:UIImagePickerControllerSourceType)
    {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType=source
        pickerController.allowsEditing=true
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK:- ImagePicker Delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image=info[UIImagePickerControllerEditedImage] as? UIImage
        {
            imgView.image=image
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK : Custom methods for saving images
    
    func saveImage()
    {
        
        let memedCreatedImg:UIImage = createMemedImage()
        var aMeme = Meme(headerText: tfTop.text, footerText: tfBottom.text, originalImage: imgView.image, memedImage: memedCreatedImg)
    }
    
    func createMemedImage()->UIImage
    {
        navigationController?.isNavigationBarHidden = true // hide the nav bar
        navigationController?.isToolbarHidden = true   // to hide toolbar so that it isnt shown in saved image
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navigationController?.isToolbarHidden = false // retrieve back the toolbar
        navigationController?.isNavigationBarHidden = true // show back nav bar
        return memedImage
        
    }
    

    // MARK :- Notifications for keyboard
    
    func registerKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unRegisterKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyBoardWillShow(notification:NSNotification)
    {
        
        if tfBottom.isFirstResponder // Frame should be shifted for only bottom text field
        {
        let keyBoardFrameHeight:CGFloat = getKeyBoardHeight(notification: notification)
        view.frame.origin.y = -keyBoardFrameHeight // Subtract keyboard height
        }
    }
    
    func keyBoardWillHide(notification:NSNotification)
    {
        if tfBottom.isFirstResponder
        {
            view.frame.origin.y = 0 //set the frame back to original position
        }
    }
    
    func getKeyBoardHeight(notification:NSNotification)->CGFloat
    {
        let userInfoDic = notification.userInfo
        let size=userInfoDic![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return size.cgRectValue.height
    }
    
    // MARK:- TEXT Field delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    func showActivityView()
    {
        let memedImage:UIImage = createMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView=view
        present(activityViewController, animated: true) {
            
            self.saveImage()
        }
    }
}


