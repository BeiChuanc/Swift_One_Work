import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Ornit: NSObject {
    
    /// 单例
    static let shared_Ornit = Subscribe_Ornit()
    
    // 是否VIP
    var isVIP_Ornit: Bool = false
    
    // 是否购买一次性商品
    var isPur_Ornit: Bool = false
    
    // 礼物商品列表
    var goodsList_Ornit: [StoreModel_Ornit] = [
        StoreModel_Ornit(
            id_Ornit: 0,
            goodsId_Ornit: "ornit.gift.spe.1_9",
            goodsName_Ornit: "x1",
            goodsPrice_Ornit: "$1.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: true
        ),
        StoreModel_Ornit(
            id_Ornit: 1,
            goodsId_Ornit: "ornit.gift.spe.3_9",
            goodsName_Ornit: "x1",
            goodsPrice_Ornit: "$3.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: true
        ),
        StoreModel_Ornit(
            id_Ornit: 2,
            goodsId_Ornit: "ornit.gift.spe.4_9",
            goodsName_Ornit: "x1",
            goodsPrice_Ornit: "$4.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: true
        ),
        StoreModel_Ornit(
            id_Ornit: 3,
            goodsId_Ornit: "ornit.gift.x1.1_9",
            goodsName_Ornit: "x1",
            goodsPrice_Ornit: "$1.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 4,
            goodsId_Ornit: "ornit.gift.x5.2_9",
            goodsName_Ornit: "x5",
            goodsPrice_Ornit: "$2.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 5,
            goodsId_Ornit: "ornit.gift.x10.3_9",
            goodsName_Ornit: "x10",
            goodsPrice_Ornit: "$3.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 6,
            goodsId_Ornit: "ornit.gift.x30.4_9",
            goodsName_Ornit: "x30",
            goodsPrice_Ornit: "$4.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 7,
            goodsId_Ornit: "ornit.gift.x1.6_9",
            goodsName_Ornit: "x1",
            goodsPrice_Ornit: "$6.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 8,
            goodsId_Ornit: "ornit.gift.x5.9_9",
            goodsName_Ornit: "x5",
            goodsPrice_Ornit: "$9.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 9,
            goodsId_Ornit: "ornit.gift.x10.19_9",
            goodsName_Ornit: "x10",
            goodsPrice_Ornit: "$19.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 10,
            goodsId_Ornit: "ornit.gift.x30.29_9",
            goodsName_Ornit: "x30",
            goodsPrice_Ornit: "$29.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 11,
            goodsId_Ornit: "ornit.gift.x1.49_9",
            goodsName_Ornit: "x1",
            goodsPrice_Ornit: "$49.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 12,
            goodsId_Ornit: "ornit.gift.x5.69_9",
            goodsName_Ornit: "x5",
            goodsPrice_Ornit: "$69.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        StoreModel_Ornit(
            id_Ornit: 13,
            goodsId_Ornit: "ornit.gift.x10.99_9",
            goodsName_Ornit: "x10",
            goodsPrice_Ornit: "$99.99",
            goodIsTop_Ornit: false,
            goodIsLimit_Ornit: false
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Ornit(
            id_Ornit: 9,
            goodsId_Ornit: "ornit.sub.1w.6_9",
            goodsName_Ornit: "1 Week",
            goodsPrice_Ornit: "$6.99",
            goodIsVIP_Ornit: true
        ),
        StoreModel_Ornit(
            id_Ornit: 10,
            goodsId_Ornit: "ornit.sub.1m.14_9",
            goodsName_Ornit: "1 Month",
            goodsPrice_Ornit: "$14.99",
            goodIsVIP_Ornit: true
        ),
        StoreModel_Ornit(
            id_Ornit: 11,
            goodsId_Ornit: "ornit.sub.3m.39_9",
            goodsName_Ornit: "3 Months",
            goodsPrice_Ornit: "$39.99",
            goodIsVIP_Ornit: true
        ),
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Ornit {
    
    // 内购商品
    func PurchaseStoreGift_Ornit(gid_Ornit: String, completion_Ornit: @escaping() -> Void) {
        Utils_Ornit.showLoading_Ornit()
        
        let products: Set = [gid_Ornit]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Ornit) { SKPaymentTransaction in
                Utils_Ornit.dismissLoading_Ornit()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Ornit.showSuccess_Ornit(message_Ornit: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Ornit()
                }else{
                    print("取消支付")
                    Utils_Ornit.showError_Ornit(message_Ornit: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Ornit.showError_Ornit(message_Ornit: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Ornit.showError_Ornit(message_Ornit: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Ornit(vipId_Ornit: String, completion_Ornit: @escaping () -> Void) {
        Utils_Ornit.showLoading_Ornit()

        let products_Ornit: Set = [vipId_Ornit]
        RMStore.default().requestProducts(products_Ornit) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Ornit) { transaction_Ornit in
                Utils_Ornit.dismissLoading_Ornit()
                if transaction_Ornit?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Ornit.showSuccess_Ornit(message_Ornit: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Ornit()
                } else {
                    print("取消 VIP 支付")
                    Utils_Ornit.showError_Ornit(message_Ornit: "User cancels payment")
                }
            } failure: { transaction_Ornit, error_Ornit in
                print("VIP 商品信息无效")
                Utils_Ornit.showError_Ornit(message_Ornit: "Invalid product information")
            }
        } failure: { error_Ornit in
            print("VIP 商品信息无效")
            Utils_Ornit.showError_Ornit(message_Ornit: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Ornit(completion_Ornit: @escaping () -> Void) {
        Utils_Ornit.showLoading_Ornit()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Ornit in
            Utils_Ornit.dismissLoading_Ornit()
            if transactions_Ornit?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Ornit.showError_Ornit(message_Ornit: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Ornit.showSuccess_Ornit(message_Ornit: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Ornit()
            }
        }, failure: { error_Ornit in
            print("取消恢复购买")
            Utils_Ornit.showError_Ornit(message_Ornit: "Cancel restore purchase")
        })
    }
}
