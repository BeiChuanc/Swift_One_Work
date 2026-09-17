import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Vestir: NSObject {
    
    /// 单例
    static let shared_Vestir = Subscribe_Vestir()
    
    // 是否VIP
    var isVIP_Vestir: Bool = false
    
    // 是否购买一次性商品
    var isPur_Vestir: Bool = false
    
    // 礼物商品列表
    var goodsList_Vestir: [StoreModel_Vestir] = [
        StoreModel_Vestir(
            id_Vestir: 1,
            goodsId_Vestir: "vestir.gift.4_9",
            goodsName_Vestir: "x1",
            goodsPrice_Vestir: "$4.99",
            goodIsTop_Vestir: true
        ),
        StoreModel_Vestir(
            id_Vestir: 2,
            goodsId_Vestir: "vestir.gift.x1.4_9",
            goodsName_Vestir: "x1",
            goodsPrice_Vestir: "$4.99",
        ),
        StoreModel_Vestir(
            id_Vestir: 3,
            goodsId_Vestir: "vestir.gift.x5.14_9",
            goodsName_Vestir: "x5",
            goodsPrice_Vestir: "$14.99",
        ),
        StoreModel_Vestir(
            id_Vestir: 4,
            goodsId_Vestir: "vestir.gift.x10.19_9",
            goodsName_Vestir: "x10",
            goodsPrice_Vestir: "$19.99",
        ),
        StoreModel_Vestir(
            id_Vestir: 5,
            goodsId_Vestir: "vestir.gift.x30.49_9",
            goodsName_Vestir: "x30",
            goodsPrice_Vestir: "$49.99",
        ),
        StoreModel_Vestir(
            id_Vestir: 6,
            goodsId_Vestir: "vestir.gift.x1.6_9",
            goodsName_Vestir: "x1",
            goodsPrice_Vestir: "$6.99",
        ),
        StoreModel_Vestir(
            id_Vestir: 7,
            goodsId_Vestir: "vestir.gift.x5.19_9",
            goodsName_Vestir: "x5",
            goodsPrice_Vestir: "$19.99",
        ),
        StoreModel_Vestir(
            id_Vestir: 8,
            goodsId_Vestir: "vestir.gift.x10.29_9",
            goodsName_Vestir: "x10",
            goodsPrice_Vestir: "$29.99",
        ),
        StoreModel_Vestir(
            id_Vestir: 9,
            goodsId_Vestir: "vestir.gift.x30.79_9",
            goodsName_Vestir: "x30",
            goodsPrice_Vestir: "$79.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Vestir(
            id_Vestir: 9,
            goodsId_Vestir: "vestir.sub.1w.9_9",
            goodsName_Vestir: "Premium (1w.)",
            goodsPrice_Vestir: "$9.99",
            goodIsVIP_Vestir: true
        ),
        StoreModel_Vestir(
            id_Vestir: 10,
            goodsId_Vestir: "vestir.sub.1m.19_9",
            goodsName_Vestir: "Premium (1m.)",
            goodsPrice_Vestir: "$19.99",
            goodIsVIP_Vestir: true
        ),
        StoreModel_Vestir(
            id_Vestir: 11,
            goodsId_Vestir: "vestir.sub.3m.29_9",
            goodsName_Vestir: "Premium (3m.)",
            goodsPrice_Vestir: "$29.99",
            goodIsVIP_Vestir: true
        ),
        StoreModel_Vestir(
            id_Vestir: 12,
            goodsId_Vestir: "vestir.sub.1y.69_9",
            goodsName_Vestir: "Premium (1y.)",
            goodsPrice_Vestir: "$69.99",
            goodIsVIP_Vestir: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Vestir {
    
    // 内购商品
    func PurchaseStoreGift_Vestir(gid_Vestir: String, completion_Vestir: @escaping() -> Void) {
        Utils_Vestir.showLoading_Vestir()
        
        let products: Set = [gid_Vestir]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Vestir) { SKPaymentTransaction in
                Utils_Vestir.dismissLoading_Vestir()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Vestir.showSuccess_Vestir(message_Vestir: "Payment successful")
                    
                    if (gid_Vestir.contains("vestir.gift.x5.3_9")) {
                        self.isPur_Vestir = true
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Vestir()
                }else{
                    print("取消支付")
                    Utils_Vestir.showError_Vestir(message_Vestir: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Vestir.showError_Vestir(message_Vestir: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Vestir.showError_Vestir(message_Vestir: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Vestir(vipId_Vestir: String, completion_Vestir: @escaping () -> Void) {
        Utils_Vestir.showLoading_Vestir()

        let products_Vestir: Set = [vipId_Vestir]
        RMStore.default().requestProducts(products_Vestir) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Vestir) { transaction_Vestir in
                Utils_Vestir.dismissLoading_Vestir()
                if transaction_Vestir?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Vestir.showSuccess_Vestir(message_Vestir: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Vestir()
                } else {
                    print("取消 VIP 支付")
                    Utils_Vestir.showError_Vestir(message_Vestir: "User cancels payment")
                }
            } failure: { transaction_Vestir, error_Vestir in
                print("VIP 商品信息无效")
                Utils_Vestir.showError_Vestir(message_Vestir: "Invalid product information")
            }
        } failure: { error_Vestir in
            print("VIP 商品信息无效")
            Utils_Vestir.showError_Vestir(message_Vestir: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Vestir(completion_Vestir: @escaping () -> Void) {
        Utils_Vestir.showLoading_Vestir()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Vestir in
            Utils_Vestir.dismissLoading_Vestir()
            if transactions_Vestir?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Vestir.showError_Vestir(message_Vestir: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Vestir.showSuccess_Vestir(message_Vestir: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Vestir()
            }
        }, failure: { error_Vestir in
            print("取消恢复购买")
            Utils_Vestir.showError_Vestir(message_Vestir: "Cancel restore purchase")
        })
    }
}
