import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Lens: NSObject {
    
    /// 单例
    static let shared_Lens = Subscribe_Lens()
    
    // 是否VIP
    var isVIP_Lens: Bool = false
    
    // 是否购买一次性商品
    var isPur_Lens: Bool = false
    
    // 礼物商品列表
    var goodsList_Lens: [StoreModel_Lens] = [
        StoreModel_Lens(
            id_Lens: 1,
            goodsId_Lens: "praise.gift.4_9",
            goodsName_Lens: "x1",
            goodsPrice_Lens: "$4.99",
            goodIsTop_Lens: true
        ),
        StoreModel_Lens(
            id_Lens: 2,
            goodsId_Lens: "praise.gift.x1.4_9",
            goodsName_Lens: "x1",
            goodsPrice_Lens: "$4.99",
        ),
        StoreModel_Lens(
            id_Lens: 3,
            goodsId_Lens: "praise.gift.x5.14_9",
            goodsName_Lens: "x5",
            goodsPrice_Lens: "$14.99",
        ),
        StoreModel_Lens(
            id_Lens: 4,
            goodsId_Lens: "praise.gift.x10.19_9",
            goodsName_Lens: "x10",
            goodsPrice_Lens: "$19.99",
        ),
        StoreModel_Lens(
            id_Lens: 5,
            goodsId_Lens: "praise.gift.x30.49_9",
            goodsName_Lens: "x30",
            goodsPrice_Lens: "$49.99",
        ),
        StoreModel_Lens(
            id_Lens: 6,
            goodsId_Lens: "praise.gift.x1.6_9",
            goodsName_Lens: "x1",
            goodsPrice_Lens: "$6.99",
        ),
        StoreModel_Lens(
            id_Lens: 7,
            goodsId_Lens: "praise.gift.x5.19_9",
            goodsName_Lens: "x5",
            goodsPrice_Lens: "$19.99",
        ),
        StoreModel_Lens(
            id_Lens: 8,
            goodsId_Lens: "praise.gift.x10.29_9",
            goodsName_Lens: "x10",
            goodsPrice_Lens: "$29.99",
        ),
        StoreModel_Lens(
            id_Lens: 9,
            goodsId_Lens: "praise.gift.x30.79_9",
            goodsName_Lens: "x30",
            goodsPrice_Lens: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Lens(
            id_Lens: 9,
            goodsId_Lens: "praise.sub.1w.9_9",
            goodsName_Lens: "Premium (1w.)",
            goodsPrice_Lens: "$9.99",
            goodIsVIP_Lens: true
        ),
        StoreModel_Lens(
            id_Lens: 10,
            goodsId_Lens: "praise.sub.1m.19_9",
            goodsName_Lens: "Premium (1m.)",
            goodsPrice_Lens: "$19.99",
            goodIsVIP_Lens: true
        ),
        StoreModel_Lens(
            id_Lens: 11,
            goodsId_Lens: "praise.sub.3m.29_9",
            goodsName_Lens: "Premium (3m.)",
            goodsPrice_Lens: "$29.99",
            goodIsVIP_Lens: true
        ),
        StoreModel_Lens(
            id_Lens: 12,
            goodsId_Lens: "praise.sub.1y.69_9",
            goodsName_Lens: "Premium (1y.)",
            goodsPrice_Lens: "$69.99",
            goodIsVIP_Lens: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Lens {
    
    // 内购商品
    func PurchaseStoreGift_Lens(gid_Lens: String, completion_Lens: @escaping() -> Void) {
        Load_Lens.showLoading_Lens()
        
        let products: Set = [gid_Lens]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Lens) { SKPaymentTransaction in
                Load_Lens.dismissLoading_Lens()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Load_Lens.showSuccess_Lens(message_Lens: "Payment successful")
                    
                    if (gid_Lens.contains("praise.gift.x5.3_9")) {
                        self.isPur_Lens = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Lens()
                }else{
                    print("取消支付")
                    Load_Lens.showError_Lens(message_Lens: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Load_Lens.showError_Lens(message_Lens: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Load_Lens.showError_Lens(message_Lens: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Lens(vipId_Lens: String, completion_Lens: @escaping () -> Void) {
        Load_Lens.showLoading_Lens()

        let products_Lens: Set = [vipId_Lens]
        RMStore.default().requestProducts(products_Lens) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Lens) { transaction_Lens in
                Load_Lens.dismissLoading_Lens()
                if transaction_Lens?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Load_Lens.showSuccess_Lens(message_Lens: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Lens()
                } else {
                    print("取消 VIP 支付")
                    Load_Lens.showError_Lens(message_Lens: "User cancels payment")
                }
            } failure: { transaction_Lens, error_Lens in
                print("VIP 商品信息无效")
                Load_Lens.showError_Lens(message_Lens: "Invalid product information")
            }
        } failure: { error_Lens in
            print("VIP 商品信息无效")
            Load_Lens.showError_Lens(message_Lens: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Lens(completion_Lens: @escaping () -> Void) {
        Load_Lens.showLoading_Lens()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Lens in
            Load_Lens.dismissLoading_Lens()
            if transactions_Lens?.count == 0 {
                print("当前没有可恢复的商品")
                Load_Lens.showError_Lens(message_Lens: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Load_Lens.showSuccess_Lens(message_Lens: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Lens()
            }
        }, failure: { error_Lens in
            print("取消恢复购买")
            Load_Lens.showError_Lens(message_Lens: "Cancel restore purchase")
        })
    }
}
