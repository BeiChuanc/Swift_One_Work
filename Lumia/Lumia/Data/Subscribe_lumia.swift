import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Lumia: NSObject {
    
    /// 单例
    static let shared_Lumia = Subscribe_Lumia()
    
    // 是否VIP
    var isVIP_Lumia: Bool = false
    
    // 是否购买一次性商品
    var isPur_Lumia: Bool = false
    
    // 礼物商品列表
    var goodsList_Lumia: [StoreModel_Lumia] = [
        StoreModel_Lumia(
            id_Lumia: 1,
            goodsId_Lumia: "lumia.gift.4_9",
            goodsName_Lumia: "x1",
            goodsPrice_Lumia: "$4.99",
            goodIsTop_Lumia: true
        ),
        StoreModel_Lumia(
            id_Lumia: 2,
            goodsId_Lumia: "lumia.gift.x1.4_9",
            goodsName_Lumia: "x1",
            goodsPrice_Lumia: "$4.99",
        ),
        StoreModel_Lumia(
            id_Lumia: 3,
            goodsId_Lumia: "lumia.gift.x5.14_9",
            goodsName_Lumia: "x5",
            goodsPrice_Lumia: "$14.99",
        ),
        StoreModel_Lumia(
            id_Lumia: 4,
            goodsId_Lumia: "lumia.gift.x10.19_9",
            goodsName_Lumia: "x10",
            goodsPrice_Lumia: "$19.99",
        ),
        StoreModel_Lumia(
            id_Lumia: 5,
            goodsId_Lumia: "lumia.gift.x30.49_9",
            goodsName_Lumia: "x30",
            goodsPrice_Lumia: "$49.99",
        ),
        StoreModel_Lumia(
            id_Lumia: 6,
            goodsId_Lumia: "lumia.gift.x1.6_9",
            goodsName_Lumia: "x1",
            goodsPrice_Lumia: "$6.99",
        ),
        StoreModel_Lumia(
            id_Lumia: 7,
            goodsId_Lumia: "lumia.gift.x5.19_9",
            goodsName_Lumia: "x5",
            goodsPrice_Lumia: "$19.99",
        ),
        StoreModel_Lumia(
            id_Lumia: 8,
            goodsId_Lumia: "lumia.gift.x10.29_9",
            goodsName_Lumia: "x10",
            goodsPrice_Lumia: "$29.99",
        ),
        StoreModel_Lumia(
            id_Lumia: 9,
            goodsId_Lumia: "lumia.gift.x30.79_9",
            goodsName_Lumia: "x30",
            goodsPrice_Lumia: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Lumia(
            id_Lumia: 9,
            goodsId_Lumia: "lumia.vip.1w.9_9",
            goodsName_Lumia: "1 Week",
            goodsPrice_Lumia: "$9.99",
            goodIsVIP_Lumia: true
        ),
        StoreModel_Lumia(
            id_Lumia: 10,
            goodsId_Lumia: "lumia.vip.1m.19_9",
            goodsName_Lumia: "1 Month",
            goodsPrice_Lumia: "$19.99",
            goodIsVIP_Lumia: true
        ),
        StoreModel_Lumia(
            id_Lumia: 11,
            goodsId_Lumia: "lumia.vip.3m.29_9",
            goodsName_Lumia: "3 Months",
            goodsPrice_Lumia: "$29.99",
            goodIsVIP_Lumia: true
        ),
        StoreModel_Lumia(
            id_Lumia: 12,
            goodsId_Lumia: "lumia.vip.1y.69_9",
            goodsName_Lumia: "1 Year",
            goodsPrice_Lumia: "$69.99",
            goodIsVIP_Lumia: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Lumia {
    
    // 内购商品
    func PurchaseStoreGift_Lumia(gid_Lumia: String, completion_Lumia: @escaping() -> Void) {
        Utils_Lumia.showLoading_Lumia()
        
        let products: Set = [gid_Lumia]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Lumia) { SKPaymentTransaction in
                Utils_Lumia.dismissLoading_Lumia()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Lumia.showSuccess_Lumia(message_Lumia: "Payment successful")
                    
                    if (gid_Lumia.contains("lumia.gift.x5.3_9")) {
                        self.isPur_Lumia = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Lumia()
                }else{
                    print("取消支付")
                    Utils_Lumia.showError_Lumia(message_Lumia: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Lumia.showError_Lumia(message_Lumia: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Lumia.showError_Lumia(message_Lumia: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Lumia(vipId_Lumia: String, completion_Lumia: @escaping () -> Void) {
        Utils_Lumia.showLoading_Lumia()

        let products_Lumia: Set = [vipId_Lumia]
        RMStore.default().requestProducts(products_Lumia) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Lumia) { transaction_Lumia in
                Utils_Lumia.dismissLoading_Lumia()
                if transaction_Lumia?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Lumia.showSuccess_Lumia(message_Lumia: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Lumia()
                } else {
                    print("取消 VIP 支付")
                    Utils_Lumia.showError_Lumia(message_Lumia: "User cancels payment")
                }
            } failure: { transaction_Lumia, error_Lumia in
                print("VIP 商品信息无效")
                Utils_Lumia.showError_Lumia(message_Lumia: "Invalid product information")
            }
        } failure: { error_Lumia in
            print("VIP 商品信息无效")
            Utils_Lumia.showError_Lumia(message_Lumia: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Lumia(completion_Lumia: @escaping () -> Void) {
        Utils_Lumia.showLoading_Lumia()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Lumia in
            Utils_Lumia.dismissLoading_Lumia()
            if transactions_Lumia?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Lumia.showError_Lumia(message_Lumia: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Lumia.showSuccess_Lumia(message_Lumia: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Lumia()
            }
        }, failure: { error_Lumia in
            print("取消恢复购买")
            Utils_Lumia.showError_Lumia(message_Lumia: "Cancel restore purchase")
        })
    }
}
