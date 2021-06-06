//
//  CreateFirstViewController.swift
//  inviti
//
//  Created by Hannah.C on 16.05.21.
//
//  swiftlint:disable comment_spacing onvenience_type trailing_closure

import UIKit
import JGProgressHUD
import FirebaseFirestore
import FirebaseFirestoreSwift


class CreateFirstViewController: BaseViewController {

    var meetingInfo: Meeting!

    var optionID: String = ""

    var meetingID: String?

    var isDataEmpty: Bool = false

    var meetingDataHandler: ((Meeting) -> Void)?

    var isSwitchOn: Bool = false

    var meetingSubject: String? {
        didSet {
            meetingSubject = createMeetingViewModel.meeting.subject
        }
    }

    var createMeetingViewModel = CreateMeetingViewModel()

    var selectOptionViewModel = SelectOptionViewModel()

    @IBOutlet weak var showButtonView: UIButton!

    @IBAction func deleteMeeting(_ sender: UIButton) {

        if isDataEmpty {

            self.createMeetingViewModel.onTap(withIndex: sender.tag)

            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let meetingVC = storyboard.instantiateViewController(identifier: "TabBarVC")
            guard let vc = meetingVC as? TabBarViewController else { return }
            self.navigationController?.pushViewController(vc, animated: true)

        } else {

            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var inviteBtnView: UIButton!

    @IBAction func invite(_ sender: Any) {

        if let name = UserDefaults.standard.value(forKey: UserDefaults.Keys.displayName.rawValue),
           let meetingSubject = createMeetingViewModel.meeting.subject {

        let message = "您的好友 \(name) 邀請您參加 \(String(describing: meetingSubject))，來 inviti 票選時間吧！打開 APP 輸入活動 ID 即可參與投票 👉🏻 \(meetingID!)"
               //Set the link to share.
//               if let link = NSURL(string: "http://yoururl.com") {
       let objectsToShare = [message]

        let ac = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        ac.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in

            if completed {

                INProgressHUD.showSuccess(text: "發送邀請成功")

            } else {
                
                INProgressHUD.showFailure(text: "請稍後再試")
            }
        }

        present(ac, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var successView: UIView!

    @IBAction func confrim(_ sender: Any) {

        if meetingInfo == nil {
            
        UIView.animate(withDuration: 5.0, animations: { () -> Void in

            self.successView.isHidden = false
            self.createMeetingViewModel.update(with: self.createMeetingViewModel.meeting)

        })} else {

        performSegue(withIdentifier: "showSuccessSegue", sender: self)

            createMeetingViewModel.update(with: meetingInfo)
        }
    }

    @IBAction func goCalendar(_ sender: Any) {
        nextPage()
    }


    override func viewWillAppear(_ animated: Bool) {

        createMeetingViewModel.fetchOneMeeitngData(meetingID: meetingID ?? "")

        selectOptionViewModel.fetchData(meetingID: meetingID ?? "" )

        if selectOptionViewModel.optionViewModels.value.isEmpty {

        } else {

            self.isDataEmpty = false

        }

        tableView.reloadData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        self.successView.isHidden = true

        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil

        selectOptionViewModel.optionViewModels.bind { [weak self] options in
            self?.selectOptionViewModel.onRefresh()
            self?.tableView.reloadData()
            self?.enableButton()
        }

        createMeetingViewModel.meetingViewModels.bind { [weak self] meetings in
            self?.createMeetingViewModel.onRefresh()
            self?.tableView.reloadData()
        }

        isDataGet()

        enableShareBtn()
        
        showButtonView.isEnabled = false

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareSegue" {
            let controller = segue.destination as! ShareSuccessVC

            controller.meetingID = meetingID
            controller.viewModel = createMeetingViewModel

        }
    }

    func enableButton() {

        if isDataEmpty {
           let cellOne = createMeetingViewModel.meeting.subject
           let cellTwo = createMeetingViewModel.meeting.location

           if cellOne != "" && cellTwo != "" && selectOptionViewModel.optionViewModels.value.isEmpty != true {

                enableShareBtn()
                self.showButtonView.isEnabled = true
                self.showButtonView.backgroundColor = UIColor(red: 1.00, green: 0.30, blue: 0.26, alpha: 1.00)

           } else {
                enableShareBtn()
                self.showButtonView.isEnabled = false
                self.showButtonView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)
           }
        } else {
            enableShareBtn()
            self.showButtonView.isEnabled = true
            self.showButtonView.backgroundColor = UIColor(red: 1.00, green: 0.30, blue: 0.26, alpha: 1.00)
        }
    }

    func enableShareBtn() {
        if meetingInfo != nil  || createMeetingViewModel.meeting.subject != nil {

            self.inviteBtnView.isEnabled = true
            self.inviteBtnView.tintColor = UIColor.darkGray

        } else {

            self.inviteBtnView.isEnabled = false
            self.inviteBtnView.tintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.00)

        }

    }

    func isDataGet() {

        let optionData = selectOptionViewModel.optionViewModels.value

        if optionData.isEmpty {

            isDataEmpty = true
            enableShareBtn()

        } else {

            selectOptionViewModel.fetchData(meetingID: meetingInfo.id)
            inviteBtnView.isHidden = false
        }

        if meetingInfo != nil {

            inviteBtnView.isHidden = false
            showButtonView.setTitle("更新活動內容", for: .normal)
            self.navigationController?.isNavigationBarHidden = true

            isDataEmpty = !isDataEmpty

        }
    }

//    func addParticipants() {
//
//        guard let currentUserID = UserDefaults.standard.value(forKey: "userID") as? String else { return }
//        guard let currentUserName = UserDefaults.standard.value(forKey: "userName") as? String else { return }
//        guard let currentUserImage = UserDefaults.standard.value(forKey: "userPhoto") as? String else { return }
//
//        self.meetingInfo.participantID.append(participantID)
//        self.meetingInfo.participantName.append(participantName)
//        self.meetingInfo.participantImage.append(participantImage)
//    }

    func nextPage() {

        let secondVC = storyboard?.instantiateViewController(identifier: "CMeetingVC")
           guard let second = secondVC as? CTableViewController else { return }

        createMeetingViewModel.update(with: createMeetingViewModel.meeting)

        second.selectedOptionViewModel = selectOptionViewModel

        second.meetingID = meetingID ?? ""

        navigationController?.pushViewController(second, animated: true)
    }
}

extension CreateFirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section  {
        case 0:
            return 1
        case 2:
          return 1

