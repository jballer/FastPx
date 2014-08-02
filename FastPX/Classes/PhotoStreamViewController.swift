//
//  PhotoStreamViewController.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/6/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import UIKit

private let CELL_IDENTIFIER = "com.sandofsky.fastpx.photoCell"

class PhotoStreamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AuthenicationDelegate {
    var photosTableView: UITableView!
    var account : Account!

    var photoStream : PhotoStream! {
        get {
            return nil
        }
    }

    // MARK: - Initializers and Deinitializers

    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    init(account: Account){
        self.account = account
        super.init(nibName: nil, bundle: nil)
        weak var weakSelf = self
        NSNotificationCenter.defaultCenter().addObserverForName(PhotoStreamDidUpdateNotification, object: self.photoStream, queue: NSOperationQueue.mainQueue()) {
            [weak self] notification in
            if let strongSelf = weakSelf {
                strongSelf.photosTableView.reloadData()
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View Life Cycle

    override func loadView() {
        photosTableView = UITableView(frame: CGRectZero)
        photosTableView.registerClass(PhotoCellTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        photosTableView.dataSource = self
        photosTableView.delegate = self
        photosTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view = photosTableView
    }

    override func viewDidAppear(animated: Bool) {
        self.photoStream.loadNewer()
    }

    override func viewDidLoad() {
        if self.account is LoggedOutAccount {
            let signInButton = UIBarButtonItem(title: NSLocalizedString("Sign In", comment:""), style: UIBarButtonItemStyle.Plain, target: self, action: "didTapSignIn:")
            self.navigationItem.rightBarButtonItem = signInButton
        }
    }

    // MARK: - Authentication

    func didTapSignIn(button: AnyObject){
        let nav =  UIStoryboard(name: "Authentication", bundle: nil).instantiateInitialViewController() as UINavigationController
        let authVC = nav.viewControllers[0] as AuthenticationViewController
        authVC.delegate = self
        self.navigationController.presentViewController(nav, animated: true, completion: nil)
    }
    func authenticationViewControllerDidCancel(viewcontroller: AuthenticationViewController) {
        self.navigationController.dismissViewControllerAnimated(true, completion: nil)
    }

    func authenticationViewController(viewController: AuthenticationViewController, didLoginWithAccount account: Account){
        self.navigationController.dismissViewControllerAnimated(true, completion: nil)
        (UIApplication.sharedApplication().delegate as AppDelegate).switchToAccount(account, animated:true)
    }

    // MARK: - Table Views

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        if let timeline = self.photoStream {
            return timeline.entries.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return tableView.bounds.width
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as PhotoCellTableViewCell
        let entry = self.photoStream.entries[indexPath.row]
        cell.photo = entry.photo
        return cell
    }
}
