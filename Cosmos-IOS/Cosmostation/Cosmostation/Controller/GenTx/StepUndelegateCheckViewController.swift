//
//  StepUndelegateCheckViewController.swift
//  Cosmostation
//
//  Created by yongjoo on 12/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit
import Alamofire
import BitcoinKit
import SwiftKeychainWrapper

class StepUndelegateCheckViewController: BaseViewController, PasswordViewDelegate{
    
    @IBOutlet weak var toUnDelegateAmoutLaebl: UILabel!
    @IBOutlet weak var toUndelegateDenomLabel: UILabel!
    @IBOutlet weak var feeAmountLabel: UILabel!
    @IBOutlet weak var feeDenomLabel: UILabel!
    @IBOutlet weak var targetValidatorLabel: UILabel!
    @IBOutlet weak var expectedDateLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var pageHolderVC: StepGenTxViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        pageHolderVC = self.parent as? StepGenTxViewController
        WUtils.setDenomTitle(pageHolderVC.chainType!, toUndelegateDenomLabel)
        WUtils.setDenomTitle(pageHolderVC.chainType!, feeDenomLabel)
    }
    
    
    @IBAction func onClickConfirm(_ sender: Any) {
        let passwordVC = UIStoryboard(name: "Password", bundle: nil).instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
        self.navigationItem.title = ""
        self.navigationController!.view.layer.add(WUtils.getPasswordAni(), forKey: kCATransition)
        passwordVC.mTarget = PASSWORD_ACTION_CHECK_TX
        passwordVC.resultDelegate = self
        self.navigationController?.pushViewController(passwordVC, animated: false)
    }
    
    
    @IBAction func onClickBack(_ sender: Any) {
        self.beforeBtn.isUserInteractionEnabled = false
        self.confirmBtn.isUserInteractionEnabled = false
        pageHolderVC.onBeforePage()
    }
    
    override func enableUserInteraction() {
        self.onUpdateView()
        self.beforeBtn.isUserInteractionEnabled = true
        self.confirmBtn.isUserInteractionEnabled = true
    }
    
    func onUpdateView() {
        if (pageHolderVC.chainType! == ChainType.COSMOS_MAIN || pageHolderVC.chainType! == ChainType.KAVA_MAIN || pageHolderVC.chainType! == ChainType.KAVA_TEST ||
            pageHolderVC.chainType! == ChainType.BAND_MAIN || pageHolderVC.chainType! == ChainType.IOV_MAIN || pageHolderVC.chainType! == ChainType.IOV_TEST || pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
            toUnDelegateAmoutLaebl.attributedText = WUtils.displayAmount((pageHolderVC.mToUndelegateAmount?.amount)!, toUnDelegateAmoutLaebl.font, 6, pageHolderVC.chainType!)
            feeAmountLabel.attributedText = WUtils.displayAmount((pageHolderVC.mFee?.amount[0].amount)!, feeAmountLabel.font, 6, pageHolderVC.chainType!)
        } else if (pageHolderVC.chainType! == ChainType.IRIS_MAIN) {
            toUnDelegateAmoutLaebl.attributedText = WUtils.displayAmount((pageHolderVC.mToUndelegateAmount?.amount)!, toUnDelegateAmoutLaebl.font, 18, pageHolderVC.chainType!)
            feeAmountLabel.attributedText = WUtils.displayAmount((pageHolderVC.mFee?.amount[0].amount)!, feeAmountLabel.font, 18, pageHolderVC.chainType!)
        }
        targetValidatorLabel.text = pageHolderVC.mTargetValidator?.description.moniker
        memoLabel.text = pageHolderVC.mMemo
        if (pageHolderVC.chainType! == ChainType.IOV_MAIN || pageHolderVC.chainType! == ChainType.IOV_TEST) {
            expectedDateLabel.text = WUtils.unbondingDateFromNow(3) + " (3days after)"
        } else if (pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
            expectedDateLabel.text = WUtils.unbondingDateFromNow(14) + " (14days after)"
        } else {
            expectedDateLabel.text = WUtils.unbondingDateFromNow(21) + " (21days after)"
        }
    }

    func passwordResponse(result: Int) {
        if (result == PASSWORD_RESUKT_OK) {
            self.onFetchAccountInfo(pageHolderVC.mAccount!)
        }
    }
    
    func onFetchAccountInfo(_ account: Account) {
        self.showWaittingAlert()
        var url: String?
        if (pageHolderVC.chainType! == ChainType.COSMOS_MAIN) {
             url = COSMOS_URL_ACCOUNT_INFO + account.account_address
        } else if (pageHolderVC.chainType! == ChainType.IRIS_MAIN) {
            url = IRIS_LCD_URL_ACCOUNT_INFO + account.account_address
        } else if (pageHolderVC.chainType! == ChainType.KAVA_MAIN) {
            url = KAVA_ACCOUNT_INFO + account.account_address
        } else if (pageHolderVC.chainType! == ChainType.KAVA_TEST) {
            url = KAVA_TEST_ACCOUNT_INFO + account.account_address
        } else if (pageHolderVC.chainType! == ChainType.BAND_MAIN) {
            url = BAND_ACCOUNT_INFO + account.account_address
        } else if (pageHolderVC.chainType! == ChainType.IOV_MAIN) {
            url = IOV_ACCOUNT_INFO + account.account_address
        } else if (pageHolderVC.chainType! == ChainType.IOV_TEST) {
            url = IOV_TEST_ACCOUNT_INFO + account.account_address
        } else if (pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
            url = CERTIK_TEST_ACCOUNT_INFO + account.account_address
        }
        let request = Alamofire.request(url!, method: .get, parameters: [:], encoding: URLEncoding.default, headers: [:]);
        request.responseJSON { (response) in
            switch response.result {
            case .success(let res):
                if (self.pageHolderVC.chainType! == ChainType.COSMOS_MAIN) {
                    guard let responseData = res as? NSDictionary,
                        let info = responseData.object(forKey: "result") as? [String : Any] else {
                            _ = BaseData.instance.deleteBalance(account: account)
                            self.hideWaittingAlert()
                            self.onShowToast(NSLocalizedString("error_network", comment: ""))
                            return
                    }
                    let accountInfo = AccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithAccountInfo(account, accountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithAccountInfo(account, accountInfo))
                    self.onGenUnDelegateTx()
                    
                } else if (self.pageHolderVC.chainType! == ChainType.IRIS_MAIN) {
                    guard let info = res as? [String : Any] else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.hideWaittingAlert()
                        self.onShowToast(NSLocalizedString("error_network", comment: ""))
                        return
                    }
                    let accountInfo = AccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithAccountInfo(account, accountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithAccountInfo(account, accountInfo))
                    self.onGenUnDelegateTx()
                    
                } else if (self.pageHolderVC.chainType! == ChainType.KAVA_MAIN || self.pageHolderVC.chainType! == ChainType.KAVA_TEST) {
                    guard let info = res as? [String : Any] else {
                        _ = BaseData.instance.deleteBalance(account: account)
                        self.hideWaittingAlert()
                        self.onShowToast(NSLocalizedString("error_network", comment: ""))
                        return
                    }
                    let accountInfo = KavaAccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithKavaAccountInfo(account, accountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithKavaAccountInfo(account, accountInfo))
                    self.onGenUnDelegateTx()
                    
                } else if (self.pageHolderVC.chainType! == ChainType.BAND_MAIN || self.pageHolderVC.chainType! == ChainType.IOV_MAIN || self.pageHolderVC.chainType! == ChainType.IOV_TEST || self.pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
                    guard let responseData = res as? NSDictionary,
                        let info = responseData.object(forKey: "result") as? [String : Any] else {
                            _ = BaseData.instance.deleteBalance(account: account)
                            self.hideWaittingAlert()
                            self.onShowToast(NSLocalizedString("error_network", comment: ""))
                            return
                    }
                    let accountInfo = AccountInfo.init(info)
                    _ = BaseData.instance.updateAccount(WUtils.getAccountWithAccountInfo(account, accountInfo))
                    BaseData.instance.updateBalances(account.account_id, WUtils.getBalancesWithAccountInfo(account, accountInfo))
                    self.onGenUnDelegateTx()
                    
                }
                
            case .failure( _):
                self.hideWaittingAlert()
                self.onShowToast(NSLocalizedString("error_network", comment: ""))
            }
        }
    }
    
    func onGenUnDelegateTx() {
        DispatchQueue.global().async {
            var stdTx:StdTx!
            guard let words = KeychainWrapper.standard.string(forKey: self.pageHolderVC.mAccount!.account_uuid.sha1())?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ") else {
                return
            }
            
            do {
                let pKey = WKey.getHDKeyFromWords(words, self.pageHolderVC.mAccount!)
                let msg = MsgGenerator.genUndelegateMsg(self.pageHolderVC.mAccount!.account_address,
                                                        self.pageHolderVC.mTargetValidator!.operator_address,
                                                        self.pageHolderVC.mToUndelegateAmount!,
                                                        self.pageHolderVC.chainType!)
                
                var msgList = Array<Msg>()
                msgList.append(msg)
                
                if (self.pageHolderVC.chainType! == ChainType.COSMOS_MAIN || self.pageHolderVC.chainType! == ChainType.KAVA_MAIN || self.pageHolderVC.chainType! == ChainType.KAVA_TEST ||
                    self.pageHolderVC.chainType! == ChainType.BAND_MAIN || self.pageHolderVC.chainType! == ChainType.IOV_MAIN || self.pageHolderVC.chainType! == ChainType.IOV_TEST || self.pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
                    let stdMsg = MsgGenerator.getToSignMsg(WUtils.getChainId(self.pageHolderVC.mAccount!.account_base_chain),
                                                           String(self.pageHolderVC.mAccount!.account_account_numner),
                                                           String(self.pageHolderVC.mAccount!.account_sequence_number),
                                                           msgList,
                                                           self.pageHolderVC.mFee!,
                                                           self.pageHolderVC.mMemo!)
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .sortedKeys
                    let data = try? encoder.encode(stdMsg)
                    let rawResult = String(data:data!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
                    let rawData: Data? = rawResult!.data(using: .utf8)
                    let hash = Crypto.sha256(rawData!)
                    
                    let signedData: Data? = try Crypto.sign(hash, privateKey: pKey.privateKey())
                    
                    var genedSignature = Signature.init()
                    var genPubkey =  PublicKey.init()
                    genPubkey.type = COSMOS_KEY_TYPE_PUBLIC
                    genPubkey.value = pKey.privateKey().publicKey().raw.base64EncodedString()
                    genedSignature.pub_key = genPubkey
                    genedSignature.signature = WKey.convertSignature(signedData!)
                    genedSignature.account_number = String(self.pageHolderVC.mAccount!.account_account_numner)
                    genedSignature.sequence = String(self.pageHolderVC.mAccount!.account_sequence_number)
                    
                    var signatures: Array<Signature> = Array<Signature>()
                    signatures.append(genedSignature)
                    
                    stdTx = MsgGenerator.genSignedTx(msgList, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, signatures)
                    
                } else if (self.pageHolderVC.chainType! == ChainType.IRIS_MAIN) {
                    let irisStdMsg = MsgGenerator.getIrisToSignMsg(WUtils.getChainId(self.pageHolderVC.mAccount!.account_base_chain),
                                                                   String(self.pageHolderVC.mAccount!.account_account_numner),
                                                                   String(self.pageHolderVC.mAccount!.account_sequence_number),
                                                                   msgList,
                                                                   self.pageHolderVC.mFee!,
                                                                   self.pageHolderVC.mMemo!)
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .sortedKeys
                    let data = try? encoder.encode(irisStdMsg)
                    let rawResult = String(data:data!, encoding:.utf8)?.replacingOccurrences(of: "\\/", with: "/")
                    let rawData: Data? = rawResult!.data(using: .utf8)
                    let hash = Crypto.sha256(rawData!)
                    let signedData: Data? = try Crypto.sign(hash, privateKey: pKey.privateKey())
                    
                    var genedSignature = Signature.init()
                    var genPubkey =  PublicKey.init()
                    genPubkey.type = COSMOS_KEY_TYPE_PUBLIC
                    genPubkey.value = pKey.privateKey().publicKey().raw.base64EncodedString()
                    genedSignature.pub_key = genPubkey
                    genedSignature.signature = WKey.convertSignature(signedData!)
                    genedSignature.account_number = String(self.pageHolderVC.mAccount!.account_account_numner)
                    genedSignature.sequence = String(self.pageHolderVC.mAccount!.account_sequence_number)
                    
                    var signatures: Array<Signature> = Array<Signature>()
                    signatures.append(genedSignature)
                    
                    stdTx = MsgGenerator.genSignedTx(msgList, self.pageHolderVC.mFee!, self.pageHolderVC.mMemo!, signatures)
                }
                
            } catch {
                if(SHOW_LOG) { print(error) }
            }
            
            DispatchQueue.main.async(execute: {
                let postTx = PostTx.init("sync", stdTx.value)
                let encoder = JSONEncoder()
                encoder.outputFormatting = .sortedKeys
                let data = try? encoder.encode(postTx)
                do {
                    let params = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                    var url: String?
                    if (self.pageHolderVC.chainType! == ChainType.COSMOS_MAIN) {
                        url = COSMOS_URL_BORAD_TX
                    } else if (self.pageHolderVC.chainType! == ChainType.IRIS_MAIN) {
                        url = IRIS_LCD_URL_BORAD_TX
                    } else if (self.pageHolderVC.chainType! == ChainType.KAVA_MAIN) {
                        url = KAVA_BORAD_TX
                    } else if (self.pageHolderVC.chainType! == ChainType.KAVA_TEST) {
                        url = KAVA_TEST_BORAD_TX
                    } else if (self.pageHolderVC.chainType! == ChainType.BAND_MAIN) {
                        url = BAND_BORAD_TX
                    } else if (self.pageHolderVC.chainType! == ChainType.IOV_MAIN) {
                        url = IOV_BORAD_TX
                    } else if (self.pageHolderVC.chainType! == ChainType.IOV_TEST) {
                        url = IOV_TEST_BORAD_TX
                    } else if (self.pageHolderVC.chainType! == ChainType.CERTIK_TEST) {
                        url = CERTIK_TEST_BORAD_TX
                    }
                    let request = Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:])
                    request.responseJSON { response in
                        var txResult = [String:Any]()
                        switch response.result {
                        case .success(let res):
                            if(SHOW_LOG) { print("Undelegate ", res) }
                            if let result = res as? [String : Any]  {
                                txResult = result
                            }
                        case .failure(let error):
                            if(SHOW_LOG) {
                                print("undelegate error ", error)
                            }
                            if (response.response?.statusCode == 500) {
                                txResult["net_error"] = 500
                            }
                            
                        }
                        if (self.waitAlert != nil) {
                            self.waitAlert?.dismiss(animated: true, completion: {
                                self.onStartTxDetail(txResult)
                            })
                        }
                    }

                } catch {
                    if(SHOW_LOG) { print(error) }
                }
            });
        }
    }
}