        default:
            if isDataEmpty {
                return 1
            } else {
                return selectOptionViewModel.optionViewModels.value.count
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        3
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateFirstTableViewCell", for: indexPath) as! CreateFirstCell

                cell.delegate = self

            if createMeetingViewModel.meetingViewModels.value.isEmpty {

                cell.setCell(model: createMeetingViewModel.meetingViewModel)

                cell.viewModel = self.createMeetingViewModel.meetingViewModel

            } else {

                let data = createMeetingViewModel.meetingViewModels.value[indexPath.row]

                cell.setCell(model: data)

                cell.viewModel = data

            }

            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionalSettingsCell", for: indexPath) as! OptionalSettingsCell

            if createMeetingViewModel.meetingViewModels.value.isEmpty {

                cell.setCell(model: createMeetingViewModel.meetingViewModel)

                cell.viewModel = self.createMeetingViewModel

                cell.addSubtract.value = Double(createMeetingViewModel.meetingViewModel.meeting.deadlineTag ?? 0)

                    cell.observation = cell.observe(\.addSubtract.value, options: [.old, .new], changeHandler: { (stepper, change) in
                        if change.newValue! == 0.0 {
                            if change.newValue! > change.oldValue! {
                                cell.addSubtract.value = 1
                            } else {
                                cell.addSubtract.value = -1
                            }
                        }
                        self.createMeetingViewModel.meetingViewModel.meeting.deadlineTag = Int(cell.addSubtract.value)
                    })
                return cell
                
            } else {

                let data = createMeetingViewModel.meetingViewModels.value[indexPath.row]

                cell.setCell(model: data)

                cell.viewModel = createMeetingViewModel
                cell.addSubtract.value = Double(data.meeting.deadlineTag ?? 0)
                    cell.observation = cell.observe(\.addSubtract.value, options: [.old, .new], changeHandler: { (stepper, change) in
                        if change.newValue! == 0.0 {
                            if change.newValue! > change.oldValue! {
                                cell.addSubtract.value = 1
                            } else {
                                cell.addSubtract.value = -1
                            }
                        }
                        self.createMeetingViewModel.meetingViewModels.value[indexPath.row].meeting.deadlineTag = Int(cell.addSubtract.value)
                    })
                return cell

            }

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsCell", for: indexPath) as! OptionsCell

            cell.deleteXview.tag = indexPath.row

            cell.delegate = self

            cell.selectedOptionViewModel = self.selectOptionViewModel

            cell.meetingInfo = self.meetingInfo

            if isDataEmpty {

                cell.setupEmptyDataCell()

            } else {

                cell.setupCell(model: selectOptionViewModel.optionViewModels.value[indexPath.row], index: indexPath.row)

                let cellViewModel = self.selectOptionViewModel.optionViewModels.value[indexPath.row]

                cellViewModel.onDead = { [weak self] () in
                    print("onDead")
                    self?.selectOptionViewModel.fetchData(meetingID: (self?.meetingInfo.id)!)
                }

            }

            return cell
        }
    }
}

extension CreateFirstViewController: CreateFirstCellDelegate {

    func getSubjectData(_ subject: String) {
        createMeetingViewModel.onSubjectChanged(text: subject)

    }

    func getLocationData(_ location: String) {
        createMeetingViewModel.onLocationChanged(text: location)
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

            INProgressHUD.showFailure(text: "投票選項至少兩個")

        } else {

            let theOptionID = newVMs[index].id

            selectOptionViewModel.onEmptyTap(theOptionID, meetingID: meetingID ?? "")

            selectOptionViewModel.fetchData(meetingID: meetingID ?? "")

        }
    }
}
