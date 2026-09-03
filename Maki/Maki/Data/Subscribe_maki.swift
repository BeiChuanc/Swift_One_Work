import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Subscribe_Maki: NSObject {
    
    /// 单例
    static let shared_Maki = Subscribe_Maki()
    
    // 是否VIP
    var isVIP_Maki: Bool = false
    
    // 是否购买一次性商品
    var isPur_Maki: Bool = false
    
    // 礼物商品列表
    var goodsList_Maki: [StoreModel_Maki] = [
        StoreModel_Maki(
            id_Maki: 1,
            goodsId_Maki: "maki.pur.x1.1_9",
            goodsName_Maki: "1x",
            goodsPrice_Maki: "$4.99",
        ),
        StoreModel_Maki(
            id_Maki: 2,
            goodsId_Maki: "maki.pur.x5.6_9",
            goodsName_Maki: "5x",
            goodsPrice_Maki: "$6.99",
        ),
        StoreModel_Maki(
            id_Maki: 3,
            goodsId_Maki: "maki.pur.x10.9_9",
            goodsName_Maki: "10x",
            goodsPrice_Maki: "$9.99",
        ),
        StoreModel_Maki(
            id_Maki: 4,
            goodsId_Maki: "maki.pur.x30.19_9",
            goodsName_Maki: "30x",
            goodsPrice_Maki: "$19.99",
        ),
        StoreModel_Maki(
            id_Maki: 5,
            goodsId_Maki: "maki.pur.x50.29_9",
            goodsName_Maki: "50x",
            goodsPrice_Maki: "$29.99",
        ),
        StoreModel_Maki(
            id_Maki: 6,
            goodsId_Maki: "maki.pur.x100.49_9",
            goodsName_Maki: "100x",
            goodsPrice_Maki: "$49.99",
        ),
        StoreModel_Maki(
            id_Maki: 7,
            goodsId_Maki: "maki.pur.x200.99_9",
            goodsName_Maki: "200x",
            goodsPrice_Maki: "$99.99",
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Maki(
            id_Maki: 9,
            goodsId_Maki: "maki.vip.1w.6_9",
            goodsName_Maki: "Premium (1w.)",
            goodsPrice_Maki: "$6.99",
            goodIsVIP_Maki: true
        ),
        StoreModel_Maki(
            id_Maki: 10,
            goodsId_Maki: "maki.vip.1m.14_9",
            goodsName_Maki: "Premium (1m.)",
            goodsPrice_Maki: "$14.99",
            goodIsVIP_Maki: true
        ),
        StoreModel_Maki(
            id_Maki: 11,
            goodsId_Maki: "maki.vip.3m.39_9",
            goodsName_Maki: "Premium (3m.)",
            goodsPrice_Maki: "$39.99",
            goodIsVIP_Maki: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Subscribe_Maki {
    
    // 内购商品
    func PurchaseStoreGift_Maki(gid_Maki: String, completion_Maki: @escaping() -> Void) {
        Load_Maki.showLoading_Maki()
        
        let products: Set = [gid_Maki]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Maki) { SKPaymentTransaction in
                Load_Maki.dismissLoading_Maki()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Load_Maki.showSuccess_Maki(message_Maki: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Maki()
                }else{
                    print("取消支付")
                    Load_Maki.showError_Maki(message_Maki: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Load_Maki.showError_Maki(message_Maki: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Load_Maki.showError_Maki(message_Maki: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Maki(vipId_Maki: String, completion_Maki: @escaping () -> Void) {
        Load_Maki.showLoading_Maki()

        let products_Maki: Set = [vipId_Maki]
        RMStore.default().requestProducts(products_Maki) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Maki) { transaction_Maki in
                Load_Maki.dismissLoading_Maki()
                if transaction_Maki?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Load_Maki.showSuccess_Maki(message_Maki: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Maki()
                } else {
                    print("取消 VIP 支付")
                    Load_Maki.showError_Maki(message_Maki: "User cancels payment")
                }
            } failure: { transaction_Maki, error_Maki in
                print("VIP 商品信息无效")
                Load_Maki.showError_Maki(message_Maki: "Invalid product information")
            }
        } failure: { error_Maki in
            print("VIP 商品信息无效")
            Load_Maki.showError_Maki(message_Maki: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Maki(completion_Maki: @escaping () -> Void) {
        Load_Maki.showLoading_Maki()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Maki in
            Load_Maki.dismissLoading_Maki()
            if transactions_Maki?.count == 0 {
                print("当前没有可恢复的商品")
                Load_Maki.showError_Maki(message_Maki: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Load_Maki.showSuccess_Maki(message_Maki: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Maki()
            }
        }, failure: { error_Maki in
            print("取消恢复购买")
            Load_Maki.showError_Maki(message_Maki: "Cancel restore purchase")
        })
    }
}
