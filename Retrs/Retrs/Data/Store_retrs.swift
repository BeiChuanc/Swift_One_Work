import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Retrs: NSObject {
    
    /// 单例
    static let shared_Retrs = Store_Retrs()
    
    // 礼物商品列表
    var goodsList_Retrs: [StoreModel_Retrs] = [
        StoreModel_Retrs(
            id_Retrs: 0,
            goodsId_Retrs: "retrs.spe.x1.1_9",
            goodsName_Retrs: "x1",
            goodsPrice_Retrs: "1.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: true
        ),
        StoreModel_Retrs(
            id_Retrs: 1,
            goodsId_Retrs: "retrs.spe.x3.3_9",
            goodsName_Retrs: "x3",
            goodsPrice_Retrs: "3.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: true
        ),
        StoreModel_Retrs(
            id_Retrs: 2,
            goodsId_Retrs: "retrs.spe.x5.4_9",
            goodsName_Retrs: "x5",
            goodsPrice_Retrs: "4.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: true
        ),
        StoreModel_Retrs(
            id_Retrs: 3,
            goodsId_Retrs: "retrs.gift.x1.1_9",
            goodsName_Retrs: "x1",
            goodsPrice_Retrs: "1.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 4,
            goodsId_Retrs: "retrs.gift.x3.2_9",
            goodsName_Retrs: "x3",
            goodsPrice_Retrs: "2.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 5,
            goodsId_Retrs: "retrs.gift.x3.3_9",
            goodsName_Retrs: "x5",
            goodsPrice_Retrs: "3.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 6,
            goodsId_Retrs: "retrs.gift.x10.4_9",
            goodsName_Retrs: "x10",
            goodsPrice_Retrs: "4.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 7,
            goodsId_Retrs: "retrs.gift.x1.6_9",
            goodsName_Retrs: "x1",
            goodsPrice_Retrs: "6.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 8,
            goodsId_Retrs: "retrs.gift.x3.9_9",
            goodsName_Retrs: "x3",
            goodsPrice_Retrs: "9.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 9,
            goodsId_Retrs: "retrs.gift.x5.19_9",
            goodsName_Retrs: "x5",
            goodsPrice_Retrs: "19.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 10,
            goodsId_Retrs: "retrs.gift.x10.29_9",
            goodsName_Retrs: "x10",
            goodsPrice_Retrs: "29.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 11,
            goodsId_Retrs: "retrs.gift.x1.49_9",
            goodsName_Retrs: "x1",
            goodsPrice_Retrs: "49.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 12,
            goodsId_Retrs: "retrs.gift.x3.69_9",
            goodsName_Retrs: "x3",
            goodsPrice_Retrs: "69.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        StoreModel_Retrs(
            id_Retrs: 13,
            goodsId_Retrs: "retrs.gift.x5.99_9",
            goodsName_Retrs: "x5",
            goodsPrice_Retrs: "99.99$",
            goodIsTop_Retrs: false,
            goodIsLimit_Retrs: false
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Retrs(
            id_Retrs: 14,
            goodsId_Retrs: "retrs.sub.1w.6_9",
            goodsName_Retrs: "1 Week",
            goodsPrice_Retrs: "$6.99",
            goodIsVIP_Retrs: true
        ),
        StoreModel_Retrs(
            id_Retrs: 15,
            goodsId_Retrs: "retrs.sub.1m.14_9",
            goodsName_Retrs: "1 Month",
            goodsPrice_Retrs: "$14.99",
            goodIsVIP_Retrs: true
        ),
        StoreModel_Retrs(
            id_Retrs: 16,
            goodsId_Retrs: "retrs.sub.3m.39_9",
            goodsName_Retrs: "3 Months",
            goodsPrice_Retrs: "$39.99",
            goodIsVIP_Retrs: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Retrs {
    
    // 内购商品
    func PurchaseStoreGift_Retrs(gid_Retrs: String, completion_Retrs: @escaping() -> Void) {
        Utils_Retrs.showLoading_Retrs()
        
        let products: Set = [gid_Retrs]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Retrs) { SKPaymentTransaction in
                Utils_Retrs.dismissLoading_Retrs()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Retrs.showSuccess_Retrs(message_Retrs: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Retrs()
                }else{
                    print("取消支付")
                    Utils_Retrs.showError_Retrs(message_Retrs: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Retrs.showError_Retrs(message_Retrs: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Retrs.showError_Retrs(message_Retrs: "Invalid product information")
        }
    }
    
    // 订阅VIP
    func PurchaseStoreVIP_Retrs(vipId_Retrs: String, completion_Retrs: @escaping () -> Void) {
        Utils_Retrs.showLoading_Retrs()

        let products_Retrs: Set = [vipId_Retrs]
        RMStore.default().requestProducts(products_Retrs) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Retrs) { transaction_Retrs in
                Utils_Retrs.dismissLoading_Retrs()
                if transaction_Retrs?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Retrs.showSuccess_Retrs(message_Retrs: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Retrs()
                } else {
                    print("取消 VIP 支付")
                    Utils_Retrs.showError_Retrs(message_Retrs: "User cancels payment")
                }
            } failure: { transaction_Retrs, error_Retrs in
                print("VIP 商品信息无效")
                Utils_Retrs.showError_Retrs(message_Retrs: "Invalid product information")
            }
        } failure: { error_Retrs in
            print("VIP 商品信息无效")
            Utils_Retrs.showError_Retrs(message_Retrs: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Retrs(completion_Retrs: @escaping () -> Void) {
        Utils_Retrs.showLoading_Retrs()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Retrs in
            Utils_Retrs.dismissLoading_Retrs()
            if transactions_Retrs?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Retrs.showError_Retrs(message_Retrs: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Retrs.showSuccess_Retrs(message_Retrs: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Retrs()
            }
        }, failure: { error_Retrs in
            print("取消恢复购买")
            Utils_Retrs.showError_Retrs(message_Retrs: "Cancel restore purchase")
        })
    }
    
}
