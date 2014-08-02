//
//  AccountManager.swift
//  FastPX
//
//  Created by Ben Sandofsky on 8/2/14.
//  Copyright (c) 2014 Sandofsky. All rights reserved.
//

import Foundation
import CoreData

private var _sharedAccountManager : AccountManager = {
    let path = _archivePath()
    if NSFileManager.defaultManager().fileExistsAtPath(path) {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as AccountManager
    } else {
        return AccountManager()
    }
}()

private func _archivePath() -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    return documentsPath.stringByAppendingPathComponent("accounts")
}

private let ARCHIVE_NAME = "accountManager.coded"
private let ACCOUNTS_KEY = "ACCOUNTS"
private let LOGGED_OUT_ACCOUNT_KEY = "LOGGED_OUT_ACCOUNT"

class AccountManager: NSObject, NSCoding {

    var accounts : [AuthenticatedAccount]
    var loggedOutAccount : LoggedOutAccount

    override init() {
        accounts = []
        loggedOutAccount = LoggedOutAccount()
        super.init()
    }

    required init(coder aDecoder: NSCoder!) {
        accounts = aDecoder.decodeObjectForKey(ACCOUNTS_KEY) as [AuthenticatedAccount]
        loggedOutAccount = aDecoder.decodeObjectForKey(LOGGED_OUT_ACCOUNT_KEY) as LoggedOutAccount
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(accounts, forKey: ACCOUNTS_KEY)
        aCoder.encodeObject(loggedOutAccount, forKey: LOGGED_OUT_ACCOUNT_KEY)
    }

    class var sharedManager : AccountManager {
        return _sharedAccountManager
    }

    func saveAccountDetails(){
        NSKeyedArchiver.archiveRootObject(_sharedAccountManager, toFile: _archivePath())
    }

    func addAccount(username: String, token: String, secret: String) -> Account {
       let newAccount = AuthenticatedAccount(username: username, token: token, secret: secret)
        accounts.append(newAccount)
        self.saveAccountDetails()
        return newAccount
    }

    func accountForContext(ctx : NSManagedObjectContext) -> Account? {
        for account in self.accounts {
            if ctx == account.managedObjectContext {
                return account
            }
        }
        if ctx == self.loggedOutAccount.managedObjectContext {
            return self.loggedOutAccount
        }
        return nil
    }

}
