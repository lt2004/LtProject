//
//  VRDetailViewController.swift
//  vs
//
//  Created by 邵帅 on 2016/10/19.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

import UIKit
import SDWebImage
import KVNProgress
import MBProgressHUD
import SnapKit
import Masonry

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class VRDetailViewController: XTCBaseViewController, GVRWidgetViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, PlayerManagerStopDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var vrView: GVRPanoramaView!
    @IBOutlet weak var bottomMenuView: UIView!
    
    var detailArray:[PostDetail]? = []
    var manager:SDWebImageManager?
    var vrImage:UIImage? = nil;
    @objc var detail:PostDetail?
    @objc var postId:String? = ""
    var detailShowMenuView:VRDetailShowMenuView = VRDetailShowMenuView()
    var currentSelectIndex:Int = 0;
    var isShowStatusBar:Bool = true;
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleTopLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(NBZUtil.checkIphoneX()) {
            bottomLayoutConstraint.constant = 34;
            titleTopLayoutConstraint.constant = 43;
        } else {
            
        }
        self.bottomMenuView.backgroundColor = SwiftDefine.RGB_CLEAR(0, g: 0, b: 0, d: 0.2);
        self.userLabel.text = "";
        self.timeLabel.text = "";
        self.titleLabel.text = "";
        self.locImageView.isHidden = true;
        
        let bzpath:UIBezierPath = NBZUtil.roundedPolygonPath(with: userButton.bounds, lineWidth: 1.0, sides: 6, cornerRadius: 5)
        let mask:CAShapeLayer = CAShapeLayer()
        mask.path = bzpath.cgPath
        mask.lineWidth = 2.0
        mask.borderColor = UIColor.white.cgColor
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = UIColor.white.cgColor
        userButton.layer.mask = mask
        userButton.clipsToBounds = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        self.collectionView?.collectionViewLayout = layout
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView?.backgroundColor = SwiftDefine.RGB_CLEAR(0, g: 0, b: 0, d: 0.15)
        self.collectionView!.register(UINib(nibName: "VrCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VrCollectionViewCell")
        self.collectionView?.reloadData()
        
        let getdetailModelRequest:RequestGetdetailModel = RequestGetdetailModel();
        getdetailModelRequest.user_id = GlobalData.sharedInstance()?.userModel.user_id;
        getdetailModelRequest.token = GlobalData.sharedInstance().userModel.token;
        getdetailModelRequest.post_id = postId;
        XTCNetworkManager.shareRequestConnect().networkingCommon(by: RequestEnum.RequestGetdetailv2Enum, byRequestDict: getdetailModelRequest) { (responseObject:Any?, errorModel:RSResponseErrorModel?) in
            if (errorModel?.errorEnum == ResponseErrorEnum.successEnum) {
                self.detail = responseObject as? PostDetail;
                self.createRightMenuView()
                self.buildInfo()
                
                NotificationCenter.default.addObserver(self, selector: #selector(VRDetailViewController.OrientationDidChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
                
                self.vrView.enableCardboardButton = false
                self.vrView.enableTouchTracking = true
                self.vrView.enableFullscreenButton = false
                self.vrView.delegate = self
                let flagDict:NSDictionary = self.detail?.headImgList[0] as! NSDictionary;
                SDWebImageManager.shared.loadImage(with: URL(string: flagDict["image"] as! String), options: SDWebImageOptions.retryFailed, progress: nil, completed: { (image:UIImage?, data:Data?, error:Error?, cacheType:SDImageCacheType, finished:Bool, url:URL?) in
                    if image != nil && self.vrView != nil &&  finished == true {
                        self.vrView.load(image)
                        self.vrImage = image!;
                    }
                });
                self.collectionView?.reloadData()
            } else {
                
            }
        }
        
    }
    
    // MARK:推荐链接
    @objc func recommendLinkButtonClick() {
        let commonWebViewVC:CommonWebViewViewController = CommonWebViewViewController();
        commonWebViewVC.titleString = "查看网站";
        commonWebViewVC.urlString = detail?.art_link;
        commonWebViewVC.isPreventPanPop = false;
        self.navigationController?.pushViewController(commonWebViewVC, animated: true);
        
        
    }
    
    // MARK:创建边侧菜单
    func createRightMenuView() {
        let nibArray:NSArray = Bundle.main.loadNibNamed("VRDetailShowMenuView", owner: self, options: nil)! as NSArray;
        detailShowMenuView = nibArray[0] as! VRDetailShowMenuView;
        detailShowMenuView.isUserInteractionEnabled = true;
        vrView.addSubview(detailShowMenuView);
        detailShowMenuView.snp.makeConstraints { (make) in
//            make.width.equalTo(200)
            make.height.equalTo(300)
            make.centerY.equalTo(self.view);
            make.right.equalTo(self.view);
        }
        
        detailShowMenuView.createPersonalInforMenuUI();
        
        if (detail!.voiceUrl == "") {
            detailShowMenuView.soundButton.isEnabled = false;
        } else {
            
        }
        
        if detail!.lat == "" && detail!.lng == "" {
            detailShowMenuView.mapInforButton.isEnabled = false;
        } else {
            
        }
        
        
        if (detail?.art_link != nil && detail?.art_link != "") {
            detailShowMenuView.mapInforButton.isEnabled = true;
        } else {
            detailShowMenuView.mapInforButton.isEnabled = false;
        }
        
        detailShowMenuView.soundButton.addTarget(self, action: #selector(VRDetailViewController.playAction(_:)), for: UIControl.Event.touchUpInside);
        
        detailShowMenuView.mapInforButton.addTarget(self, action: #selector(VRDetailViewController.mapAction), for: UIControl.Event.touchUpInside);
        detailShowMenuView.eyeButton.addTarget(self, action: #selector(VRDetailViewController.carboardAction(_:)), for: UIControl.Event.touchUpInside);
        detailShowMenuView.messageButton.addTarget(self, action: #selector(VRDetailViewController.moreAction(_:)), for: UIControl.Event.touchUpInside);
        detailShowMenuView.crabButton.addTarget(self, action: #selector(VRDetailViewController.linkUrlButtonClick), for: UIControl.Event.touchUpInside);
        
        
        
    }
    
    // MARK:进入链接
    @objc func linkUrlButtonClick() {
        if (self.detail?.art_link == "" || self.detail?.art_link == nil) {
            
        } else {
            let commonWebViewVC:CommonWebViewViewController = CommonWebViewViewController();
            commonWebViewVC.urlString = self.detail?.art_link;
            commonWebViewVC.titleString = "推广链接";
            commonWebViewVC.isPreventPanPop = false;
            self.navigationController?.pushViewController(commonWebViewVC, animated: true);
            
        }
        
    }
    
    
    // MARK:载入相关信息
    func buildInfo() {
        titleLabel.text = detail?.postName
        userLabel.text = detail?.userName
        timeLabel.text = detail?.postTime
        
        locImageView.isHidden = false;
        let cityLocLabel:UILabel = UILabel();
        cityLocLabel.textColor = UIColor.white;
        cityLocLabel.font = UIFont.systemFont(ofSize: 11);
        vrView.addSubview(cityLocLabel);
        
        let countryImageView = UIImageView()
        countryImageView.contentMode = UIView.ContentMode.scaleAspectFill;
        vrView.addSubview(countryImageView)
        
        cityLocLabel.mas_makeConstraints({ (make:MASConstraintMaker!) in
            make.left.equalTo()(locImageView.mas_right)?.with().offset()(3);
            make.centerY.equalTo()(locImageView.mas_centerY);
        })
        if (detail?.cityName == "" || detail?.cityName == "未知") {
            cityLocLabel.text = "";
            countryImageView.mas_makeConstraints({ (make:MASConstraintMaker!) in
                make.left.equalTo()(cityLocLabel.mas_left);
                make.centerY.equalTo()(cityLocLabel.mas_centerY);
                make.height.mas_equalTo()(12);
                make.width.mas_equalTo()(20);
            })
        } else {
            cityLocLabel.text = detail?.cityName
            countryImageView.mas_makeConstraints({ (make:MASConstraintMaker!) in
                make.left.equalTo()(cityLocLabel.mas_right)?.with().offset()(3);
                make.centerY.equalTo()(cityLocLabel.mas_centerY);
                make.height.mas_equalTo()(12);
                make.width.mas_equalTo()(20);
            })
        }
        if (detail?.flag_url == "" || detail?.flag_url == nil) {
            
        } else {
            countryImageView.image = UIImage(named: (detail?.flag_url)!);
            /*
            countryImageView.sd_setImage(with: URL(string:(detail?.flag_url)!), completed: { (image:UIImage?, error:Error?, cacheType:SDImageCacheType, url:URL?) in
                if (error == nil) {
                    countryImageView.image = image;
                } else {
                    countryImageView.image = UIImage(named: "")
                }
            });
 */
        }
        if ((detail?.flag_url == nil || detail?.flag_url == "") && (detail?.cityName == nil || detail?.cityName == "" || detail?.cityName == "未知")) {
            locImageView.isHidden = true;
        } else {
            locImageView.isHidden = false;
        }
        
        if (detail?.userImage != nil) {
            userButton.sd_setBackgroundImage(with: URL(string:(detail?.userImage)!), for: UIControl.State())
        } else {
            
        }
        
        
    }
    
    @objc func OrientationDidChanged() {
        
        if self.vrView == nil {
            return
        }
        
        if UIDevice.current.orientation == UIDeviceOrientation.portrait {
            isShowStatusBar = true;
            self.setNeedsStatusBarAppearanceUpdate();
            for view in self.vrView.subviews {
                if view.isKind(of: NSClassFromString("QTMButton")!) {
                    view.isHidden = true
                } else {
                    view.isHidden = false
                }
            }
        }
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            isShowStatusBar = false;
            self.setNeedsStatusBarAppearanceUpdate();
            for view in self.vrView.subviews {
                if view.isKind(of: NSClassFromString("GVRGlView")!) {
                    view.isHidden = false
                } else {
                    view.isHidden = true
                }
            }
        }
        
        vrView.enableCardboardButton = false
        vrView.enableFullscreenButton = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func widgetView(_ widgetView: GVRWidgetView!, didChange displayMode: GVRWidgetDisplayMode) {
        vrView.enableCardboardButton = false
        vrView.enableFullscreenButton = false
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true;
        
        for view in self.vrView.subviews {
            if view.isKind(of: NSClassFromString("QTMButton")!) {
                view.isHidden = true
            }
        }
        // 如果有音频，界面出现时音频按钮更改为可点击播放状态
        if (detail != nil && detail?.voiceUrl != "") {
            detailShowMenuView.soundButton.isSelected = false;
        } else {
            
        }
        if (vrImage != nil) {
            self.vrView.load(vrImage);
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false;
        self.navigationController?.setToolbarHidden(true, animated: true)
        if (self.vrView != nil) {
            self.vrView.load(nil);
        }
        PlayerManager.sharedInstance().player.pause()
         isShowStatusBar = true;
        self.setNeedsStatusBarAppearanceUpdate();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func op(_ sender: UIButton) {
        if ((self.presentingViewController != nil) && self.navigationController!.viewControllers.count == 1) {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        vrView.removeFromSuperview()
        vrView = nil
        manager = nil
    }
    
    // MARK:更多帖子信息
    @IBAction func moreAction(_ sender: UIButton) {
        let attributedString = NSMutableAttributedString(string:(self.detail?.postDescript)!)
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 9
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, NSString(string: (self.detail?.postDescript)!).length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica", size: 14)!,range: NSMakeRange(0, NSString(string: (self.detail?.postDescript)!).length))
        
        let detailShowDescVC = UIStoryboard(name: "VRDetailShowDesc", bundle: nil).instantiateViewController(withIdentifier: "VRDetailShowDescViewController") as! VRDetailShowDescViewController
        detailShowDescVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        detailShowDescVC.view.backgroundColor = SwiftDefine.RGB_CLEAR(0, g: 0, b: 0, d: 0.5);
        self.present(detailShowDescVC, animated: false) {
            detailShowDescVC.userHeaderImageView.sd_setImage(with: URL(string: (self.detail?.userImage)!), placeholderImage: UIImage(named: "default-avata"), options: SDWebImageOptions.retryFailed, completed: nil)
            detailShowDescVC.descTextView.attributedText = attributedString;
        }
    }
    
    // MARK:播放音频
    @objc func playAction(_ button: UIButton) {
        PlayerManager.sharedInstance().player.pause()
        if !button.isSelected {
            PlayerManager.sharedInstance().play([(detail!.voiceUrl)!])
            if (PlayerManager.sharedInstance().finishDelegate == nil) {
                PlayerManager.sharedInstance().finishDelegate = self;
            }
        }
        button.isSelected = !button.isSelected
    }
    
    // MARK:佩戴VR眼镜
    @objc func carboardAction(_ sender: UIButton) {
        self.vrView.displayMode = GVRWidgetDisplayMode.fullscreenVR
    }
    
    // MARK:进入地图
    @objc func mapAction() {
        self.vrView.load(nil)
        let post = detail
        let to = CLLocationCoordinate2D(latitude: (post!.lat as NSString).doubleValue, longitude: (post!.lng as NSString).doubleValue)
        let vc = UIStoryboard(name: "detail", bundle: nil).instantiateViewController(withIdentifier: "NavigateToViewController") as! NavigateToViewController
        vc.coordinate = to
        vc.mapList = detail!.headImgList
        vc.title = detail!.postName
        vc.userid = detail?.userId;
        vc.isPull = false;
        let maps = detail?.headImgList as! [NSDictionary]
        var only = true
        for idx in 0 ..< maps.count {
            let map = maps[idx]
            if (map["lat"] as! String) == "" || (map["lat"] as! String) == "0"{
                continue
            }
            only = false
        }
        if detail!.videoUrl != "" || only {
            vc.onlyOne = true
        } else {
            vc.onlyOne = false
        }
        vc.isVR = true;
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    @IBAction func reportAction(_ sender: UIButton) {
        let vc = UIStoryboard(name: "XTCReport", bundle: nil).instantiateViewController(withIdentifier: "XTCReportViewController") as! XTCReportViewController
        vc.reportId = detail!.postDetailId
        vc.isChatReport = false;
        let nav = XTCBaseNavigationController(rootViewController: vc);
        self.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detail == nil ? 0 : (detail?.headImgList.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VrCollectionViewCell", for: indexPath) as! VrCollectionViewCell
        let flagDict:NSDictionary = detail?.headImgList[indexPath.item] as! NSDictionary;
        cell.image.sd_setImage(with: URL(string: flagDict["thumbnail_image"] as! String), placeholderImage: nil, options: SDWebImageOptions.retryFailed);
        if indexPath.row == currentSelectIndex {
            cell.image.layer.borderColor = SwiftDefine.RGB(126, g: 221, b: 33).cgColor
        } else {
            cell.image.layer.borderColor = UIColor.clear.cgColor
        }
        cell.image.layer.borderWidth = 1;
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (currentSelectIndex == indexPath.row) {
            
        } else {
            currentSelectIndex = indexPath.row;
            SDImageCache.shared.setValue(nil, forKey: "memCache");
            collectionView.reloadData()
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let flagDict:NSDictionary = detail?.headImgList[indexPath.item] as! NSDictionary;
            
            SDWebImageManager.shared.loadImage(with: URL(string: flagDict["image"] as! String), options: SDWebImageOptions.retryFailed, progress: nil, completed: { (image:UIImage?, data:Data?, error:Error?, cacheType:SDImageCacheType, finished:Bool, url:URL?) in
                DispatchQueue.main.async(execute: { () -> Void in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if image != nil && self.vrView != nil && finished == true {
                        self.vrView.load(image)
                        self.vrImage = image;
                    }
                })
            });
        }
        
    }
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70 * 16 / 9 ,height: 70)
    }
    
    // 分享按钮被点击
    @IBAction func shareButtonClick(_ sender: UIButton) {
        let imageURL:URL = URL(string: detail!.share["prc_url"] as! String)!
        SDWebImageManager.shared.loadImage(with: imageURL, options: SDWebImageOptions.retryFailed, progress: nil, completed: { (image:UIImage?, data:Data?, error:Error?, cacheType:SDImageCacheType, finished:Bool, url:URL?) in
            if (finished == true) {
                let flagDict:NSDictionary = self.detail!.share as NSDictionary;
                XTCShareHelper.shared()?.shreData(byTitle: flagDict["title"] as? String, byDesc: flagDict["desc"] as? String, byThumbnailImage: image!, byMedia: self.detail!.share["url"] as? String, byVC: self, byiPadView: sender);
            }
        });
    }
    
    override var prefersStatusBarHidden: Bool {
        if (isShowStatusBar) {
            return false;
        } else {
            return true;
        }
    }
    
    func playerManagerVideoFinish() {
        detailShowMenuView.soundButton.isSelected = false;
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
