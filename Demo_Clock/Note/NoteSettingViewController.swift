//
//  TDClockSettingViewController.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import RichEditorView
import UIKit

class NoteSettingViewController: LXMBaseViewController, UITextViewDelegate {
    @IBOutlet var notetitle: UITextField!

    @IBOutlet var editorView: RichEditorView!

    @IBOutlet var done: UIButton!

    @IBOutlet  var cancel: UIButton!
    
    var htmlcontext = ""

    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = " Please input note..."
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

        // ----
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
        dismiss(animated: true) { () -> Void in
        }
    }
    
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
        note.id = DBManager.shareManager().fing_note_id(note: note)
        NoteManager.sharedInstance.noteArray.append(note)
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
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
}

extension NoteSettingViewController: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        htmlcontext = content
    }
    
}
