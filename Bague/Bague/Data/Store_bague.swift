import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Bague: NSObject {
    
    /// 单例
    static let shared_Bague = Store_Bague()
    
    // 是否VIP
    var isVIP_Bague: Bool = false
    
    // 是否购买一次性商品
    var isPur_Bague: Bool = false
    
    // 礼物商品列表
    var goodsList_Bague: [StoreModel_Bague] = [
        
        // ------- 消耗 ------- //
        StoreModel_Bague(
            id_Bague: 1,
            goodsId_Bague: "bague.limit.3_9",
            goodsName_Bague: "x1",
            goodsPrice_Bague: "$3.99",
            goodIsTop_Bague: true
        ),
        StoreModel_Bague(
            id_Bague: 2,
            goodsId_Bague: "bague.limit.9_9",
            goodsName_Bague: "x5",
            goodsPrice_Bague: "$9.99",
            goodIsTop_Bague: true
        ),
        StoreModel_Bague(
            id_Bague: 3,
            goodsId_Bague: "bague.limit.14_9",
            goodsName_Bague: "x10",
            goodsPrice_Bague: "$14.99",
            goodIsTop_Bague: true
        ),

        StoreModel_Bague(
            id_Bague: 4,
            goodsId_Bague: "bague.gift.x1.4_9",
            goodsName_Bague: "x1",
            goodsPrice_Bague: "$4.99",
        ),
        StoreModel_Bague(
            id_Bague: 5,
            goodsId_Bague: "bague.gift.x5.14_9",
            goodsName_Bague: "x5",
            goodsPrice_Bague: "$14.99",
        ),
        StoreModel_Bague(
            id_Bague: 6,
            goodsId_Bague: "bague.gift.x10.29_9",
            goodsName_Bague: "x10",
            goodsPrice_Bague: "$29.99",
        ),
        StoreModel_Bague(
            id_Bague: 7,
            goodsId_Bague: "bague.gift.x30.49_9",
            goodsName_Bague: "x30",
            goodsPrice_Bague: "$49.99",
        ),
        StoreModel_Bague(
            id_Bague: 8,
            goodsId_Bague: "bague.gift.x1.5_9",
            goodsName_Bague: "x1",
            goodsPrice_Bague: "$5.99",
        ),
        StoreModel_Bague(
            id_Bague: 9,
            goodsId_Bague: "bague.gift.x5.19_9",
            goodsName_Bague: "x5",
            goodsPrice_Bague: "$19.99",
        ),
        StoreModel_Bague(
            id_Bague: 10,
            goodsId_Bague: "bague.gift.x10.39_9",
            goodsName_Bague: "x10",
            goodsPrice_Bague: "$39.99",
        ),
        StoreModel_Bague(
            id_Bague: 11,
            goodsId_Bague: "bague.gift.x30.59_9",
            goodsName_Bague: "x30",
            goodsPrice_Bague: "$59.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Bague(
            id_Bague: 12,
            goodsId_Bague: "bague.vip.1w.9_9",
            goodsName_Bague: "1 WEEK",
            goodsPrice_Bague: "$9.99",
            goodIsVIP_Bague: true
        ),
        StoreModel_Bague(
            id_Bague: 13,
            goodsId_Bague: "bague.vip.1m.24_9",
            goodsName_Bague: "1 MONTHS",
            goodsPrice_Bague: "$24.99",
            goodIsVIP_Bague: true
        ),
        StoreModel_Bague(
            id_Bague: 14,
            goodsId_Bague: "bague.vip.3m.49_9",
            goodsName_Bague: "3 MONTHS",
            goodsPrice_Bague: "$49.99",
            goodIsVIP_Bague: true
        ),
        StoreModel_Bague(
            id_Bague: 15,
            goodsId_Bague: "bague.vip.1y.69_9",
            goodsName_Bague: "6 MONTHS",
            goodsPrice_Bague: "$69.99",
            goodIsVIP_Bague: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Bague {
    
    // 内购商品
    func PurchaseStoreGift_Bague(gid_Bague: String, completion_Bague: @escaping() -> Void) {
        Utils_Bague.showLoading_Bague()
        
        let products: Set = [gid_Bague]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Bague) { SKPaymentTransaction in
                Utils_Bague.dismissLoading_Bague()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Bague.showSuccess_Bague(message_Bague: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Bague()
                }else{
                    print("取消支付")
                    Utils_Bague.showError_Bague(message_Bague: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Bague.showError_Bague(message_Bague: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Bague.showError_Bague(message_Bague: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Bague(vipId_Bague: String, completion_Bague: @escaping () -> Void) {
        Utils_Bague.showLoading_Bague()

        let products_Bague: Set = [vipId_Bague]
        RMStore.default().requestProducts(products_Bague) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Bague) { transaction_Bague in
                Utils_Bague.dismissLoading_Bague()
                if transaction_Bague?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Bague.showSuccess_Bague(message_Bague: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Bague()
                } else {
                    print("取消 VIP 支付")
                    Utils_Bague.showError_Bague(message_Bague: "User cancels payment")
                }
            } failure: { transaction_Bague, error_Bague in
                print("VIP 商品信息无效")
                Utils_Bague.showError_Bague(message_Bague: "Invalid product information")
            }
        } failure: { error_Bague in
            print("VIP 商品信息无效")
            Utils_Bague.showError_Bague(message_Bague: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Bague(completion_Bague: @escaping () -> Void) {
        Utils_Bague.showLoading_Bague()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Bague in
            Utils_Bague.dismissLoading_Bague()
            if transactions_Bague?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Bague.showError_Bague(message_Bague: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Bague.showSuccess_Bague(message_Bague: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Bague()
            }
        }, failure: { error_Bague in
            print("取消恢复购买")
            Utils_Bague.showError_Bague(message_Bague: "Cancel restore purchase")
        })
    }
}
