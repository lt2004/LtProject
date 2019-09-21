//
//  ProDetailViewController.swift
//  vs
//
//  Created by 邵帅 on 2017/1/12.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

import UIKit
import SDWebImage
import KVNProgress

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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class ProDetailViewController: XTCBaseViewController, GVRWidgetViewDelegate, HysteriaPlayerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate,PlayerManagerStopDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var vrView: GVRPanoramaView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gifBackGround: UIView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var userLevelImageView: UIImageView!
    @objc
    var detail:ProDetail?
    var proId = ""
    var manager:SDWebImageManager?
    var url:String?
    @objc
    var page = 0
    
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        gifBackGround.isHidden = true
        buildInfo()
        
        if (SwiftDefine.isX()) {
            topLayoutConstraint.constant = 45;
            bottomLayoutConstraint.constant = 42;
        } else {
            topLayoutConstraint.constant = 25;
            bottomLayoutConstraint.constant = 8;
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        collectionView?.collectionViewLayout = layout
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView?.backgroundColor = UIColor.clear
        collectionView!.register(UINib(nibName: "VrCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VrCollectionViewCell")
        collectionView?.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(ProDetailViewController.OrientationDidChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        vrView.enableCardboardButton = false
        vrView.enableTouchTracking = true
        vrView.enableFullscreenButton = false
        vrView.delegate = self
        
        if page == 0 {
            leftButton.isHidden = true
            if detail?.detailed.count <= 1 {
                rightButton.isHidden = true
            }
        }
        
        if page == 1 {
            leftButton.isHidden = false
            
            if detail?.detailed.count == 3 {
                rightButton.isHidden = false
            } else {
                rightButton.isHidden = true
            }
        }
        
        if page == 2 {
            leftButton.isHidden = false
            rightButton.isHidden = true
        }
    }
    
    func buildInfo() {
        titleLabel.text = detail?.posttitle
        userLabel.text = detail?.userName
        timeLabel.text = detail?.postTime
        locLabel.text = detail?.cityName
        userButton.sd_setBackgroundImage(with: URL(string: (detail?.userImage)!), for: UIControl.State())
        let bzpath:UIBezierPath = NBZUtil.roundedPolygonPath(with: userButton.bounds, lineWidth: 1.0, sides: 6, cornerRadius: 10)
        let mask:CAShapeLayer = CAShapeLayer()
        mask.path = bzpath.cgPath
        mask.lineWidth = 2.0
        mask.borderColor = UIColor.white.cgColor
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = UIColor.white.cgColor
        userButton.layer.mask = mask
        userButton.clipsToBounds = true
        
        if detail!.lat == "" && detail!.lng == "" {
            mapButton.isHidden = true
        } else {
            mapButton.isHidden = false
        }

        let x = detail?.detailed[page] as! NSDictionary
        
        let videoUrl = x["audio_url"] as! String;
        if (videoUrl == "") {
            playButton.isHidden = true
        } else {
            playButton.isHidden = false
        }
        
        let y = x["vr_url"] as! String
        url = y
        let cacheStr:String =  SDWebImageManager.shared.cacheKey(for: URL(string: url!))!
        if (cacheStr != "") {
            
        } else {
            self.gifBackGround.isHidden = false
            ProData.sharedInstance().finish = false
        }
        SDWebImageManager.shared.loadImage(with: URL(string: url!), options: SDWebImageOptions.retryFailed, progress:nil) { (image:UIImage?,data:Data?, error:Error? ,cacheType:SDImageCacheType, finished:Bool,url:URL?) in
            ProData.sharedInstance().finish = true
            self.gifBackGround.isHidden = true
            if image != nil && self.vrView != nil && finished == true  {
                self.vrView.load(image)
            }
        };
    }
    
    @objc func OrientationDidChanged() {
        
        if !ProData.sharedInstance().finish {
            return
        }
        
        if self.vrView == nil {
            return
        }
        
        if UIDevice.current.orientation == UIDeviceOrientation.portrait {
            for view in self.vrView.subviews {
                if view.isKind(of: NSClassFromString("QTMButton")!) {
                    view.isHidden = true
                } else {
                    view.isHidden = false
                }
            }
            
            if detail!.lat == "" && detail!.lng == "" {
                mapButton.isHidden = true
            } else {
                mapButton.isHidden = false
            }
            leftButton.setImage(UIImage(named: "pro_left"), for: UIControl.State())
            rightButton.setImage(UIImage(named: "pro_right"), for: UIControl.State())
            leftButton.isEnabled = true;
             rightButton.isEnabled = true;
        }
        
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            for view in self.vrView.subviews {
                if view.isKind(of: NSClassFromString("GVRGlView")!) {
                    view.isHidden = false
                } else {
                    view.isHidden = true
                }
            }
            leftButton.setImage(UIImage(named: "clear_image"), for: UIControl.State())
            rightButton.setImage(UIImage(named: "clear_image"), for: UIControl.State())
            leftButton.isEnabled = false;
            rightButton.isEnabled = false;
        }
        
        gifBackGround.isHidden = true
        vrView.enableCardboardButton = false
        vrView.enableFullscreenButton = false
    }
    
    func widgetView(_ widgetView: GVRWidgetView!, didChange displayMode: GVRWidgetDisplayMode) {
        vrView.enableCardboardButton = false
        vrView.enableFullscreenButton = false
        playButton.isSelected = PlayerManager.sharedInstance().player.isPlaying()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.playButton.isSelected = false
        if self.navigationController?.isNavigationBarHidden == false {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
        
        for view in self.vrView.subviews {
            if view.isKind(of: NSClassFromString("QTMButton")!) {
                view.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProData.sharedInstance().finish = false
        PlayerManager.sharedInstance().player.pause()
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
//        SDImageCache.shared().setValue(nil, forKey: "memCache")
        SDImageCache.shared.setValue(nil, forKey: "memCache")
    }
    
    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if detail == nil {
            return 0
        }
        let x = detail?.detailed[page] as! NSDictionary
        let y = x["images"] as! [AnyObject]
        return y.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VrCollectionViewCell", for: indexPath) as! VrCollectionViewCell
        
        //        if indexPath.item == 0{
        //            cell.playButton.hidden = false
        //            cell.image.sd_setImageWithURL(NSURL(string: ("http://mobile.viewspeaker.com/" + (detail?.videophoto_url)!)))
        //        } else {
        cell.playButton.isHidden = true
        let x = detail?.detailed[page] as! NSDictionary
        let y = x["images"] as! [AnyObject]
        let thumDict:NSDictionary = y[indexPath.item] as! NSDictionary;
        let url = thumDict["thumbnail_image"] as! String
        cell.image.sd_setImage(with: URL(string:url))
        //        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SDImageCache.shared.setValue(nil, forKey: "memCache")
        /*
         for (NSDictionary *flagDict in selectArray) {
         PublishSourceModel *sourceModel = [[PublishSourceModel alloc] init];
         sourceModel.sourceDesc = flagDict[@"photodesc"];
         sourceModel.sourceImage = flagDict[@"thumbnail_image"];
         [flagMutableArray addObject:sourceModel];
         }
 */
        let flagImageArray:NSMutableArray = NSMutableArray();
        let flagDict = detail?.detailed[page] as! NSDictionary
        let imageArray = flagDict["images"] as! [AnyObject]
        for i in 0 ..< imageArray.count {
            let sourceModel:PublishSourceModel = PublishSourceModel()
            let strDict:NSDictionary = imageArray[i] as! NSDictionary;
            sourceModel.sourceDesc = strDict["photodesc"] as? String;
//            var flagDict:NSDictionary = imageArray[i] as! NSDictionary;
            flagImageArray.add(sourceModel);
        }
        
        let browser = MWPhotoBrowser(delegate: self)
        browser?.setCurrentPhotoIndex(UInt(indexPath.row))
        browser?.autoPlayOnAppear = true
        browser?.displayActionButton = false
        browser?.isLS = true;
        browser?.publishSourceModelArray = flagImageArray;
        browser?.postUserId = self.detail?.userId;
        let nav = XTCBaseNavigationController(rootViewController: browser!)
        self.present(nav, animated: true, completion: nil)
    }
    
    // MARK: - MWPhotoBrowser
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(detail!.detailed.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        let flagDict = detail?.detailed[page] as! NSDictionary
        let imageArray = flagDict["images"] as! [AnyObject]
         let strDict:NSDictionary = imageArray[Int(index)] as! NSDictionary;
        let urlStr:String = strDict["thumbnail_image"] as! String;
        return MWPhoto(url: URL(string: (urlStr)))
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
        let x = detail?.detailed[page] as! NSDictionary
        let y = x["images"] as! [AnyObject]
        let strDict:NSDictionary = y[indexPath.item] as! NSDictionary;
        let w_str = (strDict["width"] as AnyObject).description
        let h_str = (strDict["height"] as AnyObject).description
        //        let w_str = y[indexPath.item]["width"] as AnyObject
        //        let h_str = y[indexPath.item]["height"] as AnyObject
        if w_str == nil || h_str == nil {
            return CGSize(width: 90 * 16 / 9, height: 90)
        }
//        let w = CGFloat(NumberFormatter().number(from: w_str!)!)
//        let h = CGFloat(NumberFormatter().number(from: h_str!)!)
        let w = self.stringToFloat(str: w_str!)
        let h = self.stringToFloat(str: h_str!)
        return CGSize(width: w/h*90,height: 90)
    }
    
    func stringToFloat(str:String)->(CGFloat){
        let string = str
        var cgFloat:CGFloat = 0
        if let doubleValue = Double(string)
        {
            cgFloat = CGFloat(doubleValue)
        }
        return cgFloat
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pageUp(_ sender: UIButton) {
        
        PlayerManager.sharedInstance().player.pause()
        playButton.isSelected = false
        
        page -= 1
        rightButton.isHidden = false
        
        if page == 0 {
            leftButton.isHidden = true
        }
        
        collectionView.reloadData()
        
        let x = detail?.detailed[page] as! NSDictionary
        let y = x["vr_url"] as! String
        url = y
        
        let cacheStr:String =  SDWebImageManager.shared.cacheKey(for: URL(string: url!))!
        if (cacheStr != "") {
            
        } else {
            self.gifBackGround.isHidden = false
            ProData.sharedInstance().finish = false
        }
        
        
        self.vrView.load(NBZUtil.createImage(with: UIColor.clear))
        SDWebImageManager.shared.loadImage(with: URL(string: url!), options: SDWebImageOptions.retryFailed, progress: nil) { (image:UIImage?,data:Data?, error:Error? ,cacheType:SDImageCacheType, finished:Bool,url:URL?) in
            ProData.sharedInstance().finish = true
            self.gifBackGround.isHidden = true
            if image != nil && self.vrView != nil && finished == true {
                self.vrView.load(image)
            }
        };
    }
    
    @IBAction func pageDown(_ sender: UIButton) {
        
        PlayerManager.sharedInstance().player.pause()
        playButton.isSelected = false
        
        page += 1
        leftButton.isHidden = false
        
        if detail?.detailed.count == page + 1 {
            rightButton.isHidden = true
        }
        
        collectionView.reloadData()
        
        let x = detail?.detailed[page] as! NSDictionary
        let y = x["vr_url"] as! String
        url = y
        
        let cacheStr:String =  SDWebImageManager.shared.cacheKey(for: URL(string: url!))!
        if (cacheStr == "") {
            self.gifBackGround.isHidden = false
            ProData.sharedInstance().finish = false
        }
        
        self.vrView.load(NBZUtil.createImage(with: UIColor.clear))
        
        SDWebImageManager.shared.loadImage(with: URL(string: url!), options: SDWebImageOptions.retryFailed, progress: nil) { (image:UIImage?,data:Data?, error:Error? ,cacheType:SDImageCacheType, finished:Bool,url:URL?) in
            ProData.sharedInstance().finish = true
            self.gifBackGround.isHidden = true
            if image != nil && self.vrView != nil && finished == true {
                self.vrView.load(image)
            }
        };
        
        
    }
    
    @IBAction func playAction(_ sender: UIButton) {
        
        PlayerManager.sharedInstance().player.pause()
        let x = detail?.detailed[page] as! NSDictionary
        let y = x["audio_url"] as! String
        if !sender.isSelected {
            PlayerManager.sharedInstance().play([(y)])
            if (PlayerManager.sharedInstance().finishDelegate == nil) {
                PlayerManager.sharedInstance().finishDelegate = self;
            }
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func cardboardAction(_ sender: UIButton) {
        self.vrView.displayMode = GVRWidgetDisplayMode.fullscreenVR
    }
    
    @IBAction func mapAction(_ sender: UIButton) {
        
        let post = detail
        let to = CLLocationCoordinate2D(latitude: (post!.lat as NSString).doubleValue, longitude: (post!.lng as NSString).doubleValue)
        let vc = UIStoryboard(name: "detail", bundle: nil).instantiateViewController(withIdentifier: "NavigateToViewController") as! NavigateToViewController
        vc.coordinate = to
        vc.userid = post?.userId;
        vc.isPull = false;
        let x = detail?.detailed[page] as! NSDictionary
        let y = x["images"] as! [AnyObject]
        
        vc.mapList = y
        vc.isVR = false;
        vc.title = detail!.posttitle
        
        let maps = y
        
        var only = true
        for idx in 0 ..< maps.count {
            
            let map = maps[idx] as! NSDictionary
            
            if (map["lat"] as! String) == "" || (map["lat"] as! String) == "0"{
                continue
            }
            only = false
        }
        
        vc.onlyOne = only
        vc.isPro = true
        let nav = UINavigationController(rootViewController: vc)
        
        //显示工具栏，隐藏导航栏
        nav.setToolbarHidden(false, animated: true)
        nav.setNavigationBarHidden(true, animated: true)
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        if self.presentingViewController == nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func reportAction(_ sender: UIButton) {
        let vc = UIStoryboard(name: "XTCReport", bundle: nil).instantiateViewController(withIdentifier: "XTCReportViewController") as! XTCReportViewController
        vc.reportId = detail!.postDetailId
        vc.isChatReport = false;
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    
    func playerManagerVideoFinish() {
        playButton.isSelected = false
    }
    
    deinit {
        self.vrView.load(nil);
        PlayerManager.sharedInstance().finishDelegate = nil;
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
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
