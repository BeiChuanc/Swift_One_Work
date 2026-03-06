import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Trace: NSObject {
    
    /// 单例
    static let shared_Trace = Store_Trace()
    
    // 礼物商品列表
    var goodsList_Trace: [StoreModel_Trace] = [
        StoreModel_Trace(
            id_Trace: 1,
            goodsId_Trace: "trace.pur.e.x5.3_9",
            goodsName_Trace: "x5",
            goodsPrice_Trace: "$3.99",
            goodIsTop_Trace: true,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 2,
            goodsId_Trace: "trace.pur.e.x10.4_9",
            goodsName_Trace: "x10",
            goodsPrice_Trace: "$4.99",
            goodIsTop_Trace: true,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 3,
            goodsId_Trace: "trace.pur.e.x1.1_9",
            goodsName_Trace: "x1",
            goodsPrice_Trace: "$1.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 4,
            goodsId_Trace: "trace.pur.e.x2.2_9",
            goodsName_Trace: "x2",
            goodsPrice_Trace: "$2.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 5,
            goodsId_Trace: "trace.pur.e.x3.3_9_s",
            goodsName_Trace: "x3",
            goodsPrice_Trace: "$3.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 6,
            goodsId_Trace: "trace.pur.e.x4.4_9",
            goodsName_Trace: "x4",
            goodsPrice_Trace: "$4.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 7,
            goodsId_Trace: "trace.pur.e.x5.6_9",
            goodsName_Trace: "x5",
            goodsPrice_Trace: "$6.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 8,
            goodsId_Trace: "trace.pur.e.x7.9_9",
            goodsName_Trace: "x7",
            goodsPrice_Trace: "$9.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 9,
            goodsId_Trace: "trace.pur.e.x12.19_9",
            goodsName_Trace: "x12",
            goodsPrice_Trace: "$19.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 10,
            goodsId_Trace: "trace.pur.e.x20.29_9",
            goodsName_Trace: "x20",
            goodsPrice_Trace: "$29.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 11,
            goodsId_Trace: "trace.pur.e.x42.49_9",
            goodsName_Trace: "x42",
            goodsPrice_Trace: "$49.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 12,
            goodsId_Trace: "trace.pur.e.x64.69_9",
            goodsName_Trace: "x64",
            goodsPrice_Trace: "$69.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        ),
        StoreModel_Trace(
            id_Trace: 13,
            goodsId_Trace: "trace.pur.e.x102.99_9",
            goodsName_Trace: "x102",
            goodsPrice_Trace: "$99.99",
            goodIsTop_Trace: false,
            goodIsLimit_Trace: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Trace {
    
    // 内购商品
    func PurchaseStoreGift_Trace(gid_Trace: String, completion_Trace: @escaping() -> Void) {
        Utils_Trace.showLoading_Trace()
        
        let products: Set = [gid_Trace]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Trace) { SKPaymentTransaction in
                Utils_Trace.dismissLoading_Trace()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Trace.showSuccess_Trace(message_Trace: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Trace()
                }else{
                    print("取消支付")
                    Utils_Trace.showError_Trace(message_Trace: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Trace.showError_Trace(message_Trace: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Trace.showError_Trace(message_Trace: "Invalid product information")
        }
    }
    
}
