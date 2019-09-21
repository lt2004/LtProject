//
//  ProPushSecViewController.swift
//  vs
//
//  Created by 邵帅 on 2016/12/17.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

import UIKit
import IQKeyboardManager
import MZTimerLabel
import KVNProgress
import SCSiriWaveformView

class ProPushSecViewController: XTCBaseViewController, UIGestureRecognizerDelegate, UITextViewDelegate, PlayerManagerStopDelegate {
    
    @IBOutlet weak var firstTextView: UITextView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondTextView: UITextView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdTextView: UITextView!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var vrTextView: UITextView!
    @IBOutlet weak var vrLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var vrButton: UIButton!
    @IBOutlet weak var waveformView: SCSiriWaveformView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressTimeLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    var interactivePostId:String = String() // 互动圈帖子id
    var but = UIButton()
    @objc var isRoadBook:Bool = false;
    @objc var proDetailModel:PublishNormalPostModel = PublishNormalPostModel()
    let recordClient = JZMp3RecordingClient.shared()
    var timer: MZTimerLabel? = nil
    var playingTimer: Timer? = nil
    var playedSeconds: Int = 0
    let maxRecordSeconds = 600
    var isLoading:Bool = false;
    @objc var proPublishNumber:String = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        buildSiriWave()
        buildInterface()
        
        firstButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        secondButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        thirdButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        NotificationCenter.default.addObserver(self, selector: #selector(ProPushSecViewController.publishPostSuccessClick), name: NSNotification.Name(rawValue: "PublishPostSuccess"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ProPushSecViewController.publishPostFailedClick), name: NSNotification.Name(rawValue: "PublishPostFailed"), object: nil);
        
    }
    
    @objc func publishPostSuccessClick() -> Void {
        self.dismiss(animated: true) {
            self.navigationController?.popViewController(animated: true);
        };
    }
    
