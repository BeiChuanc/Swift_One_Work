import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Pane: NSObject {
    
    /// 单例
    static let shared_Pane = Store_Pane()
    
    // 是否VIP
    var isVIP_Pane: Bool = false
    
    // 礼物商品列表
    var goodsList_Pane: [StoreModel_Pane] = [
        StoreModel_Pane(
            id_Pane: 1,
            goodsId_Pane: "pane.pur.x5.3_9",
            goodsName_Pane: "x5",
            goodsPrice_Pane: "$3.99",
            goodIsTop_Pane: true,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 2,
            goodsId_Pane: "pane.pur.x10.4_9",
            goodsName_Pane: "x10",
            goodsPrice_Pane: "$4.99",
            goodIsTop_Pane: true,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 3,
            goodsId_Pane: "pane.pur.x1.1_9",
            goodsName_Pane: "x1",
            goodsPrice_Pane: "$1.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: true,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 4,
            goodsId_Pane: "pane.pur.x2.2_9",
            goodsName_Pane: "x2",
            goodsPrice_Pane: "$2.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: true,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 5,
            goodsId_Pane: "pane.pur.x3.3_9_s",
            goodsName_Pane: "x3",
            goodsPrice_Pane: "$3.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: true,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 6,
            goodsId_Pane: "pane.pur.x4.4_9",
            goodsName_Pane: "x4",
            goodsPrice_Pane: "$4.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 7,
            goodsId_Pane: "pane.pur.x5.6_9",
            goodsName_Pane: "x5",
            goodsPrice_Pane: "$6.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 8,
            goodsId_Pane: "pane.pur.x7.9_9",
            goodsName_Pane: "x7",
            goodsPrice_Pane: "$9.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 9,
            goodsId_Pane: "pane.pur.x12.19_9",
            goodsName_Pane: "x12",
            goodsPrice_Pane: "$19.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 10,
            goodsId_Pane: "pane.pur.x20.29_9",
            goodsName_Pane: "x20",
            goodsPrice_Pane: "$29.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 11,
            goodsId_Pane: "pane.pur.x42.49_9",
            goodsName_Pane: "x42",
            goodsPrice_Pane: "$49.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 12,
            goodsId_Pane: "pane.pur.x64.69_9",
            goodsName_Pane: "x64",
            goodsPrice_Pane: "$69.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        StoreModel_Pane(
            id_Pane: 13,
            goodsId_Pane: "pane.pur.x102.99_9",
            goodsName_Pane: "x102",
            goodsPrice_Pane: "$99.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: false
        ),
        
        // ------- VIP ------- //
        
        StoreModel_Pane(
            id_Pane: 14,
            goodsId_Pane: "pane.pur.1w.9_9",
            goodsName_Pane: "1 Week / $ 9.99",
            goodsPrice_Pane: "$9.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: true
        ),
        StoreModel_Pane(
            id_Pane: 15,
            goodsId_Pane: "pane.pur.1m.19_9",
            goodsName_Pane: "1 Months / $ 19.99",
            goodsPrice_Pane: "$19.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: true
        ),
        StoreModel_Pane(
            id_Pane: 16,
            goodsId_Pane: "pane.pur.3m.29_9",
            goodsName_Pane: "3 Months / $ 29.99",
            goodsPrice_Pane: "$29.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: true
        ),
        StoreModel_Pane(
            id_Pane: 17,
            goodsId_Pane: "pane.pur.1y.69_9",
            goodsName_Pane: "1 Year / $ 69.99",
            goodsPrice_Pane: "$69.99",
            goodIsTop_Pane: false,
            goodIsLimit_Pane: false,
            goodIsVIP_Pane: true
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Pane {
    
    // 内购商品
    func PurchaseStoreGift_Pane(gid_Pane: String, completion_Pane: @escaping() -> Void) {
        Utils_Pane.showLoading_Pane()
        
        let products: Set = [gid_Pane]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Pane) { SKPaymentTransaction in
                Utils_Pane.dismissLoading_Pane()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Pane.showSuccess_Pane(message_Pane: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Pane()
                }else{
                    print("取消支付")
                    Utils_Pane.showError_Pane(message_Pane: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Pane.showError_Pane(message_Pane: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Pane.showError_Pane(message_Pane: "Invalid product information")
        }
    }

    // 订阅VIP
    func PurchaseStoreVIP_Pane(vipId_Pane: String, completion_Pane: @escaping () -> Void) {
        Utils_Pane.showLoading_Pane()

        let products_pane: Set = [vipId_Pane]
        RMStore.default().requestProducts(products_pane) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(vipId_Pane) { transaction_pane in
                Utils_Pane.dismissLoading_Pane()
                if transaction_pane?.transactionState == .purchased {
                    print("VIP 支付成功")
                    Utils_Pane.showSuccess_Pane(message_Pane: "Payment successful")

                    NotificationCenter.default.post(
                        name: NSNotification.Name("PaneRefreshVIP"),
                        object: nil
                    )
                    completion_Pane()
                } else {
                    print("取消 VIP 支付")
                    Utils_Pane.showError_Pane(message_Pane: "User cancels payment")
                }
            } failure: { transaction_pane, error_pane in
                print("VIP 商品信息无效")
                Utils_Pane.showError_Pane(message_Pane: "Invalid product information")
            }
        } failure: { error_pane in
            print("VIP 商品信息无效")
            Utils_Pane.showError_Pane(message_Pane: "Invalid product information")
        }
    }

    // 恢复购买
    func RestorePurchase_Pane(completion_Pane: @escaping () -> Void) {
        Utils_Pane.showLoading_Pane()

        RMStore.default().restoreTransactions(onSuccess: { transactions_pane in
            Utils_Pane.dismissLoading_Pane()
            if transactions_pane?.count == 0 {
                print("当前没有可恢复的商品")
                Utils_Pane.showError_Pane(message_Pane: "There are currently no items to restore")
            } else {
                print("恢复购买成功")
                Utils_Pane.showSuccess_Pane(message_Pane: "Restore purchase successfully")

                NotificationCenter.default.post(
                    name: NSNotification.Name("PaneRefreshVIP"),
                    object: nil
                )
                completion_Pane()
            }
        }, failure: { error_pane in
            print("取消恢复购买")
            Utils_Pane.showError_Pane(message_Pane: "Cancel restore purchase")
        })
    }
}
