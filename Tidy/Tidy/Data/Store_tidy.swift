import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Tidy: NSObject {
    
    /// 单例
    static let shared_Tidy = Store_Tidy()
    
    // 是否VIP
    var isVIP_Tidy: Bool = false
    
    // 是否购买一次性商品
    var isPur_Tidy: Bool = false
    
    // 礼物商品列表
    var goodsList_Tidy: [StoreModel_Tidy] = [
        StoreModel_Tidy(
            id_Tidy: 1,
            goodsId_Tidy: "praise.gift.4_9",
            goodsName_Tidy: "x1",
            goodsPrice_Tidy: "$4.99",
            goodIsTop_Tidy: true
        ),
        StoreModel_Tidy(
            id_Tidy: 2,
            goodsId_Tidy: "praise.gift.x1.4_9",
            goodsName_Tidy: "x1",
            goodsPrice_Tidy: "$4.99",
        ),
        StoreModel_Tidy(
            id_Tidy: 3,
            goodsId_Tidy: "praise.gift.x5.14_9",
            goodsName_Tidy: "x5",
            goodsPrice_Tidy: "$14.99",
        ),
        StoreModel_Tidy(
            id_Tidy: 4,
            goodsId_Tidy: "praise.gift.x10.19_9",
            goodsName_Tidy: "x10",
            goodsPrice_Tidy: "$19.99",
        ),
        StoreModel_Tidy(
            id_Tidy: 5,
            goodsId_Tidy: "praise.gift.x30.49_9",
            goodsName_Tidy: "x30",
            goodsPrice_Tidy: "$49.99",
        ),
        StoreModel_Tidy(
            id_Tidy: 6,
            goodsId_Tidy: "praise.gift.x1.6_9",
            goodsName_Tidy: "x1",
            goodsPrice_Tidy: "$6.99",
        ),
        StoreModel_Tidy(
            id_Tidy: 7,
            goodsId_Tidy: "praise.gift.x5.19_9",
            goodsName_Tidy: "x5",
            goodsPrice_Tidy: "$19.99",
        ),
        StoreModel_Tidy(
            id_Tidy: 8,
            goodsId_Tidy: "praise.gift.x10.29_9",
            goodsName_Tidy: "x10",
            goodsPrice_Tidy: "$29.99",
        ),
        StoreModel_Tidy(
            id_Tidy: 9,
            goodsId_Tidy: "praise.gift.x30.79_9",
            goodsName_Tidy: "x30",
            goodsPrice_Tidy: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Tidy(
            id_Tidy: 9,
            goodsId_Tidy: "praise.sub.1w.9_9",
            goodsName_Tidy: "Premium (1w.)",
            goodsPrice_Tidy: "$9.99",
            goodIsVIP_Tidy: true
        ),
        StoreModel_Tidy(
            id_Tidy: 10,
            goodsId_Tidy: "praise.sub.1m.19_9",
            goodsName_Tidy: "Premium (1m.)",
            goodsPrice_Tidy: "$19.99",
            goodIsVIP_Tidy: true
        ),
        StoreModel_Tidy(
            id_Tidy: 11,
            goodsId_Tidy: "praise.sub.3m.29_9",
            goodsName_Tidy: "Premium (3m.)",
            goodsPrice_Tidy: "$29.99",
            goodIsVIP_Tidy: true
        ),
        StoreModel_Tidy(
            id_Tidy: 12,
            goodsId_Tidy: "praise.sub.1y.69_9",
            goodsName_Tidy: "Premium (1y.)",
            goodsPrice_Tidy: "$69.99",
            goodIsVIP_Tidy: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Tidy {
    
    // 内购商品
    func PurchaseStoreGift_Tidy(gid_Tidy: String, completion_Tidy: @escaping() -> Void) {
        Utils_Tidy.showLoading_Tidy()
        
        let products: Set = [gid_Tidy]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Tidy) { SKPaymentTransaction in
                Utils_Tidy.dismissLoading_Tidy()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Tidy.showSuccess_Tidy(message_Tidy: "Payment successful")
                    
                    if (gid_Tidy.contains("praise.gift.x5.3_9")) {
                        self.isPur_Tidy = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Tidy()
                }else{
                    print("取消支付")
                    Utils_Tidy.showError_Tidy(message_Tidy: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Tidy.showError_Tidy(message_Tidy: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Tidy.showError_Tidy(message_Tidy: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Tidy(vipId_Tidy: String, completion_Tidy: @escaping () -> Void) {
        Utils_Tidy.showLoading_Tidy()

        let products_Tidy: Set = [vipId_Tidy]
        RMStore.default().requestProducts(products_Tidy) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Tidy) { transaction_Tidy in
                Utils_Tidy.dismissLoading_Tidy()
                if transaction_Tidy?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Tidy.showSuccess_Tidy(message_Tidy: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Tidy()
                } else {
                    print("取消 VIP 支付")
                    Utils_Tidy.showError_Tidy(message_Tidy: "User cancels payment")
                }
            } failure: { transaction_Tidy, error_Tidy in
                print("VIP 商品信息无效")
                Utils_Tidy.showError_Tidy(message_Tidy: "Invalid product information")
            }
        } failure: { error_Tidy in
            print("VIP 商品信息无效")
            Utils_Tidy.showError_Tidy(message_Tidy: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Tidy(completion_Tidy: @escaping () -> Void) {
        Utils_Tidy.showLoading_Tidy()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Tidy in
            Utils_Tidy.dismissLoading_Tidy()
            if transactions_Tidy?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Tidy.showError_Tidy(message_Tidy: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Tidy.showSuccess_Tidy(message_Tidy: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Tidy()
            }
        }, failure: { error_Tidy in
            print("取消恢复购买")
            Utils_Tidy.showError_Tidy(message_Tidy: "Cancel restore purchase")
        })
    }
}
