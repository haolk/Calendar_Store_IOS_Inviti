//
//  CreateFirstViewController.swift
//  inviti
//
//  Created by Hannah.C on 16.05.21.
//

import UIKit
import JGProgressHUD
import FirebaseFirestore
import FirebaseFirestoreSwift
import IQKeyboardManagerSwift

class CreateFirstViewController: UIViewController {
    
    var meetingInfo: Meeting!
    var optionID: String = ""
    var meetingID: String?
    var isDataEmpty: Bool = false
    var isSwitchOn: Bool = false
    var meetingDataHandler: ((Meeting) -> Void)?
    var createMeetingViewModel = CreateMeetingViewModel()
    var selectOptionViewModel = SelectOptionViewModel()
    var meetingSubject: String? {

        didSet {

            meetingSubject = createMeetingViewModel.meeting.subject
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inviteBtnView: UIButton!
    @IBOutlet weak var confrimButtonView: UIView!
    @IBOutlet weak var calendarIconView: UIButton!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var showButtonView: UIButton!
    @IBAction func deleteMeeting(_ sender: UIButton) {
        
        if isDataEmpty {

           self.present(

            .confirmationAlert(title: "b01".localized,
                               message: "b02".localized,
                               cancelHandler: {

                                    self.returnToMain() },

                               confirmHandler: {

                                    self.createMeetingViewModel.onTap(withIndex: sender.tag)
                                    self.returnToMain()}),
            animated: true,
            completion: nil)

       } else {

           self.navigationController?.popViewController(animated: true)
       }
    }

    @IBAction func confrim(_ sender: Any) {
        
        // if true 代表是新增一個空的 meeting
        if meetingInfo == nil {
            
            UIView.animate(withDuration: 5.0, animations: { () -> Void in
                
                self.successView.isHidden = false
                self.createMeetingViewModel.updateDetails(meetingID: self.meetingID ?? "")
                
            })} else {
                
                createMeetingViewModel.updateDetails(meetingID: meetingID ?? "")
                performSegue(withIdentifier: "editSuccessSegue", sender: self)
                
            }
    }

    @IBAction func invitePeopleButton(_ sender: Any) {
        performSegue(withIdentifier: "addPeopleSegue", sender: nil)
    }
    
    @IBAction func goCalendar(_ sender: Any) {
        nextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        createMeetingViewModel.fetchOneMeeitngData(meetingID: meetingID ?? "")

        selectOptionViewModel.fetchData(meetingID: meetingID ?? "" )
        
        if !selectOptionViewModel.optionViewModels.value.isEmpty {
            self.isDataEmpty = false
        }

        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil

        successView.isHidden = true
        showButtonView.isEnabled = false

        selectOptionViewModel.optionViewModels.bind { [weak self] options in
            self?.tableView.reloadData()
            self?.enableButton()
        }
        
        createMeetingViewModel.meetingViewModels.bind { [weak self] meetings in
            self?.tableView.reloadData()
        }
        
        isDataGet()
        
        enableShareBtn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "shareSegue" {
            
            let controller = segue.destination as? ShareSuccessVC
            
            controller?.meetingID = meetingID
            
            controller?.viewModel = createMeetingViewModel
            
        } else if segue.identifier == "addPeopleSegue" {
            
            let controller = segue.destination as? AddPeopleViewController
            
            controller?.meetingID = meetingID
            
        } else if segue.identifier == "editSuccessSegue" {
            
            let controller = segue.destination as? EditSuccessVC
            
            controller?.delegate = self
            
        }
    }
    
    func enableButton() {
        
        if isDataEmpty {
            if let cellOne = createMeetingViewModel.meeting.subject,
               let cellTwo = createMeetingViewModel.meeting.location {
                
                if !cellOne.isEmpty && !cellTwo.isEmpty && selectOptionViewModel.optionViewModels.value.isEmpty != true {

                    displayButton(isEnabled: true, color: UIColor(red: 1.00, green: 0.30, blue: 0.26, alpha: 1.00))
                    
                } else {

                    displayButton(isEnabled: false, color: UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.00))
                }
            }
        } else {

            displayButton(isEnabled: true, color: UIColor(red: 1.00, green: 0.30, blue: 0.26, alpha: 1.00))
        }
    }

    func displayButton(isEnabled: Bool, color: UIColor) {
        self.enableShareBtn()
        self.showButtonView.isEnabled = isEnabled
        self.showButtonView.backgroundColor = color
    }

    func returnToMain() {

         let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let meetingVC = storyboard.instantiateViewController(identifier: "TabBarVC")
         guard let vc = meetingVC as? TabBarViewController else { return }

         self.navigationController?.pushViewController(vc, animated: true)
    }

    func enableShareBtn() {
        if meetingInfo != nil || createMeetingViewModel.meeting.subject != nil {
            
            self.inviteBtnView.isEnabled = true
            self.inviteBtnView.tintColor = UIColor.systemGray

        } else {
            
            self.inviteBtnView.isEnabled = false
            self.inviteBtnView.tintColor = UIColor.gray
        }
    }

    // option date
    func isDataGet() {
        
        let optionData = selectOptionViewModel.optionViewModels.value
        
        if optionData.isEmpty {
            
            isDataEmpty = true
            enableShareBtn()

        } else {
            
            isDataEmpty = false
            selectOptionViewModel.fetchData(meetingID: meetingInfo.id)
            inviteBtnView.isHidden = false
        }
        
        if meetingInfo != nil {
            
            inviteBtnView.isHidden = false
            showButtonView.setTitle("b03".localized, for: .normal)
            self.navigationController?.isNavigationBarHidden = true
            
            isDataEmpty = !isDataEmpty
        }
    }
    
    func nextPage() {
        
        let secondVC = storyboard?.instantiateViewController(identifier: "CMeetingVC")
        guard let second = secondVC as? CTableViewController else { return }
        
        if meetingInfo != nil {
            
            second.meetingID = meetingID ?? ""
            second.selectedOptionViewModel = selectOptionViewModel
        }
        
        createMeetingViewModel.updateDetails(meetingID: meetingID ?? "")
        second.selectedOptionViewModel = selectOptionViewModel
        second.meetingID = meetingID ?? ""
        
        navigationController?.pushViewController(second, animated: true)
    }
}

extension CreateFirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
            
