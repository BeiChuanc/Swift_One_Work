import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Hush: NSObject {
    
    /// 单例
    static let shared_Hush = Subscribe_Hush()
    
    // 是否VIP
    var isVIP_Hush: Bool = false
    
    // 是否购买一次性商品
    var isPur_Hush: Bool = false
    
    // 礼物商品列表
    var goodsList_Hush: [StoreModel_Hush] = [
        StoreModel_Hush(
            id_Hush: 1,
            goodsId_Hush: "hush.gift.4_9",
            goodsName_Hush: "x1",
            goodsPrice_Hush: "$4.99",
            goodIsTop_Hush: true
        ),
        StoreModel_Hush(
            id_Hush: 2,
            goodsId_Hush: "hush.gift.x1.4_9",
            goodsName_Hush: "x1",
            goodsPrice_Hush: "$4.99",
        ),
        StoreModel_Hush(
            id_Hush: 3,
            goodsId_Hush: "hush.gift.x5.14_9",
            goodsName_Hush: "x5",
            goodsPrice_Hush: "$14.99",
        ),
        StoreModel_Hush(
            id_Hush: 4,
            goodsId_Hush: "hush.gift.x10.19_9",
            goodsName_Hush: "x10",
            goodsPrice_Hush: "$19.99",
        ),
        StoreModel_Hush(
            id_Hush: 5,
            goodsId_Hush: "hush.gift.x30.49_9",
            goodsName_Hush: "x30",
            goodsPrice_Hush: "$49.99",
        ),
        StoreModel_Hush(
            id_Hush: 6,
            goodsId_Hush: "hush.gift.x1.6_9",
            goodsName_Hush: "x1",
            goodsPrice_Hush: "$6.99",
        ),
        StoreModel_Hush(
            id_Hush: 7,
            goodsId_Hush: "hush.gift.x5.19_9",
            goodsName_Hush: "x5",
            goodsPrice_Hush: "$19.99",
        ),
        StoreModel_Hush(
            id_Hush: 8,
            goodsId_Hush: "hush.gift.x10.29_9",
            goodsName_Hush: "x10",
            goodsPrice_Hush: "$29.99",
        ),
        StoreModel_Hush(
            id_Hush: 9,
            goodsId_Hush: "hush.gift.x30.79_9",
            goodsName_Hush: "x30",
            goodsPrice_Hush: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Hush(
            id_Hush: 9,
            goodsId_Hush: "hush.vip.1w.9_9",
            goodsName_Hush: "Premium (1w.)",
            goodsPrice_Hush: "$9.99/w",
            goodIsVIP_Hush: true
        ),
        StoreModel_Hush(
            id_Hush: 10,
            goodsId_Hush: "hush.vip.1m.19_9",
            goodsName_Hush: "Premium (1m.)",
            goodsPrice_Hush: "$19.99/m",
            goodIsVIP_Hush: true
        ),
        StoreModel_Hush(
            id_Hush: 11,
            goodsId_Hush: "hush.vip.3m.29_9",
            goodsName_Hush: "Premium (3m.)",
            goodsPrice_Hush: "$29.99/m",
            goodIsVIP_Hush: true
        ),
        StoreModel_Hush(
            id_Hush: 12,
            goodsId_Hush: "hush.vip.1y.69_9",
            goodsName_Hush: "Premium (1y.)",
            goodsPrice_Hush: "$69.99/y",
            goodIsVIP_Hush: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Hush {
    
    // 内购商品
    func PurchaseStoreGift_Hush(gid_Hush: String, completion_Hush: @escaping() -> Void) {
        Utils_Hush.showLoading_Hush()
        
        let products: Set = [gid_Hush]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Hush) { SKPaymentTransaction in
                Utils_Hush.dismissLoading_Hush()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Hush.showSuccess_Hush(message_Hush: "Payment successful")
                    
                    if (gid_Hush.contains("hush.gift.x5.3_9")) {
                        self.isPur_Hush = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Hush()
                }else{
                    print("取消支付")
                    Utils_Hush.showError_Hush(message_Hush: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Hush.showError_Hush(message_Hush: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Hush.showError_Hush(message_Hush: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Hush(vipId_Hush: String, completion_Hush: @escaping () -> Void) {
        Utils_Hush.showLoading_Hush()

        let products_Hush: Set = [vipId_Hush]
        RMStore.default().requestProducts(products_Hush) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Hush) { transaction_Hush in
                Utils_Hush.dismissLoading_Hush()
                if transaction_Hush?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Hush.showSuccess_Hush(message_Hush: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Hush()
                } else {
                    print("取消 VIP 支付")
                    Utils_Hush.showError_Hush(message_Hush: "User cancels payment")
                }
            } failure: { transaction_Hush, error_Hush in
                print("VIP 商品信息无效")
                Utils_Hush.showError_Hush(message_Hush: "Invalid product information")
            }
        } failure: { error_Hush in
            print("VIP 商品信息无效")
            Utils_Hush.showError_Hush(message_Hush: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Hush(completion_Hush: @escaping () -> Void) {
        Utils_Hush.showLoading_Hush()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Hush in
            Utils_Hush.dismissLoading_Hush()
            if transactions_Hush?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Hush.showError_Hush(message_Hush: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Hush.showSuccess_Hush(message_Hush: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Hush()
            }
        }, failure: { error_Hush in
            print("取消恢复购买")
            Utils_Hush.showError_Hush(message_Hush: "Cancel restore purchase")
        })
    }
}
