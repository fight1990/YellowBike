//
//  ViewController.swift
//  YellowBike
//
//  Created by butcher on 2018/3/26.
//  Copyright © 2018年 butcher. All rights reserved.
//

import UIKit
import SWRevealViewController
import AMapFoundationKit
import FTIndicator

class ViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, MAMultiPointOverlayRendererDelegate, AMapNaviWalkManagerDelegate{
    
    @IBOutlet weak var panelView: UIView!
    var mapView:MAMapView!
    var search:AMapSearchAPI!
    var pin:MyPinAnnotation!
    var pinView:MAAnnotationView!
    
    var nearBySearch = true
    
    var start:CLLocationCoordinate2D!
    var end:CLLocationCoordinate2D!
    var walkManager:AMapNaviWalkManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .white
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "yellowBikeLogo"))
        self.navigationItem.leftBarButtonItem?.image = UIImage.init(named: "user_center_icon")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem?.image = UIImage.init(named: "icon_slide_energy")?.withRenderingMode(.alwaysOriginal)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        mapView = MAMapView(frame:view.frame)
        view.addSubview(mapView)
        view.bringSubview(toFront: panelView)
        
        mapView.delegate = self
        mapView.zoomLevel = 17
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        //显示更新定位蓝点
        let r = MAUserLocationRepresentation()
        r.showsAccuracyRing = false
        r.showsHeadingIndicator = false;//是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
        r.fillColor = UIColor.red
        r.strokeColor = UIColor.blue
        r.lineWidth = 2
        r.enablePulseAnnimation = false
        r.locationDotBgColor = UIColor.green
        r.locationDotFillColor = UIColor.gray
        r.image = UIImage(named: "homePage_wholeAnchor")
        mapView.update(r)
        
        //地图logo控件
        mapView.logoCenter = CGPoint(x: 10, y: SCREEN_HEIGHT-10)
        
        //指南针控件
        mapView.showsCompass = true
        mapView.compassOrigin = CGPoint(x: SCREEN_WIDTH-40, y: SCREEN_ORIGIN_Y+10)
        
        //比例尺控件
        mapView.showsScale = true
        mapView.scaleOrigin = CGPoint(x: 5, y: SCREEN_ORIGIN_Y+5)
        
        search = AMapSearchAPI()
        search.delegate = self
        
        walkManager = AMapNaviWalkManager()
        walkManager.delegate = self
/*
        let pointAnnotation = MAPointAnnotation()
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: 39.979590, longitude: 116.352792)
        pointAnnotation.title = "方恒国际"
        pointAnnotation.subtitle = "阜通东大街6号"
        mapView.addAnnotation(pointAnnotation)
 */

        if let revealVC = revealViewController() {
            
            revealVC.rearViewRevealWidth = SCREEN_WIDTH - 80
            
            navigationItem.leftBarButtonItem?.target = revealVC
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    @IBAction func locationBtnTap(_ sender: Any) {
        nearBySearch = true
        searchBikeNearby()
    }
    
    //搜索周边小黄车请求
    func searchBikeNearby() {
        searchCustomLocation(mapView.userLocation.coordinate)
    }
    
    func searchCustomLocation(_ center: CLLocationCoordinate2D) {
        
        DispatchQueue.global().async {
            let request = AMapPOIAroundSearchRequest()
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(center.latitude), longitude: CGFloat(center.longitude))
            request.keywords = "餐馆|学校"
            request.radius = 500
            request.requireExtension = true
            
            self.search.aMapPOIAroundSearch(request)

        }
        
    }
