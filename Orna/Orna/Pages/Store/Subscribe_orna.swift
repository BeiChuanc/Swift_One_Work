import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Orna: NSObject {
    
    /// 单例
    static let shared_Orna = Subscribe_Orna()
    
    // 是否VIP
    var isVIP_Orna: Bool = false
    
    // 是否购买一次性商品
    var isPur_Orna: Bool = false
    
    // 礼物商品列表
    var goodsList_Orna: [StoreModel_Orna] = [
        StoreModel_Orna(
            id_Orna: 1,
            goodsId_Orna: "praise.gift.4_9",
            goodsName_Orna: "x1",
            goodsPrice_Orna: "$4.99",
            goodIsTop_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 2,
            goodsId_Orna: "praise.gift.x1.4_9",
            goodsName_Orna: "x1",
            goodsPrice_Orna: "$4.99",
        ),
        StoreModel_Orna(
            id_Orna: 3,
            goodsId_Orna: "praise.gift.x5.14_9",
            goodsName_Orna: "x5",
            goodsPrice_Orna: "$14.99",
        ),
        StoreModel_Orna(
            id_Orna: 4,
            goodsId_Orna: "praise.gift.x10.19_9",
            goodsName_Orna: "x10",
            goodsPrice_Orna: "$19.99",
        ),
        StoreModel_Orna(
            id_Orna: 5,
            goodsId_Orna: "praise.gift.x30.49_9",
            goodsName_Orna: "x30",
            goodsPrice_Orna: "$49.99",
        ),
        StoreModel_Orna(
            id_Orna: 6,
            goodsId_Orna: "praise.gift.x1.6_9",
            goodsName_Orna: "x1",
            goodsPrice_Orna: "$6.99",
        ),
        StoreModel_Orna(
            id_Orna: 7,
            goodsId_Orna: "praise.gift.x5.19_9",
            goodsName_Orna: "x5",
            goodsPrice_Orna: "$19.99",
        ),
        StoreModel_Orna(
            id_Orna: 8,
            goodsId_Orna: "praise.gift.x10.29_9",
            goodsName_Orna: "x10",
            goodsPrice_Orna: "$29.99",
        ),
        StoreModel_Orna(
            id_Orna: 9,
            goodsId_Orna: "praise.gift.x30.79_9",
            goodsName_Orna: "x30",
            goodsPrice_Orna: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Orna(
            id_Orna: 9,
            goodsId_Orna: "praise.sub.1w.9_9",
            goodsName_Orna: "Premium (1w.)",
            goodsPrice_Orna: "$9.99",
            goodIsVIP_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 10,
            goodsId_Orna: "praise.sub.1m.19_9",
            goodsName_Orna: "Premium (1m.)",
            goodsPrice_Orna: "$19.99",
            goodIsVIP_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 11,
            goodsId_Orna: "praise.sub.3m.29_9",
            goodsName_Orna: "Premium (3m.)",
            goodsPrice_Orna: "$29.99",
            goodIsVIP_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 12,
            goodsId_Orna: "praise.sub.1y.69_9",
            goodsName_Orna: "Premium (1y.)",
            goodsPrice_Orna: "$69.99",
            goodIsVIP_Orna: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Orna {
    
    // 内购商品
    func PurchaseStoreGift_Orna(gid_Orna: String, completion_Orna: @escaping() -> Void) {
        Load_Orna.showLoading_Orna()
        
        let products: Set = [gid_Orna]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Orna) { SKPaymentTransaction in
                Load_Orna.dismissLoading_Orna()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Load_Orna.showSuccess_Orna(message_Orna: "Payment successful")
                    
                    if (gid_Orna.contains("praise.gift.x5.3_9")) {
                        self.isPur_Orna = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Orna()
                }else{
                    print("取消支付")
                    Load_Orna.showError_Orna(message_Orna: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Load_Orna.showError_Orna(message_Orna: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Load_Orna.showError_Orna(message_Orna: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Orna(vipId_Orna: String, completion_Orna: @escaping () -> Void) {
        Load_Orna.showLoading_Orna()

        let products_Orna: Set = [vipId_Orna]
        RMStore.default().requestProducts(products_Orna) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Orna) { transaction_Orna in
                Load_Orna.dismissLoading_Orna()
                if transaction_Orna?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Load_Orna.showSuccess_Orna(message_Orna: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Orna()
                } else {
                    print("取消 VIP 支付")
                    Load_Orna.showError_Orna(message_Orna: "User cancels payment")
                }
            } failure: { transaction_Orna, error_Orna in
                print("VIP 商品信息无效")
                Load_Orna.showError_Orna(message_Orna: "Invalid product information")
            }
        } failure: { error_Orna in
            print("VIP 商品信息无效")
            Load_Orna.showError_Orna(message_Orna: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Orna(completion_Orna: @escaping () -> Void) {
        Load_Orna.showLoading_Orna()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Orna in
            Load_Orna.dismissLoading_Orna()
            if transactions_Orna?.count == 0 {
                print("当前没有可恢复的商品")
                Load_Orna.showError_Orna(message_Orna: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Load_Orna.showSuccess_Orna(message_Orna: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Orna()
            }
        }, failure: { error_Orna in
            print("取消恢复购买")
            Load_Orna.showError_Orna(message_Orna: "Cancel restore purchase")
        })
    }
}