    @objc func publishPostFailedClick() -> Void {
        self.hideHub()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        IQKeyboardManager.shared().isEnabled = true
        buildBarItems();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().isEnabled = false
        
        if recordButton.isSelected {
            recordAction(nil)
            ProData.sharedInstance().recorder.stop()
        }
        if playButton.isSelected {
            listenAction(nil)
        }
    }

    
    func buildInterface() {
        
        let page = self.proDetailModel.proPage;
        // 最多发送3页
        if page == 3 {
            nextButton.isHidden = true
        }
        let str = "pro_\(page+1)"
        let titleView = UIImageView(image: UIImage(named: str))
        self.navigationItem.titleView = titleView
    }
    
    
    func buildBarItems() {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = true;
        //back button
        let backButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage(named: "pro_exit"), for: UIControl.State())
        backButton.sizeToFit()
        backButton.backgroundColor = UIColor.white
        backButton.addTarget(self, action: #selector(ProPushSecViewController.closeAction), for: UIControl.Event.touchUpInside)
        
        let pushButton = UIButton(type: UIButton.ButtonType.custom)
        pushButton.setImage(UIImage(named: "pro_push"), for: UIControl.State())
        pushButton.sizeToFit()
        pushButton.addTarget(self, action: #selector(ProPushSecViewController.pushAction), for: UIControl.Event.touchUpInside)
        
        
        let backBarItem = UIBarButtonItem(customView: backButton)
        let pushBarItem = UIBarButtonItem(customView: pushButton)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spacer.width = -10; // for example shift right bar button to the right
        
        self.navigationItem.leftBarButtonItems = [spacer ,backBarItem]
        self.navigationItem.rightBarButtonItems = [spacer ,pushBarItem]
    }
    
    @objc func closeAction() {
        if (recordClient?.isRecoding == true) {
            KVNProgress.showError(withStatus: "录音中不能进行此操作") {
                
            }
            return;
        } else {
            
        }
        let alert = UIAlertController(title: "确定要退出编辑吗?", message: "", preferredStyle: UIAlertController.Style.alert)
        let yes = UIAlertAction(title: "确定", style: UIAlertAction.Style.destructive) { (action:UIAlertAction) -> Void in
        
            APIClient.shared().operationQueue.cancelAllOperations()
            if (self.proDetailModel.proPage == 1) {
                self.proDetailModel.proFirstDetailModel.vrImage = nil;
                self.proDetailModel.proFirstDetailModel.firstImage = nil;
                self.proDetailModel.proFirstDetailModel.secondImage = nil;
                self.proDetailModel.proFirstDetailModel.thirdImage = nil;
                self.proDetailModel.proFirstDetailModel.voiceFlag = 0;
            } else if (self.proDetailModel.proPage == 2) {
                self.proDetailModel.proSecondDetailModel.vrImage = nil;
                self.proDetailModel.proSecondDetailModel.firstImage = nil;
                self.proDetailModel.proSecondDetailModel.secondImage = nil;
                self.proDetailModel.proSecondDetailModel.thirdImage = nil;
                self.proDetailModel.proSecondDetailModel.voiceFlag = 0;
            } else {
                self.proDetailModel.proThirdDetailModel.vrImage = nil;
                self.proDetailModel.proThirdDetailModel.firstImage = nil;
                self.proDetailModel.proThirdDetailModel.secondImage = nil;
                self.proDetailModel.proThirdDetailModel.thirdImage = nil;
                self.proDetailModel.proThirdDetailModel.voiceFlag = 0;
            }
            self.navigationController?.popViewController(animated: true);
        }
        
        let cancel = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel) { (action:UIAlertAction) -> Void in
            //
        }
        alert.addAction(yes)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK:选择vr照片
    @IBAction func vrSelectAction(_ sender: UIButton) {
        selectPhoto(sender)
    }
    
    @IBAction func firstPhotoAction(_ sender: UIButton) {
        selectPhoto(sender)
    }
    
    @IBAction func secondPhotoAction(_ sender: UIButton) {
        selectPhoto(sender)
    }
    
    @IBAction func thirdPhotoAction(_ sender: UIButton) {
        selectPhoto(sender)
    }
    
    func selectPhoto(_ button:UIButton) {
        but = button
        let storyBoard = UIStoryboard.init(name: "XTCPublishPicker", bundle: nil);
        let publishPickerVC:XTCPublishPickerViewController = storyBoard.instantiateViewController(withIdentifier: "XTCPublishPickerViewController") as! XTCPublishPickerViewController;
        publishPickerVC.isPublishSelect = false;
        publishPickerVC.isProSingleSelect = true;
        if (but.tag == 101) {
            publishPickerVC.selectPublishTypeEnum = SelectPublishTypeEnum.type720VREnum;
        } else {
            publishPickerVC.selectPublishTypeEnum = SelectPublishTypeEnum.typePhotoEnum;
        }
        publishPickerVC.selectPublishSourceCallBack = { (assetArray:NSMutableArray?, photoArray:NSMutableArray?, selectType:SelectPublishTypeEnum?) -> () in
            if ((assetArray != nil) && (photoArray != nil)) {
                let asset:PHAsset = assetArray?.firstObject as! PHAsset;
                if self.but == self.vrButton {
                    if asset.pixelWidth/asset.pixelHeight != 2 {
                        self.alertMessage("您选择的不是VR照片");
                        return
                    }
                    if (self.proDetailModel.proPage == 1) {
                        self.proDetailModel.proFirstDetailModel.vrFlag = 1
                        self.proDetailModel.proFirstDetailModel.vrImage = asset
                    }
                    if (self.proDetailModel.proPage == 2) {
                        self.proDetailModel.proSecondDetailModel.vrFlag = 1
                        self.proDetailModel.proSecondDetailModel.vrImage = asset
                    }
                    if (self.proDetailModel.proPage == 3) {
                        self.proDetailModel.proThirdDetailModel.vrFlag = 1
                        self.proDetailModel.proThirdDetailModel.vrImage = asset
                    }
                }
                
                if self.but == self.firstButton {
                    if (self.proDetailModel.proPage == 1) {
                        self.proDetailModel.proFirstDetailModel.firstFlag = 1
                        self.proDetailModel.proFirstDetailModel.firstImage = asset
                    }
                    if (self.proDetailModel.proPage == 2) {
                        self.proDetailModel.proSecondDetailModel.firstFlag = 1
                        self.proDetailModel.proSecondDetailModel.firstImage = asset
                    }
                    if (self.proDetailModel.proPage == 3) {
                        self.proDetailModel.proThirdDetailModel.firstFlag = 1
                        self.proDetailModel.proThirdDetailModel.firstImage = asset
                    }
                    
                }
                
                if self.but == self.secondButton {
                    if (self.proDetailModel.proPage == 1) {
                        self.proDetailModel.proFirstDetailModel.secondFlag = 1
                        self.proDetailModel.proFirstDetailModel.secondImage = asset
                    }
                    if (self.proDetailModel.proPage == 2) {
                        self.proDetailModel.proSecondDetailModel.secondFlag = 1
                        self.proDetailModel.proSecondDetailModel.secondImage = asset
                    }
                    if (self.proDetailModel.proPage == 3) {
                        self.proDetailModel.proThirdDetailModel.secondFlag = 1
                        self.proDetailModel.proThirdDetailModel.secondImage = asset
                    }
                }
                
                if self.but == self.thirdButton {
                    if (self.proDetailModel.proPage == 1) {
                        self.proDetailModel.proFirstDetailModel.thirdFlag = 1
                        self.proDetailModel.proFirstDetailModel.thirdImage = asset
                    }
                    if (self.proDetailModel.proPage == 2) {
                        self.proDetailModel.proSecondDetailModel.thirdFlag = 1
                        self.proDetailModel.proSecondDetailModel.thirdImage = asset
                    }
                    if (self.proDetailModel.proPage == 3) {
                        self.proDetailModel.proThirdDetailModel.thirdFlag = 1
                        self.proDetailModel.proThirdDetailModel.thirdImage = asset
                    }
                }
                
                let photo:UIImage = photoArray?.firstObject as! UIImage;
                self.but.setImage(photo, for: UIControl.State())
            } else {
                
            }
        };
        self.present(publishPickerVC, animated: true, completion: nil);
        
    }
    
    
    // MARK: - Recorder
    @IBAction func recordAction(_ sender: UIButton?) {
        XTCPermissionManager.checkAudioPermissioncallBack { (isPermission:Bool) in
            if (isPermission) {
                self.playButton.isEnabled = true
                if self.playButton.isSelected {
                    PlayerManager.sharedInstance().player.pause()
                    self.playButton.isSelected = false
                }
                
                if self.recordButton.isSelected {
                    self.resetTimer()
                    self.timer?.pause()
                    self.recordClient?.stop()
                    self.recordButton.isSelected = false
                    ProData.sharedInstance().recorder.stop()
                    self.recordLabel.text = "点击重录"
                    if (self.proDetailModel.proPage == 1) {
                        self.proDetailModel.proFirstDetailModel.voiceFlag = 1;
                        self.proDetailModel.proFirstDetailModel.voiceFile = self.recordingMp3FilePath()
                    }
                    if (self.proDetailModel.proPage == 2) {
                        self.proDetailModel.proSecondDetailModel.voiceFlag = 2;
                        self.proDetailModel.proSecondDetailModel.voiceFile = self.recordingMp3FilePath()
                    }
                    if (self.proDetailModel.proPage == 3) {
                        self.proDetailModel.proThirdDetailModel.voiceFlag = 3;
                        self.proDetailModel.proThirdDetailModel.voiceFile = self.recordingMp3FilePath()
                    }
                    
                } else {
                    self.recordLabel.text = "点击完成"
                    self.startTimer()
                    if self.timer == nil {
                        self.timer = MZTimerLabel(label: self.progressTimeLabel)
                        self.timer!.timeFormat = "mm:ss.SS"
                    }
                    self.timer?.reset()
                    self.timer?.start()
                    
                    let target = self.recordingMp3FilePath()
                    do {
                        try FileManager.default.removeItem(atPath: target!)
                    } catch( _ ) {}
                    
                    self.recordClient?.currentMp3File = target
                    self.recordClient?.start(target)
                    self.recordButton.isSelected = true
                    ProData.sharedInstance().recorder.record()
                }
            } else {
                
            }
        }
    }
    
    @objc func tick() {
        playedSeconds += 1
        let minutesLeft = playedSeconds / 60
        let secondsLeft = playedSeconds % 60
        let left = NSString(format: "%02i:%02i", minutesLeft, secondsLeft)
        timerLabel.text = left as String
        
        if recordButton.isSelected {
            if playedSeconds >= maxRecordSeconds {
                recordAction(nil)
                ProData.sharedInstance().recorder.stop()
            }
        }
    }
    
    func startTimer() {
        resetTimer()
        timerLabel.text = "00:00"
        playingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ProPushSecViewController.tick), userInfo: nil, repeats: true)
    }
    
    func resetTimer() {
        if playingTimer != nil {
            playingTimer?.invalidate()
            playingTimer = nil
        }
        playedSeconds = 0
        
        let duration = self.durationVoiceAudio()
        let minutesLeft = duration / 60
        let secondsLeft = duration % 60
        let left = NSString(format: "%02i:%02i", minutesLeft, secondsLeft)
        timerLabel.text = left as String
    }
    
    func durationVoiceAudio() -> Int {
        do{
            let avAudioPlayer = try AVAudioPlayer(contentsOf: URL(string: self.recordingMp3FilePath())!)
            return Int(avAudioPlayer.duration)
        }catch(_) {
            return 0
        }
        
    }
    
    @IBAction func listenAction(_ sender: UIButton?) {
        
        if recordButton.isSelected {
            recordAction(nil)
            ProData.sharedInstance().recorder.stop()
        }
        
        if playButton.isSelected {
            resetTimer()
            PlayerManager.sharedInstance().player.pause()
            playButton.isSelected = false
        } else {
            let target = recordingMp3FilePath()
            if !FileManager.default.fileExists(atPath: target!) {
                return
            }
            startTimer()
            PlayerManager.sharedInstance().play([target!])
            if (PlayerManager.sharedInstance().finishDelegate == nil) {
                PlayerManager.sharedInstance().finishDelegate = self;
            }
            playButton.isSelected = true
        }
    }
    
    func recordingMp3FilePath() -> String! {
        let str = self.proDetailModel.proPage;
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        print("音频录制到第%d页", self.proDetailModel.proPage);
        return path! + "/\(proPublishNumber)recording\(str).mp3"
    }
    
    func buildSiriWave() {
        
        let displaylink = CADisplayLink(target: self, selector: #selector(ProPushSecViewController.updateMeters))
        
        
        displaylink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        }catch(_) {}
        
        self.waveformView.waveColor = SwiftDefine.RGB(112, g: 217, b: 0)
        self.waveformView.primaryWaveLineWidth = 3.0
        self.waveformView.secondaryWaveLineWidth = 1.0
        
        ProData.sharedInstance().recorder.prepareToRecord()
        ProData.sharedInstance().recorder.isMeteringEnabled = true
    }
    
    @objc func updateMeters() {
        ProData.sharedInstance().recorder.updateMeters()
        
        let normalizedValue = self.normalizedPowerLevelFromDecibels(ProData.sharedInstance().recorder.averagePower(forChannel: 0))
        
        self.waveformView.update(withLevel: CGFloat(normalizedValue))
    }
    
    func normalizedPowerLevelFromDecibels(_ decibels:Float) -> Float {
        if decibels < -60.0 || decibels == 0.0 {
            return 0.0
        }
        
        return powf((powf(10.0, 0.05 * decibels) - powf(10.0, 0.05 * -60.0)) * (1.0 / (1.0 - powf(10.0, 0.05 * -60.0))), 1.0 / 2.0)
    }
    
    //pro_photo
    @IBAction func vrRemoveAction(_ sender: UIButton) {
        if (self.proDetailModel.proPage == 1) {
            if self.proDetailModel.proFirstDetailModel.vrImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.vrButton.setImage(UIImage(named: "pro_720"), for: UIControl.State())
                    self.proDetailModel.proThirdDetailModel.vrUrl = ""
                    self.proDetailModel.proThirdDetailModel.vrFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 2) {
            if self.proDetailModel.proSecondDetailModel.vrImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.vrButton.setImage(UIImage(named: "pro_720"), for: UIControl.State())
                    self.proDetailModel.proThirdDetailModel.vrUrl = ""
                    self.proDetailModel.proThirdDetailModel.vrFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 3) {
            if self.proDetailModel.proThirdDetailModel.vrImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.vrButton.setImage(UIImage(named: "pro_720"), for: UIControl.State())
                    self.proDetailModel.proThirdDetailModel.vrUrl = ""
                    self.proDetailModel.proThirdDetailModel.vrFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    @IBAction func firstRemoveAction(_ sender: UIButton) {
        if (self.proDetailModel.proPage == 1) {
            if self.proDetailModel.proFirstDetailModel.firstImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.firstButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proFirstDetailModel.firstUrl = ""
                    self.proDetailModel.proFirstDetailModel.firstFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 2) {
            if self.proDetailModel.proSecondDetailModel.firstImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.firstButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proSecondDetailModel.firstUrl = ""
                    self.proDetailModel.proSecondDetailModel.firstFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 3) {
            if self.proDetailModel.proThirdDetailModel.firstImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.firstButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proThirdDetailModel.firstUrl = ""
                    self.proDetailModel.proThirdDetailModel.firstFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func secondRemoveAction(_ sender: UIButton) {
        if (self.proDetailModel.proPage == 1) {
            if self.proDetailModel.proFirstDetailModel.secondImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.secondButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proFirstDetailModel.secondUrl = ""
                    self.proDetailModel.proFirstDetailModel.secondFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 2) {
            if self.proDetailModel.proSecondDetailModel.secondImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.secondButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proSecondDetailModel.secondUrl = ""
                    self.proDetailModel.proSecondDetailModel.secondFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 3) {
            if self.proDetailModel.proThirdDetailModel.secondImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.secondButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proThirdDetailModel.secondUrl = ""
                    self.proDetailModel.proThirdDetailModel.secondFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
    
    @IBAction func thirdRemoveAction(_ sender: UIButton) {
        if (self.proDetailModel.proPage == 1) {
            if self.proDetailModel.proFirstDetailModel.thirdImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.thirdButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proFirstDetailModel.thirdUrl = ""
                    self.proDetailModel.proFirstDetailModel.thirdFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 2) {
            if self.proDetailModel.proSecondDetailModel.thirdImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.thirdButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proSecondDetailModel.thirdUrl = ""
                    self.proDetailModel.proSecondDetailModel.thirdFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        if (self.proDetailModel.proPage == 3) {
            if self.proDetailModel.proThirdDetailModel.thirdImage != nil {
                let alert = UIAlertController(title: "提示", message: "是否确认删除照片", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction) in
                    self.thirdButton.setImage(UIImage(named: "pro_photo"), for: UIControl.State())
                    self.proDetailModel.proThirdDetailModel.thirdUrl = ""
                    self.proDetailModel.proThirdDetailModel.thirdFlag = 0
                })
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == firstTextView {
            if textView.text.count > 0 {
                firstLabel.isHidden = true
            } else {
                firstLabel.isHidden = false
            }
            if (self.proDetailModel.proPage == 1) {
                self.proDetailModel.proFirstDetailModel.firstText = textView.text;
            }
            if (self.proDetailModel.proPage == 2) {
                self.proDetailModel.proSecondDetailModel.firstText = textView.text;
            }
            if (self.proDetailModel.proPage == 3) {
                self.proDetailModel.proThirdDetailModel.firstText = textView.text;
            }
            
            
        } else if textView == secondTextView {
            if textView.text.count > 0 {
                secondLabel.isHidden = true
            } else {
                secondLabel.isHidden = false
            }
            if (self.proDetailModel.proPage == 1) {
                self.proDetailModel.proFirstDetailModel.secondText = textView.text;
            }
            if (self.proDetailModel.proPage == 2) {
                self.proDetailModel.proSecondDetailModel.secondText = textView.text;
            }
            if (self.proDetailModel.proPage == 3) {
                self.proDetailModel.proThirdDetailModel.secondText = textView.text;
            }
        } else if textView == thirdTextView {
            if textView.text.count > 0 {
                thirdLabel.isHidden = true
            } else {
                thirdLabel.isHidden = false
            }
            if (self.proDetailModel.proPage == 1) {
                self.proDetailModel.proFirstDetailModel.thirdText = textView.text;
            }
            if (self.proDetailModel.proPage == 2) {
                self.proDetailModel.proSecondDetailModel.thirdText = textView.text;
            }
            if (self.proDetailModel.proPage == 3) {
                self.proDetailModel.proThirdDetailModel.thirdText = textView.text;
            }
        } else if textView == vrTextView {
            if textView.text.count > 0 {
                vrLabel.isHidden = true
            } else {
                vrLabel.isHidden = false
            }
            if (self.proDetailModel.proPage == 1) {
                self.proDetailModel.proFirstDetailModel.vrTitle = textView.text;
            }
            if (self.proDetailModel.proPage == 2) {
                self.proDetailModel.proSecondDetailModel.vrTitle = textView.text;
            }
            if (self.proDetailModel.proPage == 3) {
                self.proDetailModel.proThirdDetailModel.vrTitle = textView.text;
            }
        }
    }
    
    // MARK:返回上一界面
    @IBAction func popAction(_ sender: UIButton) {
        if (recordClient?.isRecoding == true) {
            KVNProgress.showError(withStatus: "录音中不能进行此操作") {
                
            }
            return;
        } else {
            
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let vs = self.navigationController?.viewControllers
        if vs?.firstIndex(of: self) == nil {
            if self.proDetailModel.proPage >= 1 {
                self.proDetailModel.proPage -= 1
            }
        }
    }
    
    
    // MARK:进入下一页
    @IBAction func nextAction(_ sender: UIButton) {
        if (recordClient?.isRecoding == true) {
            KVNProgress.showError(withStatus: "录音中不能进行此操作") {
                
            }
            return;
        } else {
            
        }
        self.proDetailModel.proPage =  self.proDetailModel.proPage + 1;
        let proVC:ProPushSecViewController = UIStoryboard(name: "publish", bundle: nil).instantiateViewController(withIdentifier: "ProPushSecViewController") as! ProPushSecViewController
        proVC.proDetailModel = proDetailModel;
        proVC.isRoadBook = self.isRoadBook;
        self.navigationController?.pushViewController(proVC, animated: true)
    }
    
    // mark:发布Pro帖子
    @objc func pushAction() {
        if (recordClient?.isRecoding == true) {
            KVNProgress.showError(withStatus: "录音中不能进行此操作") {
                
            }
            return;
        } else {
            
        }
        if (self.isLoading) {
            return;
        }
        if (proDetailModel.proFirstDetailModel.vrImage == nil) {
            self.alertMessage("请上传VR照片")
            return;
        } else {
            if (proDetailModel.proFirstDetailModel.firstImage == nil || proDetailModel.proFirstDetailModel.secondImage == nil || proDetailModel.proFirstDetailModel.thirdImage == nil) {
                self.alertMessage("请上传照片");
                return;
                
            } else {

            }
        }
        if (proDetailModel.proSecondDetailModel.vrImage != nil) {
            if (proDetailModel.proSecondDetailModel.firstImage == nil && proDetailModel.proSecondDetailModel.secondImage == nil || proDetailModel.proSecondDetailModel.thirdImage == nil) {
                self.alertMessage("请上传照片");
                return;
                
            } else {
                
            }
        }
        
        if (proDetailModel.proThirdDetailModel.vrImage != nil) {
            if (proDetailModel.proThirdDetailModel.firstImage == nil || proDetailModel.proThirdDetailModel.secondImage == nil || proDetailModel.proThirdDetailModel.thirdImage == nil) {
                self.alertMessage("请上传照片");
                return;
                
            } else {
                
            }
        }
        
         self.publishCollectionData();
        
    }
    
    // MARK - 开始发布
    func publishCollectionData() {
        self.isLoading = true;
        NBZUtil.saveHistoryTag(proDetailModel);
        let flagVrTitleImageDescArray:NSMutableArray = NSMutableArray()
        if (proDetailModel.proFirstDetailModel.vrTitle != nil && proDetailModel.proFirstDetailModel.vrTitle.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proFirstDetailModel.vrTitle!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        if (proDetailModel.proFirstDetailModel.firstText != nil && proDetailModel.proFirstDetailModel.firstText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proFirstDetailModel.firstText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        if (proDetailModel.proFirstDetailModel.secondText != nil && proDetailModel.proFirstDetailModel.secondText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proFirstDetailModel.secondText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        if (proDetailModel.proFirstDetailModel.thirdText != nil && proDetailModel.proFirstDetailModel.thirdText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proFirstDetailModel.thirdText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        if (proDetailModel.proSecondDetailModel.vrTitle != nil && proDetailModel.proSecondDetailModel.vrTitle.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proSecondDetailModel.vrTitle!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        if (proDetailModel.proSecondDetailModel.firstText != nil && proDetailModel.proSecondDetailModel.firstText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proSecondDetailModel.firstText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        if (proDetailModel.proSecondDetailModel.secondText != nil && proDetailModel.proSecondDetailModel.secondText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proSecondDetailModel.secondText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        if (proDetailModel.proSecondDetailModel.thirdText != nil && proDetailModel.proSecondDetailModel.thirdText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proSecondDetailModel.thirdText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        
        if (proDetailModel.proThirdDetailModel.vrTitle != nil && proDetailModel.proThirdDetailModel.vrTitle.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proThirdDetailModel.vrTitle!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        if (proDetailModel.proThirdDetailModel.firstText != nil && proDetailModel.proThirdDetailModel.firstText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proThirdDetailModel.firstText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        if (proDetailModel.proThirdDetailModel.secondText != nil && proDetailModel.proThirdDetailModel.secondText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proThirdDetailModel.secondText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        if (proDetailModel.proThirdDetailModel.thirdText != nil && proDetailModel.proThirdDetailModel.thirdText.count > 0) {
            flagVrTitleImageDescArray.add(proDetailModel.proThirdDetailModel.thirdText!)
        } else {
            flagVrTitleImageDescArray.add("")
        }
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if (XTCPublishManager.share().isPubishLoading) {
                    
                } else {
                    if (self.isRoadBook) {
                        
                    } else {
                         self.alertMessage("开始发布...")
                    }
                }
                self.perform(#selector(ProPushSecViewController.selectTabBar), with: nil, afterDelay: 0.25);
            }
            
        }
        DispatchQueue.global().async {
            self.proDetailModel.flagVrTitleImageDesc = flagVrTitleImageDescArray.componentsJoined(by: ",");
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd";
            self.proDetailModel.dateString = fmt.string(from: Date());
            
            if (XTCPublishManager.share().isPubishLoading) {
                self.alertMessage("其他帖子上传中，已为您保存到小秘书")
            } else {
                
            }
            // 数据处理
            let publishManager:XTCPublishManager = XTCPublishManager.share();
            publishManager.createPublishProModel(self.proDetailModel);
        }
        
    }
    
    
    @objc func selectTabBar() {
        if (self.isRoadBook) {
            // 路书帖子发布执行等待操作
            self.showHub(withDescription: "正在发布...");
        } else {
            self.isLoading = false;
            if (proDetailModel.chatId != nil && proDetailModel.chatId.count > 0) {
                self.dismiss(animated: true) {
                    StaticCommonUtil.topViewController().navigationController?.popViewController(animated: true);
                }
            } else {
                StaticCommonUtil.topViewController().navigationController?.popToRootViewController(animated: true);
                self.dismiss(animated: true) {
                    
                }
            }
        }
        
    }
    
    func playerManagerVideoFinish() {
        playButton.isSelected = false
        resetTimer()
    }
    
    deinit {
        PlayerManager.sharedInstance().finishDelegate = nil;
        NotificationCenter.default.removeObserver(self);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
