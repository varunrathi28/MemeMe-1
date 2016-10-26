//
//  ViewController.swift
//  MemeMe
//
//  Created by Varun Rathi on 24/10/16.
//  Copyright © 2016 vrat28. All rights reserved.
//

import UIKit
struct Meme {
    var headerText:String?
    var footerText:String?
    var originalImage:UIImage!
    var memedImage:UIImage!

}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
        
        self.navigationItem.rightBarButtonItem=rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName :UIColor.black,  //TODO: Fill in appropriate UIColor,
            NSForegroundColorAttributeName :UIColor.white , //TODO: Fill in UIColor,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName :5.0 //TODO: Fill in appropriate Float
        ] as [String : Any]
        
        tfTop.defaultTextAttributes = memeTextAttributes

        tfTop.backgroundColor=UIColor.clear
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK :- IBActions
    
    @IBAction func pickImage(sender:AnyObject)
    {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType=UIImagePickerControllerSourceType.photoLibrary
        pickerController.allowsEditing=true
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func clickCamera(sender:AnyObject)
    {
        
        let camera=UIImagePickerController()
        camera.delegate=self
        camera.sourceType=UIImagePickerControllerSourceType.camera
        camera.allowsEditing=true
        self.present(camera, animated: true, completion: nil)
    }
    
    // MARK:- ImagePicker Delegate methods
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image=info[UIImagePickerControllerEditedImage] as? UIImage
        {
            imgView.image=image;
            
        }
        picker .dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK : Custom methods for saving images
    
    func saveImage()
    {
        let memedCreatedImg:UIImage = createMemedImage()
        
        _ = Meme(headerText: tfTop.text, footerText: tfBottom.text, originalImage: imgView.image, memedImage: memedCreatedImg)
    }
    
    func createMemedImage()->UIImage
    {
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
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
        self.view.frame.origin.y = -keyBoardFrameHeight // Subtract keyboard height
        }
    }
    
    func keyBoardWillHide(notification:NSNotification)
    {
        if tfBottom.isFirstResponder
        {
            self.view.frame.origin.y = 0 //set the frame back to original position
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
        
        textField.textColor=UIColor.white
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func showActivityView()
    {
        
        saveImage()
        var arrayTitles = [String]()
        arrayTitles.append("Share")
        let activityViewController=UIActivityViewController(activityItems: arrayTitles, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView=self.view
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
}


