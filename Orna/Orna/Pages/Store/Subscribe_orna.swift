import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Orna: NSObject {
    
    /// 单例
    static let shared_Orna = Store_Orna()
    
    // 礼物商品列表
    var goodsList_Orna: [StoreModel_Orna] = [
        StoreModel_Orna(
            id_Orna: 0,
            goodsId_Orna: "bermude.spe.x1.1_9",
            goodsName_Orna: "x1",
            goodsPrice_Orna: "1.99$",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 1,
            goodsId_Orna: "bermude.spe.x3.6_9",
            goodsName_Orna: "x3",
            goodsPrice_Orna: "6.99$",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 2,
            goodsId_Orna: "bermude.spe.x5.9_9",
            goodsName_Orna: "x5",
            goodsPrice_Orna: "9.99$",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 9,
            goodsId_Orna: "bermude.gift.x1.19_9",
            goodsName_Orna: "x1",
            goodsPrice_Orna: "19.99$",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 10,
            goodsId_Orna: "bermude.gift.x3.29_9",
            goodsName_Orna: "x3",
            goodsPrice_Orna: "29.99$",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 11,
            goodsId_Orna: "bermude.gift.x5.49_9",
            goodsName_Orna: "x5",
            goodsPrice_Orna: "49.99$",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 13,
            goodsId_Orna: "bermude.gift.x10.99_9",
            goodsName_Orna: "x10",
            goodsPrice_Orna: "99.99$",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Orna(
            id_Orna: 14,
            goodsId_Orna: "bermude.sub.1w.6_9",
            goodsName_Orna: "Premium(1w.)",
            goodsPrice_Orna: "$6.99/w",
            goodIsVIP_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 15,
            goodsId_Orna: "bermude.sub.1m.14_9",
            goodsName_Orna: "Premium(1m.)",
            goodsPrice_Orna: "$14.99/m",
            goodIsVIP_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 16,
            goodsId_Orna: "bermude.sub.3m.39_9",
            goodsName_Orna: "Premium(3m.)",
            goodsPrice_Orna: "$39.99/3m",
            goodIsVIP_Orna: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Orna {
    
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
