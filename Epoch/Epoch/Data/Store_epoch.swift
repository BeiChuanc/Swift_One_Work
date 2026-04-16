import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Epoch: NSObject {
    
    /// 单例
    static let shared_Epoch = Store_Epoch()
    
    // 是否VIP
    var isVIP_Epoch: Bool = false
    
    // 是否购买一次性商品
    var isPur_Epoch: Bool = false
    
    // 礼物商品列表
    var goodsList_Epoch: [StoreModel_Epoch] = [
        StoreModel_Epoch(
            id_Epoch: 1,
            goodsId_Epoch: "tify.gift.4_9",
            goodsName_Epoch: "x1",
            goodsPrice_Epoch: "$4.99",
            goodIsTop_Epoch: true
        ),
        StoreModel_Epoch(
            id_Epoch: 2,
            goodsId_Epoch: "tify.gift.x1.4_9",
            goodsName_Epoch: "x1",
            goodsPrice_Epoch: "$4.99",
        ),
        StoreModel_Epoch(
            id_Epoch: 3,
            goodsId_Epoch: "tify.gift.x5.14_9",
            goodsName_Epoch: "x5",
            goodsPrice_Epoch: "$14.99",
        ),
        StoreModel_Epoch(
            id_Epoch: 4,
            goodsId_Epoch: "tify.gift.x10.19_9",
            goodsName_Epoch: "x10",
            goodsPrice_Epoch: "$19.99",
        ),
        StoreModel_Epoch(
            id_Epoch: 5,
            goodsId_Epoch: "tify.gift.x30.49_9",
            goodsName_Epoch: "x30",
            goodsPrice_Epoch: "$49.99",
        ),
        StoreModel_Epoch(
            id_Epoch: 6,
            goodsId_Epoch: "tify.gift.x1.6_9",
            goodsName_Epoch: "x1",
            goodsPrice_Epoch: "$6.99",
        ),
        StoreModel_Epoch(
            id_Epoch: 7,
            goodsId_Epoch: "tify.gift.x5.19_9",
            goodsName_Epoch: "x5",
            goodsPrice_Epoch: "$19.99",
        ),
        StoreModel_Epoch(
            id_Epoch: 8,
            goodsId_Epoch: "tify.gift.x10.29_9",
            goodsName_Epoch: "x10",
            goodsPrice_Epoch: "$29.99",
        ),
        StoreModel_Epoch(
            id_Epoch: 9,
            goodsId_Epoch: "tify.gift.x30.79_9",
            goodsName_Epoch: "x30",
            goodsPrice_Epoch: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Epoch(
            id_Epoch: 9,
            goodsId_Epoch: "tify.vip.1w.9_9",
            goodsName_Epoch: "One Week",
            goodsPrice_Epoch: "$9.99",
            goodIsVIP_Epoch: true
        ),
        StoreModel_Epoch(
            id_Epoch: 10,
            goodsId_Epoch: "tify.vip.1m.19_9",
            goodsName_Epoch: "One Months",
            goodsPrice_Epoch: "$19.99",
            goodIsVIP_Epoch: true
        ),
        StoreModel_Epoch(
            id_Epoch: 11,
            goodsId_Epoch: "tify.vip.3m.29_9",
            goodsName_Epoch: "Three Months",
            goodsPrice_Epoch: "$29.99",
            goodIsVIP_Epoch: true
        ),
        StoreModel_Epoch(
            id_Epoch: 12,
            goodsId_Epoch: "tify.vip.1y.69_9",
            goodsName_Epoch: "One Year",
            goodsPrice_Epoch: "$69.99",
            goodIsVIP_Epoch: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Epoch {
    
    // 内购商品
    func PurchaseStoreGift_Epoch(gid_Epoch: String, completion_Epoch: @escaping() -> Void) {
        Utils_Epoch.showLoading_Epoch()
        
        let products: Set = [gid_Epoch]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Epoch) { SKPaymentTransaction in
                Utils_Epoch.dismissLoading_Epoch()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Epoch.showSuccess_Epoch(message_Epoch: "Payment successful")
                    
                    if (gid_Epoch.contains("tify.gift.x5.3_9")) {
                        self.isPur_Epoch = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Epoch()
                }else{
                    print("取消支付")
                    Utils_Epoch.showError_Epoch(message_Epoch: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Epoch.showError_Epoch(message_Epoch: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Epoch.showError_Epoch(message_Epoch: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Epoch(vipId_Epoch: String, completion_Epoch: @escaping () -> Void) {
        Utils_Epoch.showLoading_Epoch()

        let products_Epoch: Set = [vipId_Epoch]
        RMStore.default().requestProducts(products_Epoch) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Epoch) { transaction_Epoch in
                Utils_Epoch.dismissLoading_Epoch()
                if transaction_Epoch?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Epoch.showSuccess_Epoch(message_Epoch: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Epoch()
                } else {
                    print("取消 VIP 支付")
                    Utils_Epoch.showError_Epoch(message_Epoch: "User cancels payment")
                }
            } failure: { transaction_Epoch, error_Epoch in
                print("VIP 商品信息无效")
                Utils_Epoch.showError_Epoch(message_Epoch: "Invalid product information")
            }
        } failure: { error_Epoch in
            print("VIP 商品信息无效")
            Utils_Epoch.showError_Epoch(message_Epoch: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Epoch(completion_Epoch: @escaping () -> Void) {
        Utils_Epoch.showLoading_Epoch()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Epoch in
            Utils_Epoch.dismissLoading_Epoch()
            if transactions_Epoch?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Epoch.showError_Epoch(message_Epoch: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Epoch.showSuccess_Epoch(message_Epoch: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Epoch()
            }
        }, failure: { error_Epoch in
            print("取消恢复购买")
            Utils_Epoch.showError_Epoch(message_Epoch: "Cancel restore purchase")
        })
    }
}
