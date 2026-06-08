import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Vestir {
    /// 个人聊天
    case personal_vestir
    /// 群聊
    case group_vestir
    /// AI聊天
    case ai_vestir
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Vestir {
    
    /// 单例
    static let shared_Vestir = MessageViewModel_Vestir()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Vestir = Notification.Name("MessageStateDidChange_Vestir")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Vestir: [Int: [MessageModel_Vestir]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Vestir: [Int: GroupChatInfo_Vestir] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Vestir: [MessageModel_Vestir] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Vestir: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Vestir() {
        userMesMap_Vestir = [:]
        aiChats_Vestir = []
        notifyStateChange_Vestir()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Vestir() -> [Int: GroupChatInfo_Vestir] {
        return groupChats_Vestir
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Vestir(userId_vestir: Int) -> [MessageModel_Vestir] {
        return userMesMap_Vestir[userId_vestir] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Vestir() -> [PrewUserModel_Vestir] {
        let userIds_vestir = userMesMap_Vestir.keys
        return LocalData_Vestir.shared_Vestir.userList_Vestir.filter { user in
            guard let userId = user.userId_Vestir else { return false }
            return userIds_vestir.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Vestir() -> [MessageModel_Vestir] {
        return aiChats_Vestir
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Vestir(groupId_vestir: Int) -> [MessageModel_Vestir] {
        return groupChats_Vestir[groupId_vestir]?.messages_vestir ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Vestir(userId_vestir: Int) -> MessageModel_Vestir? {
        return userMesMap_Vestir[userId_vestir]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Vestir(message_vestir: String, chatType_vestir: ChatType_Vestir, id_vestir: Int) {
        let currentTime_vestir = getCurrentTime_Vestir()
        
        let chatMessage_vestir = MessageModel_Vestir(
            messageId_vestir: Int(Date().timeIntervalSince1970 * 1000),
            content_vestir: message_vestir,
            userHead_vestir: "current_user_head", // 这里应该从UserViewModel获取
            isMine_vestir: true,
            time_vestir: currentTime_vestir
        )
        
        switch chatType_vestir {
        case .personal_vestir:
            // 个人聊天
            if userMesMap_Vestir[id_vestir] == nil {
                userMesMap_Vestir[id_vestir] = []
            }
            userMesMap_Vestir[id_vestir]?.append(chatMessage_vestir)
            handleMessage_Vestir(message_vestir: chatMessage_vestir, id_vestir: id_vestir, chatType_vestir: chatType_vestir)
            
        case .group_vestir:
            // 群聊
            if var groupInfo_vestir = groupChats_Vestir[id_vestir] {
                groupInfo_vestir.messages_vestir.append(chatMessage_vestir)
                groupChats_Vestir[id_vestir] = groupInfo_vestir
            } else {
                groupChats_Vestir[id_vestir] = GroupChatInfo_Vestir(
                    gid_vestir: id_vestir,
                    intro_vestir: "",
                    cover_vestir: "",
                    join_vestir: "",
                    messages_vestir: [chatMessage_vestir]
                )
            }
            
        case .ai_vestir:
            // AI聊天
            aiChats_Vestir.append(chatMessage_vestir)
            handleMessage_Vestir(message_vestir: chatMessage_vestir, id_vestir: id_vestir, chatType_vestir: chatType_vestir)
        }
        
        notifyStateChange_Vestir()
    }
    
    /// 处理消息回复
    private func handleMessage_Vestir(message_vestir: MessageModel_Vestir, id_vestir: Int, chatType_vestir: ChatType_Vestir) {
        Task {
            let response_vestir = await chatService_Vestir(
                userId_vestir: 0, // 这里应该从UserViewModel获取
                message_vestir: message_vestir.content_Vestir ?? ""
            )
            
            let replyMessage_vestir = MessageModel_Vestir(
                messageId_vestir: Int(Date().timeIntervalSince1970 * 1000),
                content_vestir: response_vestir ?? "Server error",
                userHead_vestir: "",
                isMine_vestir: false,
                time_vestir: getCurrentTime_Vestir()
            )
            
            switch chatType_vestir {
            case .ai_vestir:
                aiChats_Vestir.append(replyMessage_vestir)
                
            case .personal_vestir:
                if userMesMap_Vestir[id_vestir] == nil {
                    userMesMap_Vestir[id_vestir] = []
                }
                userMesMap_Vestir[id_vestir]?.append(replyMessage_vestir)
                
            case .group_vestir:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Vestir()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Vestir(groupId_vestir: Int) {
        if var groupInfo_vestir = groupChats_Vestir[groupId_vestir] {
            groupInfo_vestir.messages_vestir = []
            groupChats_Vestir[groupId_vestir] = groupInfo_vestir
            notifyStateChange_Vestir()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Vestir(groupId_vestir: Int) {
        groupChats_Vestir.removeValue(forKey: groupId_vestir)
        notifyStateChange_Vestir()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Vestir() {
        aiChats_Vestir = []
        notifyStateChange_Vestir()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Vestir(userId_vestir: Int) {
        userMesMap_Vestir.removeValue(forKey: userId_vestir)
        notifyStateChange_Vestir()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Vestir() {
        userMesMap_Vestir = [:]
        groupChats_Vestir = [:]
        aiChats_Vestir = []
        notifyStateChange_Vestir()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Vestir() -> String {
        let formatter_vestir = DateFormatter()
        formatter_vestir.dateFormat = "HH:mm"
        return formatter_vestir.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Vestir() {
        NotificationCenter.default.post(
            name: MessageViewModel_Vestir.messageStateDidChangeNotification_Vestir,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Vestir(userId_vestir: Int, message_vestir: String) async -> String? {
        do {
            let bundleId_vestir = "com.vestir.app"
            let timestamp_vestir = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_vestir = generateRandomString_Vestir(length_vestir: 16)
            let sessionId_vestir = "\(timestamp_vestir)_\(randomString_vestir)"
            
            // 解密URL
            let urlString_vestir = decryptUrl_Vestir(encryptedCodes_vestir: MessageViewModel_Vestir.chatService_Vestir)
            guard let url_vestir = URL(string: urlString_vestir) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_vestir = URLRequest(url: url_vestir)
            request_vestir.httpMethod = "POST"
            request_vestir.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_vestir: [String: Any] = [
                "bundle_id": bundleId_vestir,
                "session_id": sessionId_vestir,
                "content_type": "text",
                "content": message_vestir
            ]
            
            request_vestir.httpBody = try JSONSerialization.data(withJSONObject: body_vestir)
            
            let (data_vestir, response_vestir) = try await URLSession.shared.data(for: request_vestir)
            
            if let httpResponse_vestir = response_vestir as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_vestir.statusCode)")
                
                if httpResponse_vestir.statusCode == 200 {
                    if let json_vestir = try JSONSerialization.jsonObject(with: data_vestir) as? [String: Any],
                       let code_vestir = json_vestir["code"] as? Int,
                       code_vestir == 1003,
                       let data_vestir = json_vestir["data"] as? [String: Any],
                       let answer_vestir = data_vestir["answer"] as? String,
                       !answer_vestir.isEmpty {
                        return answer_vestir
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Vestir(plainUrl_Vestir: String) -> [Int] {
        let xorKey_Vestir = 20 // 异或密钥
        let offset_Vestir = 23 // 字符偏移量
        
        var result_Vestir: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Vestir in plainUrl_Vestir.unicodeScalars {
            let charCode_Vestir = Int(char_Vestir.value) + offset_Vestir
            result_Vestir.append(charCode_Vestir)
        }
        
        // 第二层：异或加密
        var finalResult_Vestir: [Int] = []
        for code_Vestir in result_Vestir {
            finalResult_Vestir.append(code_Vestir ^ xorKey_Vestir)
        }
        
        print("✅ URL加密结果: \(finalResult_Vestir)")
        return finalResult_Vestir
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Vestir(encryptedCodes_vestir: [Int]) -> String {
        let xorKey_vestir = 20 // 异或密钥
        let offset_vestir = 23 // 字符偏移量
        
        var result_vestir = ""
        
        // 第一层：异或解密
        for code_vestir in encryptedCodes_vestir {
            let charCode_vestir = code_vestir ^ xorKey_vestir
            if let scalar_vestir = UnicodeScalar(charCode_vestir) {
                result_vestir.append(Character(scalar_vestir))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_vestir = ""
        for char_vestir in result_vestir.unicodeScalars {
            let charCode_vestir = Int(char_vestir.value) - offset_vestir
            if let scalar_vestir = UnicodeScalar(charCode_vestir) {
                finalResult_vestir.append(Character(scalar_vestir))
            }
        }
        
        return finalResult_vestir
    }
    
    /// 生成随机字符串
    private func generateRandomString_Vestir(length_vestir: Int) -> String {
        let letters_vestir = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_vestir).map { _ in letters_vestir.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Vestir {
    /// 群组ID
    var gid_vestir: Int
    /// 群组简介
    var intro_vestir: String
    /// 群组封面
    var cover_vestir: String
    /// 加入信息
    var join_vestir: String
    /// 消息列表
    var messages_vestir: [MessageModel_Vestir]
}
