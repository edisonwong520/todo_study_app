//
//  TDClockSettingViewController.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import RichEditorView
import UIKit
var pic_path = ""
class NoteSettingViewController: LXMBaseViewController, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var notetitle: UITextField!

    @IBOutlet var editorView: RichEditorView!

    @IBOutlet var done: UIButton!

    @IBOutlet  var cancel: UIButton!
    
    var htmlcontext = ""

    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 42))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = " 请输入内容..."
            textView.textColor = UIColor.lightGray
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        editorView.delegate = self as? RichEditorDelegate
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."

        toolbar.delegate = self
        toolbar.editor = editorView

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }

        var options = toolbar.options
        options.append(item)
        toolbar.options = options
        setupDefault()
        
        // ----
    }
    //present the old data
    func setupDefault() {
        
        if add_item_flag == false {
            notetitle.text = notes_list[current_selected_row].title
//            todoNote.text = notes_list[current_selected_row].note
            editorView.html = notes_list[current_selected_row].context
            add_item_flag = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class func loadFromStroyboardWithTargetAlarm(_: NoteItem?) -> NoteSettingViewController {
        let viewController = NoteSettingViewController.swift_loadFromStoryboard("Main")

        return viewController
    }

    @IBAction func handleCancelButtonTapped(_: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
//        dismiss(animated: true) { () -> Void in
//        }
    }
    
    //add note item
    @IBAction func handleConfirmButtonTapped(_: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // add note item------------------------
        let note = NoteItem()
        note.title = notetitle.text!
        note.createDate = Date()
        note.context = htmlcontext
        
        //add item
        DBManager.shareManager().insert(noteitem: note)
        note.id = DBManager.shareManager().find_note_id(note: note)
//        NoteManager.sharedInstance.noteArray.append(note)
        notes_list.append(note)
        filter_list = notes_list
        handleCancelButtonTapped(UIButton())
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
}

extension NoteSettingViewController: RichEditorToolbarDelegate {
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
        ]

        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        tapAction()
        toolbar.editor?.insertImage(pic_path, alt: "Pic")
//        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("", title: "Link")
        }
    }
}

extension NoteSettingViewController: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        htmlcontext = content
    }
    
    func tapAction() {
        let alertController = UIAlertController(title: "更改头像", message: nil,
                                                preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let photoAction = UIAlertAction(title: "相册选取", style: .default) { _ in
            self.getPhoto()
        }
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { _ in
            self.takePic()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func getPhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("相册不可用")
            return
        }
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(picker, animated: true, completion: nil)
    }
    
    func takePic() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            NSLog("相册不可用")
            return
        }
        
        let takePic = UIImagePickerController()
        takePic.allowsEditing = true
        takePic.sourceType = .camera
        takePic.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(takePic, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
//        imgView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        imgView.contentMode = .scaleAspectFill
//        imgView.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            if let imgUrl = info[UIImagePickerControllerImageURL] as? URL{
                let imgName = imgUrl.lastPathComponent
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let localPath = documentDirectory?.appending(imgName)
                
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                let data = UIImagePNGRepresentation(image)! as NSData
                data.write(toFile: localPath!, atomically: true)
                //let imageData = NSData(contentsOfFile: localPath!)!
                let photoURL = URL.init(fileURLWithPath: localPath!)
//                print(photoURL)
                //NSURL(fileURLWithPath: localPath!)
                NSLog("localpath:"+localPath!)
                pic_path = "file://" + localPath!
                
            }
        } else {
            // Fallback on earlier versions
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}
