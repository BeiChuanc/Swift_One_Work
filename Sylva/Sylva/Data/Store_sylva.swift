import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Sylva: NSObject {
    
    /// 单例
    static let shared_Sylva = Store_Sylva()
    
    // 礼物商品列表
    var goodsList_Sylva: [StoreModel_Sylva] = [
        StoreModel_Sylva(
            id_Sylva: 0,
            goodsId_Sylva: "sylva.spe.x1.1_9",
            goodsName_Sylva: "x1",
            goodsPrice_Sylva: "1.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: true
        ),
        StoreModel_Sylva(
            id_Sylva: 1,
            goodsId_Sylva: "sylva.spe.x3.3_9",
            goodsName_Sylva: "x3",
            goodsPrice_Sylva: "3.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: true
        ),
        StoreModel_Sylva(
            id_Sylva: 2,
            goodsId_Sylva: "sylva.spe.x5.4_9",
            goodsName_Sylva: "x5",
            goodsPrice_Sylva: "4.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: true
        ),
        StoreModel_Sylva(
            id_Sylva: 3,
            goodsId_Sylva: "sylva.gift.x1.1_9",
            goodsName_Sylva: "x1",
            goodsPrice_Sylva: "1.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 4,
            goodsId_Sylva: "sylva.gift.x3.2_9",
            goodsName_Sylva: "x3",
            goodsPrice_Sylva: "2.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 5,
            goodsId_Sylva: "sylva.gift.x3.3_9",
            goodsName_Sylva: "x5",
            goodsPrice_Sylva: "3.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 6,
            goodsId_Sylva: "sylva.gift.x10.4_9",
            goodsName_Sylva: "x10",
            goodsPrice_Sylva: "4.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 7,
            goodsId_Sylva: "sylva.gift.x1.6_9",
            goodsName_Sylva: "x1",
            goodsPrice_Sylva: "6.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 8,
            goodsId_Sylva: "sylva.gift.x3.9_9",
            goodsName_Sylva: "x3",
            goodsPrice_Sylva: "9.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 9,
            goodsId_Sylva: "sylva.gift.x5.19_9",
            goodsName_Sylva: "x5",
            goodsPrice_Sylva: "19.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 10,
            goodsId_Sylva: "sylva.gift.x10.29_9",
            goodsName_Sylva: "x10",
            goodsPrice_Sylva: "29.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 11,
            goodsId_Sylva: "sylva.gift.x1.49_9",
            goodsName_Sylva: "x1",
            goodsPrice_Sylva: "49.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 12,
            goodsId_Sylva: "sylva.gift.x3.69_9",
            goodsName_Sylva: "x3",
            goodsPrice_Sylva: "69.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        StoreModel_Sylva(
            id_Sylva: 13,
            goodsId_Sylva: "sylva.gift.x5.99_9",
            goodsName_Sylva: "x5",
            goodsPrice_Sylva: "99.99$",
            goodIsTop_Sylva: false,
            goodIsLimit_Sylva: false
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Sylva(
            id_Sylva: 14,
            goodsId_Sylva: "sylva.sub.1w.6_9",
            goodsName_Sylva: "1 Week",
            goodsPrice_Sylva: "$6.99",
            goodIsVIP_Sylva: true
        ),
        StoreModel_Sylva(
            id_Sylva: 15,
            goodsId_Sylva: "sylva.sub.1m.14_9",
            goodsName_Sylva: "1 Month",
            goodsPrice_Sylva: "$14.99",
            goodIsVIP_Sylva: true
        ),
        StoreModel_Sylva(
            id_Sylva: 16,
            goodsId_Sylva: "sylva.sub.3m.39_9",
            goodsName_Sylva: "3 Months",
            goodsPrice_Sylva: "$39.99",
            goodIsVIP_Sylva: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Sylva {
    
    // 内购商品
    func PurchaseStoreGift_Sylva(gid_Sylva: String, completion_Sylva: @escaping() -> Void) {
        Utils_Sylva.showLoading_Sylva()
        
        let products: Set = [gid_Sylva]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Sylva) { SKPaymentTransaction in
                Utils_Sylva.dismissLoading_Sylva()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Sylva.showSuccess_Sylva(message_Sylva: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Sylva()
                }else{
                    print("取消支付")
                    Utils_Sylva.showError_Sylva(message_Sylva: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Sylva.showError_Sylva(message_Sylva: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Sylva.showError_Sylva(message_Sylva: "Invalid product information")
        }
    }
    
    // 订阅VIP
    func PurchaseStoreVIP_Sylva(vipId_Sylva: String, completion_Sylva: @escaping () -> Void) {
        Utils_Sylva.showLoading_Sylva()

        let products_Sylva: Set = [vipId_Sylva]
        RMStore.default().requestProducts(products_Sylva) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Sylva) { transaction_Sylva in
                Utils_Sylva.dismissLoading_Sylva()
                if transaction_Sylva?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Sylva.showSuccess_Sylva(message_Sylva: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Sylva()
                } else {
                    print("取消 VIP 支付")
                    Utils_Sylva.showError_Sylva(message_Sylva: "User cancels payment")
                }
            } failure: { transaction_Sylva, error_Sylva in
                print("VIP 商品信息无效")
                Utils_Sylva.showError_Sylva(message_Sylva: "Invalid product information")
            }
        } failure: { error_Sylva in
            print("VIP 商品信息无效")
            Utils_Sylva.showError_Sylva(message_Sylva: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Sylva(completion_Sylva: @escaping () -> Void) {
        Utils_Sylva.showLoading_Sylva()

        RMStore.default().restoreTransactions(onSuccess: { transactions_Sylva in
            Utils_Sylva.dismissLoading_Sylva()
            if transactions_Sylva?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Sylva.showError_Sylva(message_Sylva: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Sylva.showSuccess_Sylva(message_Sylva: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Sylva()
            }
        }, failure: { error_Sylva in
            print("取消恢复购买")
            Utils_Sylva.showError_Sylva(message_Sylva: "Cancel restore purchase")
        })
    }
    
}