        case 2:
            return 1
            
        default:
            if selectOptionViewModel.optionViewModels.value.isEmpty {
                return 1
            } else {
                return selectOptionViewModel.optionViewModels.value.count
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateFirstTableViewCell", for: indexPath)

            guard let createCell = cell as? CreateFirstCell else { return cell }
            
            if createMeetingViewModel.meetingViewModels.value.isEmpty {
                createCell.createViewModel = createMeetingViewModel
                
            } else {
                
                let model = createMeetingViewModel.meetingViewModels.value[indexPath.row]
                createCell.viewModel = model
                createCell.createViewModel = createMeetingViewModel
                createCell.setup(viewModel: model)
                
            }
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionalSettingsCell", for: indexPath)

            guard let optionCell = cell as? OptionalSettingsCell else { return cell }
            
            optionCell.delegate = self
            
            if createMeetingViewModel.meetingViewModels.value.isEmpty {
                
                optionCell.viewModel = self.createMeetingViewModel
                optionCell.addSubtract.value = Double(createMeetingViewModel.meeting.deadlineTag ?? 0)
                optionCell.observation = optionCell.observe(\.addSubtract.value, options: [.old, .new], changeHandler: { stepper, change in
                    if change.newValue! == 0.0 {
                        if change.newValue! > change.oldValue! {
                            optionCell.addSubtract.value = 1
                        } else {
                            optionCell.addSubtract.value = -1
                        }
                    }
                    self.createMeetingViewModel.meeting.deadlineTag = Int(optionCell.addSubtract.value)
                })

                return optionCell
                
            } else {
                
                let data = createMeetingViewModel.meetingViewModels.value[indexPath.row]
                
                optionCell.setCell(model: data)
                optionCell.viewModel = createMeetingViewModel
                optionCell.addSubtract.value = Double(data.meeting.deadlineTag ?? 0)
                optionCell.observation = optionCell.observe(\.addSubtract.value, options: [.old, .new], changeHandler: { stepper, change in
                    if change.newValue! == 0.0 {
                        if change.newValue! > change.oldValue! {
                            optionCell.addSubtract.value = 1
                        } else {
                            optionCell.addSubtract.value = -1
                        }
                    }
                    self.createMeetingViewModel.meetingViewModels.value[indexPath.row].meeting.deadlineTag = Int(optionCell.addSubtract.value)
                })
                return optionCell
                
            }
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsCell", for: indexPath)

            guard let optionCell = cell as? OptionsCell else { return cell }
            
            optionCell.deleteXview.tag = indexPath.row
            optionCell.delegate = self
            optionCell.selectedOptionViewModel = self.selectOptionViewModel
            optionCell.meetingInfo = self.meetingInfo
            
            if selectOptionViewModel.optionViewModels.value.isEmpty {
                optionCell.setupEmptyDataCell()
                
            } else {
                
                optionCell.setupCell(model: selectOptionViewModel.optionViewModels.value[indexPath.row], index: indexPath.row)
                
                let cellViewModel = self.selectOptionViewModel.optionViewModels.value[indexPath.row]
                
                cellViewModel.onDead = { [weak self] () in
                    print("onDead")
                    self?.selectOptionViewModel.fetchData(meetingID: (self?.meetingInfo.id)!)
                }
            }
            
            return optionCell
        }
    }
}

extension CreateFirstViewController: CTableViewDelegate {
    func optionDidSelect(getData: Bool) {
        if getData {
            isDataEmpty = false
        }
    }
}

extension CreateFirstViewController: SecondCellDelegate {

    func goToSecondPage() {

        nextPage()
    }
    
    func deleteTap(_ index: Int, vms: SelectOptionViewModel) {
        
        let newVMs = selectOptionViewModel.optionViewModels.value
        
        if newVMs.count < 3 {
            
            INProgressHUD.showFailure(text: "b04".localized)
            
        } else {
            
            let theOptionID = newVMs[index].id
            
            selectOptionViewModel.onEmptyTap(theOptionID, meetingID: meetingID ?? "")
            selectOptionViewModel.fetchData(meetingID: meetingID ?? "")
        }
    }
}

extension CreateFirstViewController: EditSuccessVCDelegate {

    func didTapReturnButton() {
        
        dismiss(animated: false, completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension CreateFirstViewController: OptionalSettingsCellDelegate {

    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    func didTapController(controller: UIAlertController) {
        present(controller, animated: true)
    }
    
    func didTapImagePicker(imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true)
    }
}