/*
    // 绘制点标记
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation.isKind(of: MAPointAnnotation.self) {
            let pointReuseIndetifier = "pointReuseIndetifier"
            var annotationView: MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView!.image = UIImage(named: "redPacket")
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView!.centerOffset = CGPoint(x:0, y:-18);
            
            return annotationView!
        }
        
        return nil
    }
*/
    
    func mapInitComplete(_ mapView: MAMapView!) {
        pin = MyPinAnnotation()
        pin.coordinate = mapView.centerCoordinate
        pin.lockedScreenPoint = self.view.center
        pin.isLockedToScreen = true
        
        mapView.addAnnotation(pin)
        mapView.showAnnotations([pin], animated: true)
        
        searchBikeNearby()
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            searchCustomLocation(mapView.centerCoordinate)
        }
    }
    
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        let aViews = views as! [MAAnnotationView]
        
        for aView in aViews {
            guard aView.annotation is MAPointAnnotation else {
                continue
            }
            
            aView.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
                
                aView.transform = .identity
                
            }, completion: nil)
        }
        
    }
    
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        start = pin.coordinate
        end = view.annotation.coordinate
        
        let startPoint = AMapNaviPoint.location(withLatitude: CGFloat(start.latitude), longitude: CGFloat(start.longitude))!
        let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(end.latitude), longitude: CGFloat(end.longitude))!

        walkManager.calculateWalkRoute(withStart: [startPoint], end: [endPoint])
        
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAUserLocation {
            return nil
        }
        
        if annotation is MyPinAnnotation {
            let reuseid = "anchor"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseid)
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid)
            }
            
            annotationView?.image = UIImage(named: "startPoint")
            annotationView?.canShowCallout = false
            
            pinView = annotationView
            
            return annotationView;
        }

        let reuseid = "myid"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseid)

        if annotationView == nil {
            annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid)
        }
                
        if annotation.title == "正常可用" {
            annotationView?.image = UIImage(named: "HomePage_nearbyBike")
        } else {
            annotationView?.image = UIImage(named: "HomePage_ParkRedPack")
        }
        
        annotationView?.canShowCallout = true;

        return annotationView

    }
    /*
    //自定义海量点样式
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        
        if (overlay.isKind(of: MAMultiPointOverlay.self))
        {
            let renderer = MAMultiPointOverlayRenderer(multiPointOverlay: overlay as! MAMultiPointOverlay!)
            renderer!.delegate = self
            ///设置图片
            if "XX".elementsEqual(overlay.title!) {
                renderer!.icon = UIImage(named: "HomePage_ParkRedPack")
            } else {
                renderer!.icon = UIImage(named: "HomePage_nearbyBike")
            }
            ///设置锚点
            renderer!.anchor = CGPoint(x: 0.5, y: 1.0)
            return renderer;
        }
        
        return nil;
    }
    */
    //搜索周边小黄车后处理
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        guard response.count > 0 else {
            print("没有小黄车")
            return
        }
        
        var annotations:[MAPointAnnotation] = []
        for poi in response.pois {
            let annotation = MAPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
            
            if poi.distance > 80 {
                annotation.title = "红包区域内开锁任意小黄车"
                annotation.subtitle = "骑行10分钟可获得现金红包"
            } else {
                annotation.title = "正常可用"
            }

            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
        
        if nearBySearch {
            mapView.showAnnotations(annotations, animated: true)
            nearBySearch = !nearBySearch
        }
        
  
        /*
        ///创建MultiPointItems数组，并更新数据
        var itemsCT = [MAMultiPointItem]()
        var itemsXX = [MAMultiPointItem]()

        for poi in response.pois {
            let itemCT = MAMultiPointItem()
            let itemXX = MAMultiPointItem()

            
            print(poi.type)
            if poi.type.contains("餐厅") {
                itemCT.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))

                itemsCT.append(itemCT)

            } else {
                itemXX.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))

                itemsXX.append(itemXX)

            }
            
        }
        
        ///根据items创建海量点Overlay MultiPointOverlay
        let overlayCT: MAMultiPointOverlay! = MAMultiPointOverlay(multiPointItems: itemsCT)
        overlayCT.title = "CT"

        ///把Overlay添加进mapView
        self.mapView.add(overlayCT)
        
        ///根据items创建海量点Overlay MultiPointOverlay
        let overlayXX: MAMultiPointOverlay! = MAMultiPointOverlay(multiPointItems: itemsXX)
        overlayXX.title = "XX"

        ///把Overlay添加进mapView
        self.mapView.add(overlayXX)
        
        */
   
    }
    //Mark
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        print("步行路线规划成功！")
        
        //移除存在的规划路线
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = walkManager.naviRoute!.routeCoordinates!.map {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
        }
        
        let polyline = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        
        mapView.add(polyline)
        
        //提示分钟数和距离
        let walkMinute = (walkManager.naviRoute?.routeTime)! / 60
        var timeDesc = "1分钟之内"
        
        if walkMinute > 0 {
            timeDesc = walkMinute.description + "分钟"
        }
        
        let hintTitle = "步行" + timeDesc
        let hintSubTitle = "距离" + (walkManager.naviRoute?.routeLength.description)! + "米"
        
       FTIndicator.setIndicatorStyle(.dark)
    FTIndicator.showNotification(with: #imageLiteral(resourceName: "window_success"), title: hintTitle, message: hintSubTitle)
        
        
        
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            //大头针位置锁死
            pin.isLockedToScreen = false
            //缩放路线可视区域
            mapView.visibleMapRect = overlay.boundingMapRect
            
            let renderer = MAPolylineRenderer(overlay: overlay)
            renderer?.lineWidth = 8.0
            renderer?.strokeColor = .red
            
            return renderer
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

