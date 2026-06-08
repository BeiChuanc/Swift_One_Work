import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Echd: NSObject {
    
    /// 单例
    static let shared_Echd = Store_Echd()
    
    // 是否VIP
    var isVIP_Echd: Bool = false
    
    // 是否购买一次性商品
    var isPur_Echd: Bool = false
    
    // 礼物商品列表
    var goodsList_Echd: [StoreModel_Echd] = [
        
        // ------- 消耗 ------- //
        StoreModel_Echd(
            id_Echd: 1,
            goodsId_Echd: "echd.limit.3_9",
            goodsName_Echd: "x1",
            goodsPrice_Echd: "$3.99",
            goodIsTop_Echd: true
        ),
        StoreModel_Echd(
            id_Echd: 2,
            goodsId_Echd: "echd.limit.9_9",
            goodsName_Echd: "x5",
            goodsPrice_Echd: "$9.99",
            goodIsTop_Echd: true
        ),
        StoreModel_Echd(
            id_Echd: 3,
            goodsId_Echd: "echd.limit.14_9",
            goodsName_Echd: "x10",
            goodsPrice_Echd: "$14.99",
            goodIsTop_Echd: true
        ),

        StoreModel_Echd(
            id_Echd: 4,
            goodsId_Echd: "echd.gift.x1.4_9",
            goodsName_Echd: "x1",
            goodsPrice_Echd: "$4.99",
        ),
        StoreModel_Echd(
            id_Echd: 5,
            goodsId_Echd: "echd.gift.x5.14_9",
            goodsName_Echd: "x5",
            goodsPrice_Echd: "$14.99",
        ),
        StoreModel_Echd(
            id_Echd: 6,
            goodsId_Echd: "echd.gift.x10.29_9",
            goodsName_Echd: "x10",
            goodsPrice_Echd: "$29.99",
        ),
        StoreModel_Echd(
            id_Echd: 7,
            goodsId_Echd: "echd.gift.x30.49_9",
            goodsName_Echd: "x30",
            goodsPrice_Echd: "$49.99",
        ),
        StoreModel_Echd(
            id_Echd: 8,
            goodsId_Echd: "echd.gift.x1.5_9",
            goodsName_Echd: "x1",
            goodsPrice_Echd: "$5.99",
        ),
        StoreModel_Echd(
            id_Echd: 9,
            goodsId_Echd: "echd.gift.x5.19_9",
            goodsName_Echd: "x5",
            goodsPrice_Echd: "$19.99",
        ),
        StoreModel_Echd(
            id_Echd: 10,
            goodsId_Echd: "echd.gift.x10.39_9",
            goodsName_Echd: "x10",
            goodsPrice_Echd: "$39.99",
        ),
        StoreModel_Echd(
            id_Echd: 11,
            goodsId_Echd: "echd.gift.x30.59_9",
            goodsName_Echd: "x30",
            goodsPrice_Echd: "$59.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Echd(
            id_Echd: 12,
            goodsId_Echd: "echd.vip.1w.9_9",
            goodsName_Echd: "One Week",
            goodsPrice_Echd: "9.99",
            goodIsVIP_Echd: true
        ),
        StoreModel_Echd(
            id_Echd: 13,
            goodsId_Echd: "echd.vip.1m.24_9",
            goodsName_Echd: "One Month",
            goodsPrice_Echd: "24.99",
            goodIsVIP_Echd: true
        ),
        StoreModel_Echd(
            id_Echd: 14,
            goodsId_Echd: "echd.vip.3m.49_9",
            goodsName_Echd: "Three Months",
            goodsPrice_Echd: "49.99",
            goodIsVIP_Echd: true
        ),
        StoreModel_Echd(
            id_Echd: 15,
            goodsId_Echd: "echd.vip.1y.69_9",
            goodsName_Echd: "One Year",
            goodsPrice_Echd: "69.99",
            goodIsVIP_Echd: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Echd {
    
    // 内购商品
    func PurchaseStoreGift_Echd(gid_Echd: String, completion_Echd: @escaping() -> Void) {
        Utils_Echd.showLoading_Echd()
        
        let products: Set = [gid_Echd]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Echd) { SKPaymentTransaction in
                Utils_Echd.dismissLoading_Echd()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Echd.showSuccess_Echd(message_Echd: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Echd()
                }else{
                    print("取消支付")
                    Utils_Echd.showError_Echd(message_Echd: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Echd.showError_Echd(message_Echd: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Echd.showError_Echd(message_Echd: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Echd(vipId_Echd: String, completion_Echd: @escaping () -> Void) {
        Utils_Echd.showLoading_Echd()

        let products_Echd: Set = [vipId_Echd]
        RMStore.default().requestProducts(products_Echd) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Echd) { transaction_Echd in
                Utils_Echd.dismissLoading_Echd()
                if transaction_Echd?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Echd.showSuccess_Echd(message_Echd: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Echd()
                } else {
                    print("取消 VIP 支付")
                    Utils_Echd.showError_Echd(message_Echd: "User cancels payment")
                }
            } failure: { transaction_Echd, error_Echd in
                print("VIP 商品信息无效")
                Utils_Echd.showError_Echd(message_Echd: "Invalid product information")
            }
        } failure: { error_Echd in
            print("VIP 商品信息无效")
            Utils_Echd.showError_Echd(message_Echd: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Echd(completion_Echd: @escaping () -> Void) {
        Utils_Echd.showLoading_Echd()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Echd in
            Utils_Echd.dismissLoading_Echd()
            if transactions_Echd?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Echd.showError_Echd(message_Echd: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Echd.showSuccess_Echd(message_Echd: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Echd()
            }
        }, failure: { error_Echd in
            print("取消恢复购买")
            Utils_Echd.showError_Echd(message_Echd: "Cancel restore purchase")
        })
    }
}
