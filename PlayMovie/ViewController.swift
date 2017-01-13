//
//  ViewController.swift
//  PlayMovie
//
//  Created by 任前辈 on 2017/1/13.
//  Copyright © 2017年 任前辈. All rights reserved.
//
import AVKit
import AVFoundation
import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activitView: UIActivityIndicatorView!
    lazy var session:URLSession = {
       let session:URLSession = URLSession.init(configuration: URLSessionConfiguration.default)
        return session
    }()
    var startIndex:Int = 0
   
    var downLoadsArray = {
        return   Array<NSDictionary>()
    }()
    
    lazy var playerVC:AVPlayerViewController = {
        let  playerVC = AVPlayerViewController.init()
        playerVC.view.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 300)
        self.addChildViewController(playerVC)
        self.view.addSubview(playerVC.view)
        return playerVC
    }()
    lazy var models:Array = {
        return   Array<NSDictionary>()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100;
//        tableView .register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cellID")
        view.addSubview(tableView)
        self.activitView.transform = CGAffineTransform.init(scaleX: 2, y: 2);
        self.view.bringSubview(toFront: activitView)
       self .loadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func loadData() {
        self.activitView.startAnimating()
//
        let string = NSString.init(format: "http://www.wondering.top/api3/mb/my_list?device_id=fe949bfdedcbb862dc64a396c67581953a65fb64b1832c8b33a482ef8d5009c4&lang=zh-CN&token=e09408c95802c6007dc5a351e31c652d&trigger=user&user_id=2856649&v=ios_1.4.1&cursor=%ld&target_user_id=2803833", startIndex);
        
       
        
        let task = session.dataTask(with: (URL.init(string: string as String))!, completionHandler:{
            data, response, error in
            if(error == nil){
                let res = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary

                print(res)
                let object = res["list"] as! Array<NSDictionary>
                var currentModels = Array<NSDictionary>();
                var index:Int = 0;
                for dic in object{
                    let model = NSMutableDictionary()
                    let content = dic["content"]
                    model["title"] = String.init(format: "%ld\(content)", self.startIndex + index)
                    index += 1
                   let attachment = dic["attachment"] as! NSDictionary
                    let dub = attachment["dub"] as? NSDictionary
                
                    if(dub != nil){
                        let videodic = dub!["video"] as!NSDictionary
                        model["video"] = videodic["file"]
                        currentModels.append(model)

                    }
                    
                    self.models.append(model)
                }
                
               
             
                
                DispatchQueue.main.async {
                    if(currentModels.count>0){
                        //下载电影到桌面
                        self.downLoadsArray = currentModels
                        self.downLoadmovie()
                    }
                    self.tableView.reloadData()
                    self.title = NSString.init(format: "%ld条", self.models.count) as String
                    self.activitView.stopAnimating()
                    
                   
                }
                
                
            }
        });
        
        task.resume();
    }
    
    func downLoadmovie()  {
        
        if(self.downLoadsArray.count==0){
            //获取最新数据
             startIndex += 20;
             self.loadData()
            return;
        }
        
        let model = self.downLoadsArray.first
        let title = model?["title"] as! String
        let address = model?["video"]as! String
                //下载z
        let  task =  session.downloadTask(with: URL.init(string: address)!, completionHandler: { (localurl, response, error) in

            if (error == nil){
                   try? FileManager.default.copyItem(at: localurl!, to: URL.init(fileURLWithPath: String.init(format: "/Users/renqianbei/Desktop/movie/%@.mp4", title)))
                    }else{
                        print(error ?? "hello")
                        print(address);
                }
            self.downLoadsArray.remove(at: 0)
            self.downLoadmovie()
            
        })
        task.resume()

        
   }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.models[indexPath.row] as NSDictionary!
        if(model?["video"] != nil){
            playerVC.player?.pause()
            playerVC.player = AVPlayer.init(url: URL.init(string: model?["video"] as! String)!)
            playerVC.player?.play();
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let model = self.models[indexPath.row] as NSDictionary!
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        if(cell==nil){
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cellID")
        }
        
         cell!.textLabel?.text = model?["title"] as? String
        
         cell!.detailTextLabel?.text = model?["video"]as?String ?? "无"
        print(model?["video"] ?? "无")
         return cell!;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    @IBAction func nextPage(_ sender: Any) {
//        startIndex += 20;
//        self.loadData()
    }
    
    
    
    
}


