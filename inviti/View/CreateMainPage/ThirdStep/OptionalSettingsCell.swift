//
//  OptionalSettingsCell.swift.swift
//  inviti
//
//  Created by Hannah.C on 17.05.21.
//

import UIKit
import SwiftHEXColors
import Firebase
import FirebaseFirestoreSwift

protocol OptionalSettingsCellDelegate: AnyObject {
    func didTapController(controller: UIAlertController)
    func didTapImagePicker(imagePicker: UIImagePickerController)
    func dismissView()
}

class OptionalSettingsCell: UITableViewCell {
    
    weak var delegate: OptionalSettingsCellDelegate?
    
    var viewModel = CreateMeetingViewModel()
    
    var imagePicker = UIImagePickerController()
    
    var deadlineTag: Int = 0
    
    var placeholder = UILabel()
    
    var observation: NSKeyValueObservation?
    
    @IBOutlet weak var singleView: UISwitch!
    
    @IBOutlet weak var deadlineView: UISwitch!
    
    @IBOutlet weak var dealineFullView: UIView!
    
    @IBAction func singleToggle(_ sender: UISwitch) {
        if sender.isOn {
            
            viewModel.onMeetingSingleChanged(true)
        } else {
            
            viewModel.onMeetingSingleChanged(false)
        }
    }
    
    @IBOutlet weak var uploadSuccessView: UIView!
    
    @IBOutlet weak var uploadBtnView: UIButton!
    
    @IBAction func uploadImage(_ sender: Any) {
        
        showUploadMenu()
        
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var deadlineLabel: UILabel!
    
    @IBOutlet weak var addSubtract: UIStepper!
    
    @IBAction func deadlineToggle(_ sender: UISwitch) {
        
        if sender.isOn {
            
            UIView.animate(withDuration: 0.5) {
                
                self.dealineFullView.isHidden = false
                
                self.viewModel.onMeetingDeadlineChanged(sender.isOn)
            }
            
        } else {
            
            self.dealineFullView.isHidden = true
            
        }
        
        
    }
    
    @IBAction func stepperAction(_ sender: UIStepper) {
        
        let count = Int(sender.value)
        self.deadlineLabel.text = "voting-days".localized + "  \(count) " + "day".localized
        viewModel.onDeadlineTagChanged(count)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dealineFullView.isHidden = true
        
        textView.delegate = self
        
        imagePicker.delegate = self
        
        uploadSuccessView.isHidden = true
        
        setLayout()
        
        observation = addSubtract.observe(\.value, options: [.old, .new], changeHandler: { stepper, change in
            if change.newValue! == 0.0 {
                if change.newValue! > change.oldValue! {
                    stepper.value = 1
                } else {
                    stepper.value = -1
                }
            }
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(model: MeetingViewModel) {
        textView.text = model.meeting.notes
        singleView.isOn = model.meeting.singleMeeting
        deadlineView.isOn = model.meeting.deadlineMeeting
        deadlineTag = model.meeting.deadlineTag ?? 0
        
        if deadlineTag != 0 {
            dealineFullView.isHidden = false
            
            self.deadlineLabel.text = "voting-days".localized + " \(deadlineTag) " + "day".localized
        } else {
            dealineFullView.isHidden = true
        }
        
    }
    
    func setLayout() {
        
        placeholder.frame = CGRect(x: 6, y: 6, width: 250, height: 36)
        placeholder.text = ""
        placeholder.textColor = UIColor.lightGray
        placeholder.backgroundColor?.withAlphaComponent(0)
        placeholder.font = UIFont(name: "PingFang TC", size: 17)
        textView.addSubview(placeholder)
    }
    
}


extension OptionalSettingsCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let notes = textView.text else {
            return
        }
        
        if textView.text.isEmpty {
            
            placeholder.alpha = 1
            
        } else {
            
            placeholder.alpha = 0
            placeholder.text = ""
            viewModel.onNotesChanged(text: notes)
            
        }
        
    }
}

extension OptionalSettingsCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
            
            viewModel.uploadImage(with: pickedImage)
        }
        
        if selectedImageFromPicker != nil {
            
            uploadSuccessView.isHidden = false
        }
        
        delegate?.dismissView()
    }
    
    func showUploadMenu() {
        let controller = UIAlertController(title: "Upload an image", message: nil, preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Pick from Album", style: .default) { _ in
            
            self.openAlbum()
        }
        
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel)
        
        controller.addAction(libraryAction)
        controller.addAction(cancleAction)
        
        delegate?.didTapController(controller: controller)
        
    }
    
    func openAlbum() {
        
        imagePicker.sourceType = .savedPhotosAlbum
        delegate?.didTapImagePicker(imagePicker: imagePicker)
    }
}
