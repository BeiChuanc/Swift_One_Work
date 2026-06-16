import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Niche: NSObject {
    
    /// 单例
    static let shared_Niche = Store_Niche()
    
    // 礼物商品列表
    var goodsList_Niche: [StoreModel_Niche] = [
        StoreModel_Niche(
            id_Niche: 0,
            goodsId_Niche: "niche.spe.x1.1_9",
            goodsName_Niche: "x1",
            goodsPrice_Niche: "1.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 1,
            goodsId_Niche: "niche.spe.x3.3_9",
            goodsName_Niche: "x3",
            goodsPrice_Niche: "3.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 2,
            goodsId_Niche: "niche.spe.x5.4_9",
            goodsName_Niche: "x5",
            goodsPrice_Niche: "4.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 3,
            goodsId_Niche: "niche.gift.x1.1_9",
            goodsName_Niche: "x1",
            goodsPrice_Niche: "1.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 4,
            goodsId_Niche: "niche.gift.x3.2_9",
            goodsName_Niche: "x3",
            goodsPrice_Niche: "2.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 5,
            goodsId_Niche: "niche.gift.x3.3_9",
            goodsName_Niche: "x5",
            goodsPrice_Niche: "3.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 6,
            goodsId_Niche: "niche.gift.x10.4_9",
            goodsName_Niche: "x10",
            goodsPrice_Niche: "4.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 7,
            goodsId_Niche: "niche.gift.x1.6_9",
            goodsName_Niche: "x1",
            goodsPrice_Niche: "6.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 8,
            goodsId_Niche: "niche.gift.x3.9_9",
            goodsName_Niche: "x3",
            goodsPrice_Niche: "9.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 9,
            goodsId_Niche: "niche.gift.x5.19_9",
            goodsName_Niche: "x5",
            goodsPrice_Niche: "19.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 10,
            goodsId_Niche: "niche.gift.x10.29_9",
            goodsName_Niche: "x10",
            goodsPrice_Niche: "29.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 11,
            goodsId_Niche: "niche.gift.x1.49_9",
            goodsName_Niche: "x1",
            goodsPrice_Niche: "49.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 12,
            goodsId_Niche: "niche.gift.x3.69_9",
            goodsName_Niche: "x3",
            goodsPrice_Niche: "69.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        StoreModel_Niche(
            id_Niche: 13,
            goodsId_Niche: "niche.gift.x5.99_9",
            goodsName_Niche: "x5",
            goodsPrice_Niche: "99.99$",
            goodIsTop_Niche: false,
            goodIsLimit_Niche: false
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Niche(
            id_Niche: 14,
            goodsId_Niche: "niche.sub.1w.6_9",
            goodsName_Niche: "1 Week",
            goodsPrice_Niche: "$6.99",
            goodIsVIP_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 15,
            goodsId_Niche: "niche.sub.1m.14_9",
            goodsName_Niche: "1 Month",
            goodsPrice_Niche: "$14.99",
            goodIsVIP_Niche: true
        ),
        StoreModel_Niche(
            id_Niche: 16,
            goodsId_Niche: "niche.sub.3m.39_9",
            goodsName_Niche: "3 Months",
            goodsPrice_Niche: "$39.99",
            goodIsVIP_Niche: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Niche {
    
    // 内购商品
    func PurchaseStoreGift_Niche(gid_Niche: String, completion_Niche: @escaping() -> Void) {
        Utils_Niche.showLoading_Niche()
        
        let products: Set = [gid_Niche]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Niche) { SKPaymentTransaction in
                Utils_Niche.dismissLoading_Niche()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Niche.showSuccess_Niche(message_Niche: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Niche()
                }else{
                    print("取消支付")
                    Utils_Niche.showError_Niche(message_Niche: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Niche.showError_Niche(message_Niche: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Niche.showError_Niche(message_Niche: "Invalid product information")
        }
    }
    
    // 订阅VIP
    func PurchaseStoreVIP_Niche(vipId_Niche: String, completion_Niche: @escaping () -> Void) {
        Utils_Niche.showLoading_Niche()

        let products_Niche: Set = [vipId_Niche]
        RMStore.default().requestProducts(products_Niche) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Niche) { transaction_Niche in
                Utils_Niche.dismissLoading_Niche()
                if transaction_Niche?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Niche.showSuccess_Niche(message_Niche: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Niche()
                } else {
                    print("取消 VIP 支付")
                    Utils_Niche.showError_Niche(message_Niche: "User cancels payment")
                }
            } failure: { transaction_Niche, error_Niche in
                print("VIP 商品信息无效")
                Utils_Niche.showError_Niche(message_Niche: "Invalid product information")
            }
        } failure: { error_Niche in
            print("VIP 商品信息无效")
            Utils_Niche.showError_Niche(message_Niche: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Niche(completion_Niche: @escaping () -> Void) {
        Utils_Niche.showLoading_Niche()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Niche in
            Utils_Niche.dismissLoading_Niche()
            if transactions_Niche?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Niche.showError_Niche(message_Niche: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Niche.showSuccess_Niche(message_Niche: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Niche()
            }
        }, failure: { error_Niche in
            print("取消恢复购买")
            Utils_Niche.showError_Niche(message_Niche: "Cancel restore purchase")
        })
    }
    
}
