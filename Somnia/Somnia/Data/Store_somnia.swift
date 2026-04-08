import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Somnia: NSObject {
    
    /// 单例
    static let shared_Somnia = Store_Somnia()
    
    // 是否VIP
    var isVIP_Somnia: Bool = false
    
    // 是否购买一次性商品
    var isPur_Somnia: Bool = false
    
    // 礼物商品列表
    var goodsList_Somnia: [StoreModel_Somnia] = [
        StoreModel_Somnia(
            id_Somnia: 1,
            goodsId_Somnia: "tify.gift.4_9",
            goodsName_Somnia: "x1",
            goodsPrice_Somnia: "$4.99",
            goodIsTop_Somnia: true
        ),
        StoreModel_Somnia(
            id_Somnia: 2,
            goodsId_Somnia: "tify.gift.x1.4_9",
            goodsName_Somnia: "x1",
            goodsPrice_Somnia: "$4.99",
        ),
        StoreModel_Somnia(
            id_Somnia: 3,
            goodsId_Somnia: "tify.gift.x5.14_9",
            goodsName_Somnia: "x5",
            goodsPrice_Somnia: "$14.99",
        ),
        StoreModel_Somnia(
            id_Somnia: 4,
            goodsId_Somnia: "tify.gift.x10.19_9",
            goodsName_Somnia: "x10",
            goodsPrice_Somnia: "$19.99",
        ),
        StoreModel_Somnia(
            id_Somnia: 5,
            goodsId_Somnia: "tify.gift.x30.49_9",
            goodsName_Somnia: "x30",
            goodsPrice_Somnia: "$49.99",
        ),
        StoreModel_Somnia(
            id_Somnia: 6,
            goodsId_Somnia: "tify.gift.x1.6_9",
            goodsName_Somnia: "x1",
            goodsPrice_Somnia: "$6.99",
        ),
        StoreModel_Somnia(
            id_Somnia: 7,
            goodsId_Somnia: "tify.gift.x5.19_9",
            goodsName_Somnia: "x5",
            goodsPrice_Somnia: "$19.99",
        ),
        StoreModel_Somnia(
            id_Somnia: 8,
            goodsId_Somnia: "tify.gift.x10.29_9",
            goodsName_Somnia: "x10",
            goodsPrice_Somnia: "$29.99",
        ),
        StoreModel_Somnia(
            id_Somnia: 9,
            goodsId_Somnia: "tify.gift.x30.79_9",
            goodsName_Somnia: "x30",
            goodsPrice_Somnia: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Somnia(
            id_Somnia: 9,
            goodsId_Somnia: "tify.vip.1w.9_9",
            goodsName_Somnia: "Week",
            goodsPrice_Somnia: "$9.99",
            goodIsVIP_Somnia: true
        ),
        StoreModel_Somnia(
            id_Somnia: 10,
            goodsId_Somnia: "tify.vip.1m.19_9",
            goodsName_Somnia: "Month",
            goodsPrice_Somnia: "$19.99",
            goodIsVIP_Somnia: true
        ),
        StoreModel_Somnia(
            id_Somnia: 11,
            goodsId_Somnia: "tify.vip.3m.29_9",
            goodsName_Somnia: "Months",
            goodsPrice_Somnia: "$29.99",
            goodIsVIP_Somnia: true
        ),
        StoreModel_Somnia(
            id_Somnia: 12,
            goodsId_Somnia: "tify.vip.1y.69_9",
            goodsName_Somnia: "Year",
            goodsPrice_Somnia: "$69.99",
            goodIsVIP_Somnia: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Somnia {
    
    // 内购商品
    func PurchaseStoreGift_Somnia(gid_Somnia: String, completion_Somnia: @escaping() -> Void) {
        Utils_Somnia.showLoading_Somnia()
        
        let products: Set = [gid_Somnia]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Somnia) { SKPaymentTransaction in
                Utils_Somnia.dismissLoading_Somnia()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Somnia.showSuccess_Somnia(message_Somnia: "Payment successful")
                    
                    if (gid_Somnia.contains("tify.gift.x5.3_9")) {
                        self.isPur_Somnia = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Somnia()
                }else{
                    print("取消支付")
                    Utils_Somnia.showError_Somnia(message_Somnia: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Somnia.showError_Somnia(message_Somnia: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Somnia.showError_Somnia(message_Somnia: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Somnia(vipId_Somnia: String, completion_Somnia: @escaping () -> Void) {
        Utils_Somnia.showLoading_Somnia()

        let products_Somnia: Set = [vipId_Somnia]
        RMStore.default().requestProducts(products_Somnia) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Somnia) { transaction_Somnia in
                Utils_Somnia.dismissLoading_Somnia()
                if transaction_Somnia?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Somnia.showSuccess_Somnia(message_Somnia: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Somnia()
                } else {
                    print("取消 VIP 支付")
                    Utils_Somnia.showError_Somnia(message_Somnia: "User cancels payment")
                }
            } failure: { transaction_Somnia, error_Somnia in
                print("VIP 商品信息无效")
                Utils_Somnia.showError_Somnia(message_Somnia: "Invalid product information")
            }
        } failure: { error_Somnia in
            print("VIP 商品信息无效")
            Utils_Somnia.showError_Somnia(message_Somnia: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Somnia(completion_Somnia: @escaping () -> Void) {
        Utils_Somnia.showLoading_Somnia()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Somnia in
            Utils_Somnia.dismissLoading_Somnia()
            if transactions_Somnia?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Somnia.showError_Somnia(message_Somnia: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Somnia.showSuccess_Somnia(message_Somnia: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Somnia()
            }
        }, failure: { error_Somnia in
            print("取消恢复购买")
            Utils_Somnia.showError_Somnia(message_Somnia: "Cancel restore purchase")
        })
    }
}
