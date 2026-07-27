import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Breeze: NSObject {
    
    /// 单例
    static let shared_Breeze = Store_Breeze()
    
    // 礼物商品列表
    var goodsList_Breeze: [StoreModel_Breeze] = [
        StoreModel_Breeze(
            id_Breeze: 0,
            goodsId_Breeze: "breeze.spe.x1.1_9",
            goodsName_Breeze: "x1",
            goodsPrice_Breeze: "1.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: true
        ),
        StoreModel_Breeze(
            id_Breeze: 1,
            goodsId_Breeze: "breeze.spe.x3.3_9",
            goodsName_Breeze: "x3",
            goodsPrice_Breeze: "3.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: true
        ),
        StoreModel_Breeze(
            id_Breeze: 2,
            goodsId_Breeze: "breeze.spe.x5.4_9",
            goodsName_Breeze: "x5",
            goodsPrice_Breeze: "4.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: true
        ),
        StoreModel_Breeze(
            id_Breeze: 3,
            goodsId_Breeze: "breeze.gift.x1.1_9",
            goodsName_Breeze: "x1",
            goodsPrice_Breeze: "1.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 4,
            goodsId_Breeze: "breeze.gift.x3.2_9",
            goodsName_Breeze: "x3",
            goodsPrice_Breeze: "2.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 5,
            goodsId_Breeze: "breeze.gift.x3.3_9",
            goodsName_Breeze: "x5",
            goodsPrice_Breeze: "3.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 6,
            goodsId_Breeze: "breeze.gift.x10.4_9",
            goodsName_Breeze: "x10",
            goodsPrice_Breeze: "4.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 7,
            goodsId_Breeze: "breeze.gift.x1.6_9",
            goodsName_Breeze: "x1",
            goodsPrice_Breeze: "6.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 8,
            goodsId_Breeze: "breeze.gift.x3.9_9",
            goodsName_Breeze: "x3",
            goodsPrice_Breeze: "9.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 9,
            goodsId_Breeze: "breeze.gift.x5.19_9",
            goodsName_Breeze: "x5",
            goodsPrice_Breeze: "19.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 10,
            goodsId_Breeze: "breeze.gift.x10.29_9",
            goodsName_Breeze: "x10",
            goodsPrice_Breeze: "29.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 11,
            goodsId_Breeze: "breeze.gift.x1.49_9",
            goodsName_Breeze: "x1",
            goodsPrice_Breeze: "49.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 12,
            goodsId_Breeze: "breeze.gift.x3.69_9",
            goodsName_Breeze: "x3",
            goodsPrice_Breeze: "69.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        StoreModel_Breeze(
            id_Breeze: 13,
            goodsId_Breeze: "breeze.gift.x5.99_9",
            goodsName_Breeze: "x5",
            goodsPrice_Breeze: "99.99$",
            goodIsTop_Breeze: false,
            goodIsLimit_Breeze: false
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Breeze(
            id_Breeze: 14,
            goodsId_Breeze: "breeze.sub.1w.6_9",
            goodsName_Breeze: "1 Week",
            goodsPrice_Breeze: "$6.99",
            goodIsVIP_Breeze: true
        ),
        StoreModel_Breeze(
            id_Breeze: 15,
            goodsId_Breeze: "breeze.sub.1m.14_9",
            goodsName_Breeze: "1 Month",
            goodsPrice_Breeze: "$14.99",
            goodIsVIP_Breeze: true
        ),
        StoreModel_Breeze(
            id_Breeze: 16,
            goodsId_Breeze: "breeze.sub.3m.39_9",
            goodsName_Breeze: "3 Months",
            goodsPrice_Breeze: "$39.99",
            goodIsVIP_Breeze: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Breeze {
    
    // 内购商品
    func PurchaseStoreGift_Breeze(gid_Breeze: String, completion_Breeze: @escaping() -> Void) {
        Utils_Breeze.showLoading_Breeze()
        
        let products: Set = [gid_Breeze]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Breeze) { SKPaymentTransaction in
                Utils_Breeze.dismissLoading_Breeze()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Breeze.showSuccess_Breeze(message_Breeze: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Breeze()
                }else{
                    print("取消支付")
                    Utils_Breeze.showError_Breeze(message_Breeze: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Breeze.showError_Breeze(message_Breeze: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Breeze.showError_Breeze(message_Breeze: "Invalid product information")
        }
    }
    
    // 订阅VIP
    func PurchaseStoreVIP_Breeze(vipId_Breeze: String, completion_Breeze: @escaping () -> Void) {
        Utils_Breeze.showLoading_Breeze()

        let products_Breeze: Set = [vipId_Breeze]
        RMStore.default().requestProducts(products_Breeze) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Breeze) { transaction_Breeze in
                Utils_Breeze.dismissLoading_Breeze()
                if transaction_Breeze?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Breeze.showSuccess_Breeze(message_Breeze: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Breeze()
                } else {
                    print("取消 VIP 支付")
                    Utils_Breeze.showError_Breeze(message_Breeze: "User cancels payment")
                }
            } failure: { transaction_Breeze, error_Breeze in
                print("VIP 商品信息无效")
                Utils_Breeze.showError_Breeze(message_Breeze: "Invalid product information")
            }
        } failure: { error_Breeze in
            print("VIP 商品信息无效")
            Utils_Breeze.showError_Breeze(message_Breeze: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Breeze(completion_Breeze: @escaping () -> Void) {
        Utils_Breeze.showLoading_Breeze()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Breeze in
            Utils_Breeze.dismissLoading_Breeze()
            if transactions_Breeze?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Breeze.showError_Breeze(message_Breeze: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Breeze.showSuccess_Breeze(message_Breeze: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Breeze()
            }
        }, failure: { error_Breeze in
            print("取消恢复购买")
            Utils_Breeze.showError_Breeze(message_Breeze: "Cancel restore purchase")
        })
    }
    
}
