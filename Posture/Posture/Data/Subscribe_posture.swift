import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Posture: NSObject {
    
    /// 单例
    static let shared_Posture = Subscribe_Posture()
    
    // 是否VIP
    var isVIP_Posture: Bool = false
    
    // 是否购买一次性商品
    var isPur_Posture: Bool = false
    
    // 礼物商品列表
    var goodsList_Posture: [StoreModel_Posture] = [
        StoreModel_Posture(
            id_Posture: 1,
            goodsId_Posture: "praise.gift.4_9",
            goodsName_Posture: "x1",
            goodsPrice_Posture: "$4.99",
            goodIsTop_Posture: true
        ),
        StoreModel_Posture(
            id_Posture: 2,
            goodsId_Posture: "praise.gift.x1.4_9",
            goodsName_Posture: "x1",
            goodsPrice_Posture: "$4.99",
        ),
        StoreModel_Posture(
            id_Posture: 3,
            goodsId_Posture: "praise.gift.x5.14_9",
            goodsName_Posture: "x5",
            goodsPrice_Posture: "$14.99",
        ),
        StoreModel_Posture(
            id_Posture: 4,
            goodsId_Posture: "praise.gift.x10.19_9",
            goodsName_Posture: "x10",
            goodsPrice_Posture: "$19.99",
        ),
        StoreModel_Posture(
            id_Posture: 5,
            goodsId_Posture: "praise.gift.x30.49_9",
            goodsName_Posture: "x30",
            goodsPrice_Posture: "$49.99",
        ),
        StoreModel_Posture(
            id_Posture: 6,
            goodsId_Posture: "praise.gift.x1.6_9",
            goodsName_Posture: "x1",
            goodsPrice_Posture: "$6.99",
        ),
        StoreModel_Posture(
            id_Posture: 7,
            goodsId_Posture: "praise.gift.x5.19_9",
            goodsName_Posture: "x5",
            goodsPrice_Posture: "$19.99",
        ),
        StoreModel_Posture(
            id_Posture: 8,
            goodsId_Posture: "praise.gift.x10.29_9",
            goodsName_Posture: "x10",
            goodsPrice_Posture: "$29.99",
        ),
        StoreModel_Posture(
            id_Posture: 9,
            goodsId_Posture: "praise.gift.x30.79_9",
            goodsName_Posture: "x30",
            goodsPrice_Posture: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Posture(
            id_Posture: 9,
            goodsId_Posture: "praise.sub.1w.9_9",
            goodsName_Posture: "Premium (1w.)",
            goodsPrice_Posture: "$9.99",
            goodIsVIP_Posture: true
        ),
        StoreModel_Posture(
            id_Posture: 10,
            goodsId_Posture: "praise.sub.1m.19_9",
            goodsName_Posture: "Premium (1m.)",
            goodsPrice_Posture: "$19.99",
            goodIsVIP_Posture: true
        ),
        StoreModel_Posture(
            id_Posture: 11,
            goodsId_Posture: "praise.sub.3m.29_9",
            goodsName_Posture: "Premium (3m.)",
            goodsPrice_Posture: "$29.99",
            goodIsVIP_Posture: true
        ),
        StoreModel_Posture(
            id_Posture: 12,
            goodsId_Posture: "praise.sub.1y.69_9",
            goodsName_Posture: "Premium (1y.)",
            goodsPrice_Posture: "$69.99",
            goodIsVIP_Posture: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Posture {
    
    // 内购商品
    func PurchaseStoreGift_Posture(gid_Posture: String, completion_Posture: @escaping() -> Void) {
        Utils_Posture.showLoading_Posture()
        
        let products: Set = [gid_Posture]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Posture) { SKPaymentTransaction in
                Utils_Posture.dismissLoading_Posture()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Posture.showSuccess_Posture(message_Posture: "Payment successful")
                    
                    if (gid_Posture.contains("praise.gift.x5.3_9")) {
                        self.isPur_Posture = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Posture()
                }else{
                    print("取消支付")
                    Utils_Posture.showError_Posture(message_Posture: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Posture.showError_Posture(message_Posture: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Posture.showError_Posture(message_Posture: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Posture(vipId_Posture: String, completion_Posture: @escaping () -> Void) {
        Utils_Posture.showLoading_Posture()

        let products_Posture: Set = [vipId_Posture]
        RMStore.default().requestProducts(products_Posture) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Posture) { transaction_Posture in
                Utils_Posture.dismissLoading_Posture()
                if transaction_Posture?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Posture.showSuccess_Posture(message_Posture: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Posture()
                } else {
                    print("取消 VIP 支付")
                    Utils_Posture.showError_Posture(message_Posture: "User cancels payment")
                }
            } failure: { transaction_Posture, error_Posture in
                print("VIP 商品信息无效")
                Utils_Posture.showError_Posture(message_Posture: "Invalid product information")
            }
        } failure: { error_Posture in
            print("VIP 商品信息无效")
            Utils_Posture.showError_Posture(message_Posture: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Posture(completion_Posture: @escaping () -> Void) {
        Utils_Posture.showLoading_Posture()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Posture in
            Utils_Posture.dismissLoading_Posture()
            if transactions_Posture?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Posture.showError_Posture(message_Posture: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Posture.showSuccess_Posture(message_Posture: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Posture()
            }
        }, failure: { error_Posture in
            print("取消恢复购买")
            Utils_Posture.showError_Posture(message_Posture: "Cancel restore purchase")
        })
    }
}
