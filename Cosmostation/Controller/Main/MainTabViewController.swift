//
//  MainTabViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 05/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import NotificationBannerSwift
import GRPC
import NIO
import SwiftProtobuf

class MainTabViewController: UITabBarController, UITabBarControllerDelegate, SBCardPopupDelegate, AccountSwitchDelegate {
    
    var mAccount: Account!
    var mChainType: ChainType!
    var mAccounts = Array<Account>()
    var mBalances = Array<Balance>()
    var mFetchCnt = 0
        
    var waitAlert: UIAlertController?
    var banner: NotificationBanner?
    var notiView: NotificationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notiView = NotificationView()
        
        self.onUpdateAccountDB()
        self.onFetchAccountData()
        
        self.delegate = self
        self.selectedIndex = BaseData.instance.getLastTab()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if( self.mFetchCnt > 0)  {
            self.showWaittingAlert()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNotificationBanner(_:)), name: Notification.Name("pushNoti"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("pushNoti"), object: nil)
    }
    
    @objc public func showNotificationBanner(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        
        if let notifyto = userInfo["notifyto"] as? String,
            let txid = userInfo["txid"] as? String,
            let type = userInfo["type"] as? String,
            let aps = userInfo["aps"] as? NSDictionary,
            let alert = aps["alert"] as? NSDictionary,
            let title = alert["title"] as? String,
            let body = alert["body"] as? String {
            
            if (type == "sent") {
                notiView!.notiType.image = UIImage.init(named: "notificationsSend")
                notiView!.notiTitle.textColor = UIColor.init(hexString: "#f31963")
                
            } else if (type == "received") {
                notiView!.notiType.image = UIImage.init(named: "notificationsReceive")
                notiView!.notiTitle.textColor = UIColor.init(hexString: "#37cc6e")
            } else {
                return
            }
            
            notiView!.notiTitle.text = title
            notiView!.notiMsg.text = body
            notiView!.actionDismiss = {
                self.banner?.dismiss()
            }
            notiView!.actionBody = {
                let notiAccount = BaseData.instance.selectAccountByAddress(address: notifyto)
                if (notiAccount != nil) {
                    BaseData.instance.setRecentAccountId(notiAccount!.account_id)
                    BaseData.instance.setLastTab(2)
                    
                    let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = mainTabVC
                    self.present(mainTabVC, animated: true, completion: nil)
                }
                self.banner?.dismiss()
            }
            banner = NotificationBanner(customView: notiView!)
            banner?.dismissDuration = 0.5
            banner?.show()
        }
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        BaseData.instance.setLastTab(tabBarController.selectedIndex)
    }
    
    func onShowAccountSwicth() {
        let sourceVC = self.selectedViewController!
        let accountSwitchVC = AccountSwitchViewController(nibName: "AccountSwitchViewController", bundle: nil)
        accountSwitchVC.modalPresentationStyle = .overFullScreen
        accountSwitchVC.resultDelegate = self
        
        sourceVC.view.superview?.insertSubview(accountSwitchVC.view, aboveSubview: sourceVC.view)
        accountSwitchVC.view.transform = CGAffineTransform(translationX: 0, y: -sourceVC.view.frame.size.height)
        UIView.animate(withDuration: 0.3, animations: {
            accountSwitchVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { _ in
            sourceVC.present(accountSwitchVC, animated: false, completion: nil)
        }
    }
    
    func SBCardPopupResponse(type:Int, result: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(490), execute: {
            let naviVC = self.selectedViewController as? UINavigationController
            var tagetVC:BaseViewController?
            if(result == 1) {
                tagetVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController
                tagetVC?.chainType = self.targetChain
                
            } else if(result == 2) {
                tagetVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "RestoreViewController") as! RestoreViewController
                tagetVC?.chainType = self.targetChain
                
            } else if(result == 3) {
                tagetVC = UIStoryboard(name: "Init", bundle: nil).instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
                
            }
            if(tagetVC != nil) {
                tagetVC?.hidesBottomBarWhenPushed = true
                naviVC?.navigationItem.title = ""
                naviVC?.pushViewController(tagetVC!, animated: true)
            }
        })
    }
    
    
    func onUpdateAccountDB() {
        mAccount = BaseData.instance.selectAccountById(id: BaseData.instance.getRecentAccountId())
        mAccounts = BaseData.instance.selectAllAccounts()
        if (mAccount == nil && mAccounts.count > 0) {
            mAccount = mAccounts[0]
            BaseData.instance.setRecentAccountId(mAccount.account_id)
        }
        if (mAccount == nil) {
            print("NO ACCOUNT ERROR!!!!")
            return
        }
        mChainType = WUtils.getChainType(mAccount.account_base_chain)
    }
    
    func onFetchAccountData() -> Bool {
        if (self.mFetchCnt > 0)  {
            return false
        }
        
        BaseData.instance.mParam = nil
        BaseData.instance.mPrices.removeAll()
        BaseData.instance.mIbcPaths.removeAll()
        BaseData.instance.mIbcTokens.removeAll()
        
        
        BaseData.instance.mNodeInfo = nil
        BaseData.instance.mAllValidator.removeAll()
        BaseData.instance.mTopValidator.removeAll()
        BaseData.instance.mOtherValidator.removeAll()
        BaseData.instance.mMyValidator.removeAll()
        BaseData.instance.mBalances.removeAll()
        BaseData.instance.mMyDelegations.removeAll()
        BaseData.instance.mMyUnbondings.removeAll()
        BaseData.instance.mMyReward.removeAll()
        
        BaseData.instance.mBnbTokenList.removeAll()
        BaseData.instance.mBnbTokenTicker.removeAll()
        
        BaseData.instance.mKavaPriceMarkets.removeAll()
        BaseData.instance.mIncentiveParam = nil
        
        BaseData.instance.mOkStaking = nil
        BaseData.instance.mOkUnbonding = nil
        BaseData.instance.mOkTokenList = nil
        BaseData.instance.mOkTickerList = nil
                
        BaseData.instance.mSifVsIncentive = nil
        BaseData.instance.mSifLmIncentive = nil
        
        
        
        //gRPC
        BaseData.instance.mNodeInfo_gRPC = nil
        BaseData.instance.mAccount_gRPC = nil
        BaseData.instance.mAllValidators_gRPC.removeAll()
        BaseData.instance.mBondedValidators_gRPC.removeAll()
        BaseData.instance.mUnbondValidators_gRPC.removeAll()
        BaseData.instance.mMyValidators_gRPC.removeAll()
        
        BaseData.instance.mMyDelegations_gRPC.removeAll()
        BaseData.instance.mMyUnbondings_gRPC.removeAll()
        BaseData.instance.mMyBalances_gRPC.removeAll()
        BaseData.instance.mMyVestings_gRPC.removeAll()
        BaseData.instance.mMyReward_gRPC.removeAll()
                
        BaseData.instance.mStarNameFee_gRPC = nil
        BaseData.instance.mStarNameConfig_gRPC = nil
        
        BaseData.instance.mOsmoPools_gRPC.removeAll()
        
        BaseData.instance.mGravityPools_gRPC.removeAll()
        
        
        
        if (mChainType == ChainType.BINANCE_MAIN || mChainType == ChainType.BINANCE_TEST) {
            self.mFetchCnt = 6
            onFetchNodeInfo()
            onFetchAccountInfo(mAccount)
            onFetchBnbTokens()
            onFetchBnbMiniTokens()
            onFetchBnbTokenTickers()
            onFetchBnbMiniTokenTickers()
            
        } else if (mChainType == ChainType.KAVA_MAIN || mChainType == ChainType.KAVA_TEST) {
            self.mFetchCnt = 11
            onFetchNodeInfo()
            onFetchTopValidatorsInfo()
            onFetchUnbondedValidatorsInfo()
            onFetchUnbondingValidatorsInfo()
            
            onFetchAccountInfo(mAccount)
            onFetchBondingInfo(mAccount)
            onFetchUnbondingInfo(mAccount)
            onFetchAllReward(mAccount)
            
            onFetchPriceFeedParam()
            onFetchKavaIncentiveParam()
            onFetchKavaIncentiveReward(mAccount.account_address)
            
        } else if (mChainType == ChainType.SECRET_MAIN) {
            self.mFetchCnt = 8
            onFetchNodeInfo()
            onFetchTopValidatorsInfo()
            onFetchUnbondedValidatorsInfo()
            onFetchUnbondingValidatorsInfo()
            
            onFetchAccountInfo(mAccount)
            onFetchBondingInfo(mAccount)
            onFetchUnbondingInfo(mAccount)
            onFetchAllReward(mAccount)
            
            self.onShowToast("Using Figment's Data Hub API for Secret Network.")
            
        } else if (mChainType == ChainType.OKEX_MAIN || mChainType == ChainType.OKEX_TEST) {
            self.mFetchCnt = 8
            onFetchNodeInfo()
            onFetchAllValidatorsInfo();
            
            onFetchAccountInfo(mAccount)
            onFetchOkAccountBalance(mAccount)
            onFetchOkTokenList()
            onFetchOkDexTicker()
            
            onFetchOkStakingInfo(mAccount)
            onFetchOkUnbondingInfo(mAccount)
            
            
        } else if (mChainType == ChainType.KI_MAIN || mChainType == ChainType.MEDI_TEST) {
            self.mFetchCnt = 8
            onFetchNodeInfo()
            onFetchTopValidatorsInfo()
            onFetchUnbondedValidatorsInfo()
            onFetchUnbondingValidatorsInfo()
            onFetchAccountInfo(mAccount)
            onFetchBondingInfo(mAccount)
            onFetchUnbondingInfo(mAccount)
            onFetchAllReward(mAccount)
            
        }
                
        else if (self.mChainType == ChainType.COSMOS_MAIN) {
            self.mFetchCnt = 10
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
            self.onFetchgRPCGravityPools()
            
        } else if (self.mChainType == ChainType.IRIS_MAIN || self.mChainType == ChainType.AKASH_MAIN || self.mChainType == ChainType.PERSIS_MAIN ||
                   self.mChainType == ChainType.CRYPTO_MAIN || self.mChainType == ChainType.SENTINEL_MAIN || self.mChainType == ChainType.MEDI_MAIN ||
                   self.mChainType == ChainType.CERTIK_MAIN  || self.mChainType == ChainType.EMONEY_MAIN || self.mChainType == ChainType.FETCH_MAIN ||
                   self.mChainType == ChainType.RIZON_MAIN || self.mChainType == ChainType.BAND_MAIN || self.mChainType == ChainType.JUNO_MAIN ||
                   self.mChainType == ChainType.REGEN_MAIN || self.mChainType == ChainType.BITCANA_MAIN || self.mChainType == ChainType.ALTHEA_MAIN ||
                   self.mChainType == ChainType.GRAVITY_BRIDGE_MAIN || self.mChainType == ChainType.STARGAZE_MAIN) {
            self.mFetchCnt = 9
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
        } else if (self.mChainType == ChainType.IOV_MAIN || self.mChainType == ChainType.IOV_TEST) {
            self.mFetchCnt = 11
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
            self.onFetchgRPCStarNameFees()
            self.onFetchgRPCStarNameConfig()
            
        } else if (self.mChainType == ChainType.SIF_MAIN) {
            self.mFetchCnt = 10
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
            self.onFetchSifLmIncentive(self.mAccount.account_address)
            
        } else if (self.mChainType == ChainType.OSMOSIS_MAIN) {
            self.mFetchCnt = 10
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
            self.onFetchgRPCOsmoPools()
        }
        
        else if (self.mChainType == ChainType.COSMOS_TEST || self.mChainType == ChainType.RIZON_TEST || self.mChainType == ChainType.ALTHEA_TEST ||
                    self.mChainType == ChainType.IRIS_TEST || self.mChainType == ChainType.CERTIK_TEST || self.mChainType == ChainType.UMEE_TEST ||
                    self.mChainType == ChainType.AXELAR_TEST) {
            self.mFetchCnt = 9
            self.onFetchgRPCNodeInfo()
            self.onFetchgRPCAuth(self.mAccount.account_address)
            self.onFetchgRPCBondedValidators(0)
            self.onFetchgRPCUnbondedValidators(0)
            self.onFetchgRPCUnbondingValidators(0)
            
            self.onFetchgRPCBalance(self.mAccount.account_address, 0)
            self.onFetchgRPCDelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCUndelegations(self.mAccount.account_address, 0)
            self.onFetchgRPCRewards(self.mAccount.account_address, 0)
            
        }
        return true
    }
    
    func onFetchFinished() {
        self.mFetchCnt = self.mFetchCnt - 1
        if (mFetchCnt > 0) { return }
        if (WUtils.isGRPC(mChainType!)) {
            BaseData.instance.mAllValidators_gRPC.append(contentsOf: BaseData.instance.mBondedValidators_gRPC)
            BaseData.instance.mAllValidators_gRPC.append(contentsOf: BaseData.instance.mUnbondValidators_gRPC)
            for validator in BaseData.instance.mAllValidators_gRPC {
                var mine = false;
                for delegation in BaseData.instance.mMyDelegations_gRPC {
                    if (delegation.delegation.validatorAddress == validator.operatorAddress) {
                        mine = true;
                        break;
                    }
                }
                for unbonding in BaseData.instance.mMyUnbondings_gRPC {
                    if (unbonding.validatorAddress == validator.operatorAddress) {
                        mine = true;
                        break;
                    }
                }
                if (mine) {
                    BaseData.instance.mMyValidators_gRPC.append(validator)
                }
            }
            
            print("BaseData.instance.mAllValidators_gRPC ", BaseData.instance.mAllValidators_gRPC.count)
            print("BaseData.instance.mBondedValidators_gRPC ", BaseData.instance.mBondedValidators_gRPC.count)
            print("BaseData.instance.mUnbondValidators_gRPC ", BaseData.instance.mUnbondValidators_gRPC.count)
            print("BaseData.instance.mMyValidators_gRPC ", BaseData.instance.mMyValidators_gRPC.count)
            print("BaseData.instance.mMyBalances_gRPC ", BaseData.instance.mMyBalances_gRPC.count)
            
            if (BaseData.instance.mNodeInfo_gRPC == nil) {
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
            } else {
                if (BaseData.instance.mAccount_gRPC != nil && BaseData.instance.mAccount_gRPC!.typeURL.contains(Cosmos_Auth_V1beta1_BaseAccount.protoMessageName) == false) {
                    if (self.mChainType == ChainType.PERSIS_MAIN) {
                        WUtils.onParsePersisVestingAccount()
                    } else {
                        WUtils.onParseVestingAccount(self.mChainType)
                    }
                }
            }
            self.onFetchPriceInfo()
            NotificationCenter.default.post(name: Notification.Name("onFetchDone"), object: nil, userInfo: nil)
            self.hideWaittingAlert()
            return
            
        } else if (mChainType == ChainType.BINANCE_MAIN || mChainType == ChainType.BINANCE_TEST) {
            mAccount    = BaseData.instance.selectAccountById(id: mAccount!.account_id)
            mBalances   = BaseData.instance.selectBalanceById(accountId: mAccount!.account_id)
            BaseData.instance.mBalances = mBalances
            self.onFetchPriceInfo()
            NotificationCenter.default.post(name: Notification.Name("onFetchDone"), object: nil, userInfo: nil)
            self.hideWaittingAlert()
            return
            
        } else if (mChainType == ChainType.OKEX_MAIN || mChainType == ChainType.OKEX_TEST) {
            mAccount    = BaseData.instance.selectAccountById(id: mAccount!.account_id)
            mBalances   = BaseData.instance.selectBalanceById(accountId: mAccount!.account_id)
            
            for validator in BaseData.instance.mAllValidator {
                if (validator.status == validator.BONDED) {
                    BaseData.instance.mTopValidator.append(validator)
                } else {
                    BaseData.instance.mOtherValidator.append(validator)
                }
                if let validator_address = BaseData.instance.mOkStaking?.validator_address {
                    for myVal in validator_address {
                        if (validator.operator_address == myVal) {
                            BaseData.instance.mMyValidator.append(validator)
                        }
                    }
                }
            }
            BaseData.instance.mBalances = mBalances
            self.onFetchPriceInfo()
            
        } else {
            mAccount    = BaseData.instance.selectAccountById(id: mAccount!.account_id)
            mBalances   = BaseData.instance.selectBalanceById(accountId: mAccount!.account_id)
            
            BaseData.instance.mAllValidator.append(contentsOf: BaseData.instance.mTopValidator)
            BaseData.instance.mAllValidator.append(contentsOf: BaseData.instance.mOtherValidator)
            
            for validator in BaseData.instance.mAllValidator {
                var mine = false;
                for delegate in BaseData.instance.mMyDelegations {
                    if (delegate.validator_address == validator.operator_address) {
                        mine = true;
                        break;
                    }
                }
                for unbonding in BaseData.instance.mMyUnbondings {
                    if (unbonding.validator_address == validator.operator_address) {
                        mine = true;
                        break;
                    }
                }
                if (mine) {
                    BaseData.instance.mMyValidator.append(validator)
                }
            }
            BaseData.instance.mBalances = mBalances
            self.onFetchPriceInfo()
            
            print("BaseData.instance.mMyDelegations ", BaseData.instance.mMyDelegations.count)
            print("BaseData.instance.mMyUnbondings ", BaseData.instance.mMyUnbondings.count)
            print("BaseData.instance.mMyReward ", BaseData.instance.mMyReward.count)
            
        }
        
        print("BaseData.instance.mAllValidator ", BaseData.instance.mAllValidator.count)
        print("BaseData.instance.mTopValidator ", BaseData.instance.mTopValidator.count)
        print("BaseData.instance.mOtherValidator ", BaseData.instance.mOtherValidator.count)
        print("BaseData.instance.mMyValidator ", BaseData.instance.mMyValidator.count)
        
        
        if (BaseData.instance.mNodeInfo == nil || BaseData.instance.mAllValidator.count <= 0) {
            self.onShowToast(NSLocalizedString("error_network", comment: ""))
        }
        NotificationCenter.default.post(name: Notification.Name("onFetchDone"), object: nil, userInfo: nil)
        self.hideWaittingAlert()
    }
    
    func onFetchNodeInfo() {
        let request = Alamofire.request(BaseNetWork.nodeInfoUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary, let nodeInfo = responseData.object(forKey: "node_info") as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mNodeInfo = NodeInfo.init(nodeInfo)
                self.mFetchCnt = self.mFetchCnt + 1
                self.onFetchParams(BaseData.instance.getChainId(self.mChainType))
                if let height = responseData.object(forKey: "height") as? Int {
                    BaseData.instance.mHeight = height
                }
                if let heightS = responseData.object(forKey: "height") as? String, let height = Int(heightS) {
                    BaseData.instance.mHeight = height
                }
            case .failure(let error):
                print("onFetchTopValidatorsInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchTopValidatorsInfo() {
        let request = Alamofire.request(BaseNetWork.validatorsUrl(mChainType), method: .get, parameters: ["status":"bonded"], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary, let validators = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                    self.onFetchFinished()
                    return
                }
                for validator in validators {
                    BaseData.instance.mTopValidator.append(Validator(validator as! [String : Any]))
                }
                
            case .failure(let error):
                print("onFetchTopValidatorsInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchUnbondedValidatorsInfo() {
        let request = Alamofire.request(BaseNetWork.validatorsUrl(mChainType), method: .get, parameters: ["status":"unbonded"], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary, let validators = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                    self.onFetchFinished()
                    return
                }
                for validator in validators {
                    BaseData.instance.mOtherValidator.append(Validator(validator as! [String : Any]))
                }
                
            case .failure(let error):
                print("onFetchUnbondedValidatorsInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchUnbondingValidatorsInfo() {
        let request = Alamofire.request(BaseNetWork.validatorsUrl(mChainType), method: .get, parameters: ["status":"unbonding"], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary, let validators = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                    self.onFetchFinished()
                    return
                }
                for validator in validators {
                    BaseData.instance.mOtherValidator.append(Validator(validator as! [String : Any]))
                }
                
            case .failure(let error):
                print("onFetchUnbondingValidatorsInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchAllValidatorsInfo() {
        let request = Alamofire.request(BaseNetWork.validatorsUrl(mChainType), method: .get, parameters: ["status":"all"], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let validators = res as? Array<NSDictionary> else {
                    self.onFetchFinished()
                    return
                }
                for validator in validators {
//                    self.mAllValidator.append(Validator(validator as! [String : Any]))
                    BaseData.instance.mAllValidator.append(Validator(validator as! [String : Any]))
                }
                
            case .failure(let error):
                print("onFetchAllValidatorsInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    
    func onFetchAccountInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.accountInfoUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if (self.mChainType == ChainType.BINANCE_MAIN || self.mChainType == ChainType.BINANCE_TEST) {
                    guard let info = res as? [String : Any] else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.onFetchFinished()
                        return
                    }
                    let bnbAccountInfo = BnbAccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithBnbAccountInfo(account, bnbAccountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithBnbAccountInfo(account, bnbAccountInfo))
                    
                } else if (self.mChainType == ChainType.KAVA_MAIN || self.mChainType == ChainType.KAVA_TEST) {
                    guard let info = res as? [String : Any] else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.onFetchFinished()
                        return
                    }
                    let kavaAccountInfo = KavaAccountInfo.init(info)
                    BaseData.instance.mKavaAccountResult = kavaAccountInfo.result
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithKavaAccountInfo(account, kavaAccountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithKavaAccountInfo(account, kavaAccountInfo))
                    
                } else if (self.mChainType == ChainType.OKEX_MAIN || self.mChainType == ChainType.OKEX_TEST) {
                    guard let info = res as? NSDictionary else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.onFetchFinished()
                        return
                    }
                    let okAccountInfo = OkAccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithOkAccountInfo(account, okAccountInfo))
                    BaseData.instance.mOkAccountInfo = okAccountInfo
                    
                } else if (self.mChainType == ChainType.SENTINEL_MAIN) {
                    guard let info = res as? NSDictionary else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.onFetchFinished()
                        return
                    }
                    let vestingAccountInfo = VestingAccountInfo.init(info)
                    BaseData.instance.mVestingAccountInfoResult = vestingAccountInfo.result
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithVestingAccountInfo(account, vestingAccountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithVestingAccountInfo(account, vestingAccountInfo))
                    
                } else {
                    guard let responseData = res as? NSDictionary,
                        let info = responseData.object(forKey: "result") as? [String : Any] else {
                            _ = BaseData.instance.deleteBalance(account: account)
                            self.onFetchFinished()
                            return
                    }
                    let accountInfo = AccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithAccountInfo(account, accountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithAccountInfo(account, accountInfo))
                }
                
            case .failure(let error):
                print("onFetchAccountInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBondingInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.bondingsUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary,
                    let bondinginfos = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.onFetchFinished()
                        return;
                }
                bondinginfos.forEach { bondinginfo in
                    BaseData.instance.mMyDelegations.append(BondingInfo.init(bondinginfo))
                }
                
            case .failure(let error):
                print("onFetchBondingInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchUnbondingInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.unbondingsUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary,
                    let unbondinginfos = responseData.object(forKey: "result") as? Array<NSDictionary> else {
                        self.onFetchFinished()
                        return
                }
                unbondinginfos.forEach { unbondinginfo in
                    BaseData.instance.mMyUnbondings.append(UnbondingInfo.init(unbondinginfo))
                }
                
            case .failure(let error):
                print("onFetchUnbondingInfo ", error)
            }
            self.onFetchFinished()
        }
    }
    
    
    func onFetchAllReward(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.rewardsUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let responseData = res as? NSDictionary,
                    let rawRewards = responseData.value(forKeyPath: "result.rewards") as? Array<NSDictionary> else {
                        self.onFetchFinished()
                        return;
                }
                rawRewards.forEach { rawReward in
                    BaseData.instance.mMyReward.append(RewardInfo.init(rawReward))
                }
                
            case .failure(let error):
                print("onFetchEachReward ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbTokens() {
        let request = Alamofire.request(BaseNetWork.bnbTokenUrl(mChainType), method: .get, parameters: ["limit":"3000"], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let tokens = res as? Array<NSDictionary> {
                    for token in tokens {
                        let bnbToken = BnbToken(token as! [String : Any])
                        bnbToken.type = BNB_TOKEN_TYPE_BEP2
                        BaseData.instance.mBnbTokenList.append(bnbToken)
                    }
                }
            case .failure(let error):
                print("onFetchBnbTokens ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbMiniTokens() {
        let request = Alamofire.request(BaseNetWork.bnbMiniTokenUrl(mChainType), method: .get, parameters: ["limit":"3000"], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let tokens = res as? Array<NSDictionary> {
                    for token in tokens {
                        let bnbToken = BnbToken(token as! [String : Any])
                        bnbToken.type = BNB_TOKEN_TYPE_MINI
                        BaseData.instance.mBnbTokenList.append(bnbToken)
                    }
                }
            case .failure(let error):
                print("onFetchBnbMiniTokens ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbTokenTickers() {
        print("onFetchBnbTokenTickers ", BaseNetWork.bnbTicUrl(mChainType))
        let request = Alamofire.request(BaseNetWork.bnbTicUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let bnbTickers = res as? Array<NSDictionary> {
//                    print("onFetchBnbTokenTickers ", bnbTickers.count)
                    bnbTickers.forEach { bnbTicker in
                        BaseData.instance.mBnbTokenTicker.append(BnbTicker.init(bnbTicker))
                    }
                }
            case .failure(let error):
                print("onFetchBnbTokenTickers ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchBnbMiniTokenTickers() {
        let request = Alamofire.request(BaseNetWork.bnbMiniTicUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let bnbMiniTickers = res as? Array<NSDictionary> {
//                    print("onFetchBnbMiniTokenTickers ", bnbMiniTickers.count)
                    bnbMiniTickers.forEach { bnbMiniTicker in
                        BaseData.instance.mBnbTokenTicker.append(BnbTicker.init(bnbMiniTicker))
                    }
                }
            case .failure(let error):
                print("onFetchBnbMiniTokenTickers ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchPriceFeedParam() {
        let request = Alamofire.request(BaseNetWork.paramPriceFeedUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
//                print("onFetchPriceFeedParam res ", res)
                guard let responseData = res as? NSDictionary,
                    let _ = responseData.object(forKey: "height") as? String else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mKavaPriceMarkets = KavaPriceFeedParam.init(responseData).result.markets
                print("BaseData.instance.mKavaPriceMarkets ", BaseData.instance.mKavaPriceMarkets.count)
            
            case .failure(let error):
                print("onFetchPriceFeedParam ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchPriceFeedPrice(_ market: String) {
        let request = Alamofire.request(BaseNetWork.priceFeedUrl(mChainType, market), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
//                print("onFetchPriceFeedPrice ", res)
                guard let responseData = res as? NSDictionary,
                    let _ = responseData.object(forKey: "height") as? String else {
                    self.onFetchFinished()
                    return
                }
                let priceParam = KavaPriceFeedPrice.init(responseData)
                BaseData.instance.mKavaPrice[priceParam.result.market_id] = priceParam
                
            case .failure(let error):
                print("onFetchKavaPrice ", market , " ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchKavaIncentiveParam() {
        let request = Alamofire.request(BaseNetWork.paramIncentiveUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
//                    print("IncentiveParam ", res)
                    guard let responseData = res as? NSDictionary,
                        let _ = responseData.object(forKey: "height") as? String else {
                            self.onFetchFinished()
                            return
                    }
                    let kavaIncentiveParam = KavaIncentiveParam.init(responseData)
                    BaseData.instance.mIncentiveParam = kavaIncentiveParam.result
//                    print("mIncentiveParam ", BaseData.instance.mIncentiveParam)
                    
                case .failure(let error):
                    print("onFetchIncentiveParam ", error)
                }
            self.onFetchFinished()
        }
    }
    
    func onFetchKavaIncentiveReward(_ address: String) {
        let request = Alamofire.request(BaseNetWork.incentiveUrl(mChainType), method: .get, parameters: ["owner":address], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
                case .success(let res):
                    guard let responseData = res as? NSDictionary, let _ = responseData.object(forKey: "height") as? String else {
                        self.onFetchFinished()
                        return
                    }
                    let kavaIncentiveReward = KavaIncentiveReward.init(responseData)
                    BaseData.instance.mIncentiveRewards = kavaIncentiveReward.result
//                    print("mIncentiveRewards ", BaseData.instance.mIncentiveRewards?.getAllIncentives().count)

                case .failure(let error):
                    print("onFetchKavaIncentiveReward ", error)
                }
            self.onFetchFinished()
        }
    }
    
    func onFetchOkAccountBalance(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.balanceOkUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let okAccountBalancesInfo = res as? [String : Any] else {
                    _ = BaseData.instance.deleteBalance(account: account)
                    self.onFetchFinished()
                    return
                }
                let okAccountBalances = OkAccountToken.init(okAccountBalancesInfo)
                BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithOkAccountInfo(account, okAccountBalances))
                
            case .failure(let error):
                print("onFetchOkAccountBalance ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchOkStakingInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.stakingOkUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let info = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mOkStaking = OkStaking.init(info)
                
            case .failure(let error):
                print("onFetchOkStakingInfo ", error)
            }
            self.onFetchFinished()
        }
        
    }
    
    func onFetchOkUnbondingInfo(_ account: Account) {
        let request = Alamofire.request(BaseNetWork.unbondingOkUrl(mChainType, account.account_address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let info = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mOkUnbonding = OkUnbonding.init(info)
                
            case .failure(let error):
                print("onFetchOkWithdraw ", error)
            }
            self.onFetchFinished()
        }
        
    }
    
    func onFetchOkTokenList() {
        print("onFetchOkTokenList ", BaseNetWork.tokenListOkUrl(mChainType))
        let request = Alamofire.request(BaseNetWork.tokenListOkUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let tokenList = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mOkTokenList = OkTokenList.init(tokenList)
                
            case .failure(let error):
                print("onFetchOkTokenList ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchOkDexTicker() {
        print("onFetchOkDexTicker ", BaseNetWork.tickerListOkUrl(mChainType))
        let request = Alamofire.request(BaseNetWork.tickerListOkUrl(mChainType), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let tickerList = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mOkTickerList = OkTickerList.init(tickerList)
                
            case .failure(let error):
                print("onFetchOkDexTicker ", error)
            }
            self.onFetchFinished()
        }
        
    }
    
    func onFetchSifLmIncentive(_ address: String) {
        print("onFetchSifLmIncentive url ", BaseNetWork.lmIncentiveUrl(address))
        let request = Alamofire.request(BaseNetWork.lmIncentiveUrl(address), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                guard let resData = res as? NSDictionary else {
                    self.onFetchFinished()
                    return
                }
                BaseData.instance.mSifLmIncentive = SifIncentive.init(resData)
//                print("mSifLmIncentive ", BaseData.instance.mSifLmIncentive?.user?.totalClaimableCommissionsAndClaimableRewards)
                
            case .failure(let error):
                print("onFetchSifLmIncentive ", error)
            }
            self.onFetchFinished()
        }
    }
    
    
    //gRPC
    func onFetchgRPCNodeInfo() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Base_Tendermint_V1beta1_GetNodeInfoRequest()
                if let response = try? Cosmos_Base_Tendermint_V1beta1_ServiceClient(channel: channel).getNodeInfo(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mNodeInfo_gRPC = response.defaultNodeInfo
                    self.mFetchCnt = self.mFetchCnt + 3
                    self.onFetchParams(BaseData.instance.getChainId(self.mChainType))
                    self.onFetchIbcPaths(BaseData.instance.getChainId(self.mChainType))
                    self.onFetchIbcTokens(BaseData.instance.getChainId(self.mChainType))
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCNodeInfo failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCAuth(_ address: String) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address }
                if let response = try? Cosmos_Auth_V1beta1_QueryClient(channel: channel).account(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mAccount_gRPC = response.account
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCAuth failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCBondedValidators(_ offset: Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
                let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).validators(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.validators.forEach { validator in
                        BaseData.instance.mBondedValidators_gRPC.append(validator)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCBondedValidators failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCUnbondedValidators(_ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
                let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDED" }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).validators(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.validators.forEach { validator in
                        BaseData.instance.mUnbondValidators_gRPC.append(validator)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCUnbondedValidators failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCUnbondingValidators(_ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
                let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDING" }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).validators(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.validators.forEach { validator in
                        BaseData.instance.mUnbondValidators_gRPC.append(validator)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCUnbondingValidators failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCBalance(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = address }
                if let response = try? Cosmos_Bank_V1beta1_QueryClient(channel: channel).allBalances(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.balances.forEach { balance in
                        if (NSDecimalNumber.init(string: balance.amount) != NSDecimalNumber.zero) {
                            BaseData.instance.mMyBalances_gRPC.append(Coin.init(balance.denom, balance.amount))
                        }
                    }
                    if (BaseData.instance.getAvailableAmount_gRPC(WUtils.getMainDenom(self.mChainType)).compare(NSDecimalNumber.zero).rawValue <= 0) {
                        BaseData.instance.mMyBalances_gRPC.append(Coin.init(WUtils.getMainDenom(self.mChainType), "0"))
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCBalance failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCDelegations(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = address }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorDelegations(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.delegationResponses.forEach { delegationResponse in
                        BaseData.instance.mMyDelegations_gRPC.append(delegationResponse)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCDelegations failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCUndelegations(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = address }
                if let response = try? Cosmos_Staking_V1beta1_QueryClient(channel: channel).delegatorUnbondingDelegations(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.unbondingResponses.forEach { unbondingResponse in
                        BaseData.instance.mMyUnbondings_gRPC.append(unbondingResponse)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCUndelegations failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCRewards(_ address: String, _ offset:Int) {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = address }
                if let response = try? Cosmos_Distribution_V1beta1_QueryClient(channel: channel).delegationTotalRewards(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.rewards.forEach { reward in
                        BaseData.instance.mMyReward_gRPC.append(reward)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCRewards failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCStarNameFees() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Starnamed_X_Configuration_V1beta1_QueryFeesRequest.init()
                if let response = try? Starnamed_X_Configuration_V1beta1_QueryClient(channel: channel).fees(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mStarNameFee_gRPC = response.fees
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCStarNameFees failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCStarNameConfig() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let req = Starnamed_X_Configuration_V1beta1_QueryConfigRequest.init()
                if let response = try? Starnamed_X_Configuration_V1beta1_QueryClient(channel: channel).config(req, callOptions:BaseNetWork.getCallOptions()).response.wait() {
                    BaseData.instance.mStarNameConfig_gRPC = response.config
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCStarNameConfig failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCOsmoPools() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 1000 }
                let req = Osmosis_Gamm_V1beta1_QueryPoolsRequest.with { $0.pagination = page }
                if let response = try? Osmosis_Gamm_V1beta1_QueryClient(channel: channel).pools(req, callOptions: BaseNetWork.getCallOptions()).response.wait() {
                    response.pools.forEach { pool in
                        let rawPool = try! Osmosis_Gamm_V1beta1_Pool.init(serializedData: pool.value)
                        BaseData.instance.mOsmoPools_gRPC.append(rawPool)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCOsmoPools failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchgRPCGravityPools() {
        DispatchQueue.global().async {
            do {
                let channel = BaseNetWork.getConnection(self.mChainType!, MultiThreadedEventLoopGroup(numberOfThreads: 1))!
                let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 1000 }
                let req = Tendermint_Liquidity_V1beta1_QueryLiquidityPoolsRequest.with { $0.pagination = page }
                if let response = try? Tendermint_Liquidity_V1beta1_QueryClient(channel: channel).liquidityPools(req).response.wait() {
                    response.pools.forEach { pool in
                        BaseData.instance.mGravityPools_gRPC.append(pool)
                    }
                }
                try channel.close().wait()
                
            } catch {
                print("onFetchgRPCGravityPools failed: \(error)")
            }
            DispatchQueue.main.async(execute: { self.onFetchFinished() });
        }
    }
    
    func onFetchPriceInfo() {
        let request = Alamofire.request(BaseNetWork.getPrices(), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let priceInfos = res as? Array<NSDictionary> {
                    priceInfos.forEach { priceInfo in
                        BaseData.instance.mPrices.append(Price.init(priceInfo))
                    }
                }
                NotificationCenter.default.post(name: Notification.Name("onFetchPrice"), object: nil, userInfo: nil)
            
            case .failure(let error):
                print("onFetchPriceInfo ", error)
            }
        }
    }
    
    func onFetchParams(_ chainId: String) {
        print("onFetchParams ", chainId, "   ", BaseNetWork.getParams(chainId))
        let request = Alamofire.request(BaseNetWork.getParams(chainId), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let params = res as? NSDictionary {
                    BaseData.instance.mParam = Param.init(params)
                }
                print("mParam ", BaseData.instance.mParam?.getGdexList()?.count)
            
            case .failure(let error):
                print("onFetchParams ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchIbcPaths(_ chainId: String) {
        print("onFetchIbcPaths ", chainId, "   ", BaseNetWork.getIbcPaths(chainId))
        let request = Alamofire.request(BaseNetWork.getIbcPaths(chainId), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
//                print("onFetchIbcPaths res ", res)
                if let resData = res as? NSDictionary, let senderables = resData.object(forKey: "sendable") as? Array<NSDictionary> {
                    senderables.forEach { senderable in
                        BaseData.instance.mIbcPaths.append(IbcPath.init(senderable))
                    }
                }
//                print("mIbcPaths ", BaseData.instance.mIbcPaths.count)
            
            case .failure(let error):
                print("onFetchIbcPaths ", error)
            }
            self.onFetchFinished()
        }
    }
    
    func onFetchIbcTokens(_ chainId: String) {
        print("onFetchIbcTokens ", chainId, "   ", BaseNetWork.getIbcTokens(chainId))
        let request = Alamofire.request(BaseNetWork.getIbcTokens(chainId), method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:])
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if let resData = res as? NSDictionary, let ibcTokens = resData.object(forKey: "ibc_tokens") as? Array<NSDictionary> {
                    ibcTokens.forEach { ibcToken in
                        BaseData.instance.mIbcTokens.append(IbcToken.init(ibcToken))
                    }
                }
//                print("ibcTokens ", BaseData.instance.mIbcTokens.count)
            
            case .failure(let error):
                print("onFetchIbcTokens ", error)
            }
            self.onFetchFinished()
        }
    }
    
    
    func onShowToast(_ text:String) {
        var style = ToastStyle()
        style.backgroundColor = UIColor.gray
        self.view.makeToast(text, duration: 2.0, position: .bottom, style: style)
    }
    
    public func showWaittingAlert() {
        waitAlert = UIAlertController(title: "", message: "\n\n\n\n", preferredStyle: .alert)
        let image = LoadingImageView(frame: CGRect(x: 0, y: 0, width: 58, height: 58))
        waitAlert!.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerX, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerX, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .centerY, relatedBy: .equal, toItem: waitAlert!.view, attribute: .centerY, multiplier: 1, constant: 0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        waitAlert!.view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 58.0))
        WUtils.clearBackgroundColor(of: waitAlert!.view)
        self.present(waitAlert!, animated: true, completion: nil)
        image.onStartAnimation()
        
    }
    
    public func showKavaTestWarn() {
        let warnAlert = UIAlertController(title: NSLocalizedString("testnet_warn_title", comment: ""), message: "", preferredStyle: .alert)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        let messageText = NSMutableAttributedString(
            string: NSLocalizedString("testnet_warn_msg", comment: ""),
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
            ]
        )
        warnAlert.setValue(messageText, forKey: "attributedMessage")
        warnAlert.addAction(UIAlertAction(title: NSLocalizedString("str_no_more_3day", comment: ""), style: .destructive, handler: { _ in
            BaseData.instance.setKavaWarn()
        }))
        warnAlert.addAction(UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default, handler: nil))
        self.present(warnAlert, animated: true, completion: nil)
    }
    
    public func hideWaittingAlert() {
        if (waitAlert != nil) {
            waitAlert?.dismiss(animated: true, completion: nil)
        }
    }
    
    func accountSelected(_ id: Int64) {
        if (id != self.mAccount.account_id) {
            BaseData.instance.setRecentAccountId(id)
            BaseData.instance.setLastTab(self.selectedIndex)

            let mainTabVC = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate            
            appDelegate.window?.rootViewController = mainTabVC
            self.present(mainTabVC, animated: true, completion: nil)
        }
    }
    
    var targetChain:ChainType?
    func addAccount(_ chain: ChainType) {
        targetChain = chain
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(610), execute: {
            let popupVC = NewAccountTypePopup(nibName: "NewAccountTypePopup", bundle: nil)
            let cardPopup = SBCardPopupViewController(contentViewController: popupVC)
            cardPopup.resultDelegate = self
            cardPopup.show(onViewController: self)
        })
    }
    
}
