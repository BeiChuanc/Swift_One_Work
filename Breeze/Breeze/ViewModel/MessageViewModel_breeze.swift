import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Breeze {
    /// 个人聊天
    case personal_breeze
    /// 群聊
    case group_breeze
    /// AI聊天
    case ai_breeze
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Breeze {
    
    /// 单例
    static let shared_Breeze = MessageViewModel_Breeze()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Breeze = Notification.Name("MessageStateDidChange_Breeze")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Breeze: [Int: [MessageModel_Breeze]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Breeze: [Int: GroupChatInfo_Breeze] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Breeze: [MessageModel_Breeze] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Breeze: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Breeze() {
        userMesMap_Breeze = [:]
        aiChats_Breeze = []
        notifyStateChange_Breeze()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Breeze() -> [Int: GroupChatInfo_Breeze] {
        return groupChats_Breeze
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Breeze(userId_breeze: Int) -> [MessageModel_Breeze] {
        return userMesMap_Breeze[userId_breeze] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Breeze() -> [PrewUserModel_Breeze] {
        let userIds_breeze = userMesMap_Breeze.keys
        return LocalData_Breeze.shared_Breeze.userList_Breeze.filter { user in
            guard let userId = user.userId_Breeze else { return false }
            return userIds_breeze.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Breeze() -> [MessageModel_Breeze] {
        return aiChats_Breeze
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Breeze(groupId_breeze: Int) -> [MessageModel_Breeze] {
        return groupChats_Breeze[groupId_breeze]?.messages_breeze ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Breeze(userId_breeze: Int) -> MessageModel_Breeze? {
        return userMesMap_Breeze[userId_breeze]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Breeze(message_breeze: String, chatType_breeze: ChatType_Breeze, id_breeze: Int) {
        let currentTime_breeze = getCurrentTime_Breeze()
        
        let chatMessage_breeze = MessageModel_Breeze(
            messageId_breeze: Int(Date().timeIntervalSince1970 * 1000),
            content_breeze: message_breeze,
            userHead_breeze: "current_user_head", // 这里应该从UserViewModel获取
            isMine_breeze: true,
            time_breeze: currentTime_breeze
        )
        
        switch chatType_breeze {
        case .personal_breeze:
            // 个人聊天
            if userMesMap_Breeze[id_breeze] == nil {
                userMesMap_Breeze[id_breeze] = []
            }
            userMesMap_Breeze[id_breeze]?.append(chatMessage_breeze)
            handleMessage_Breeze(message_breeze: chatMessage_breeze, id_breeze: id_breeze, chatType_breeze: chatType_breeze)
            
        case .group_breeze:
            // 群聊
            if var groupInfo_breeze = groupChats_Breeze[id_breeze] {
                groupInfo_breeze.messages_breeze.append(chatMessage_breeze)
                groupChats_Breeze[id_breeze] = groupInfo_breeze
            } else {
                groupChats_Breeze[id_breeze] = GroupChatInfo_Breeze(
                    gid_breeze: id_breeze,
                    intro_breeze: "",
                    cover_breeze: "",
                    join_breeze: "",
                    messages_breeze: [chatMessage_breeze]
                )
            }
            
        case .ai_breeze:
            // AI聊天
            aiChats_Breeze.append(chatMessage_breeze)
            handleMessage_Breeze(message_breeze: chatMessage_breeze, id_breeze: id_breeze, chatType_breeze: chatType_breeze)
        }
        
        notifyStateChange_Breeze()
    }
    
    /// 处理消息回复
    private func handleMessage_Breeze(message_breeze: MessageModel_Breeze, id_breeze: Int, chatType_breeze: ChatType_Breeze) {
        Task {
            let response_breeze = await chatService_Breeze(
                userId_breeze: 0, // 这里应该从UserViewModel获取
                message_breeze: message_breeze.content_Breeze ?? ""
            )
            
            let replyMessage_breeze = MessageModel_Breeze(
                messageId_breeze: Int(Date().timeIntervalSince1970 * 1000),
                content_breeze: response_breeze ?? "Server error",
                userHead_breeze: "",
                isMine_breeze: false,
                time_breeze: getCurrentTime_Breeze()
            )
            
            switch chatType_breeze {
            case .ai_breeze:
                aiChats_Breeze.append(replyMessage_breeze)
                
            case .personal_breeze:
                if userMesMap_Breeze[id_breeze] == nil {
                    userMesMap_Breeze[id_breeze] = []
                }
                userMesMap_Breeze[id_breeze]?.append(replyMessage_breeze)
                
            case .group_breeze:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Breeze()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Breeze(groupId_breeze: Int) {
        if var groupInfo_breeze = groupChats_Breeze[groupId_breeze] {
            groupInfo_breeze.messages_breeze = []
            groupChats_Breeze[groupId_breeze] = groupInfo_breeze
            notifyStateChange_Breeze()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Breeze(groupId_breeze: Int) {
        groupChats_Breeze.removeValue(forKey: groupId_breeze)
        notifyStateChange_Breeze()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Breeze() {
        aiChats_Breeze = []
        notifyStateChange_Breeze()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Breeze(userId_breeze: Int) {
        userMesMap_Breeze.removeValue(forKey: userId_breeze)
        notifyStateChange_Breeze()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Breeze() {
        userMesMap_Breeze = [:]
        groupChats_Breeze = [:]
        aiChats_Breeze = []
        notifyStateChange_Breeze()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Breeze() -> String {
        let formatter_breeze = DateFormatter()
        formatter_breeze.dateFormat = "HH:mm"
        return formatter_breeze.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Breeze() {
        NotificationCenter.default.post(
            name: MessageViewModel_Breeze.messageStateDidChangeNotification_Breeze,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Breeze(userId_breeze: Int, message_breeze: String) async -> String? {
        do {
            let bundleId_breeze = "com.breeze.app"
            let timestamp_breeze = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_breeze = generateRandomString_Breeze(length_breeze: 16)
            let sessionId_breeze = "\(timestamp_breeze)_\(randomString_breeze)"
            
            // 解密URL
            let urlString_breeze = decryptUrl_Breeze(encryptedCodes_breeze: MessageViewModel_Breeze.chatService_Breeze)
            guard let url_breeze = URL(string: urlString_breeze) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_breeze = URLRequest(url: url_breeze)
            request_breeze.httpMethod = "POST"
            request_breeze.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_breeze: [String: Any] = [
                "bundle_id": bundleId_breeze,
                "session_id": sessionId_breeze,
                "content_type": "text",
                "content": message_breeze
            ]
            
            request_breeze.httpBody = try JSONSerialization.data(withJSONObject: body_breeze)
            
            let (data_breeze, response_breeze) = try await URLSession.shared.data(for: request_breeze)
            
            if let httpResponse_breeze = response_breeze as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_breeze.statusCode)")
                
                if httpResponse_breeze.statusCode == 200 {
                    if let json_breeze = try JSONSerialization.jsonObject(with: data_breeze) as? [String: Any],
                       let code_breeze = json_breeze["code"] as? Int,
                       code_breeze == 1003,
                       let data_breeze = json_breeze["data"] as? [String: Any],
                       let answer_breeze = data_breeze["answer"] as? String,
                       !answer_breeze.isEmpty {
                        return answer_breeze
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
    static func encryptUrl_Breeze(plainUrl_Breeze: String) -> [Int] {
        let xorKey_Breeze = 20 // 异或密钥
        let offset_Breeze = 23 // 字符偏移量
        
        var result_Breeze: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Breeze in plainUrl_Breeze.unicodeScalars {
            let charCode_Breeze = Int(char_Breeze.value) + offset_Breeze
            result_Breeze.append(charCode_Breeze)
        }
        
        // 第二层：异或加密
        var finalResult_Breeze: [Int] = []
        for code_Breeze in result_Breeze {
            finalResult_Breeze.append(code_Breeze ^ xorKey_Breeze)
        }
        
        print("✅ URL加密结果: \(finalResult_Breeze)")
        return finalResult_Breeze
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Breeze(encryptedCodes_breeze: [Int]) -> String {
        let xorKey_breeze = 20 // 异或密钥
        let offset_breeze = 23 // 字符偏移量
        
        var result_breeze = ""
        
        // 第一层：异或解密
        for code_breeze in encryptedCodes_breeze {
            let charCode_breeze = code_breeze ^ xorKey_breeze
            if let scalar_breeze = UnicodeScalar(charCode_breeze) {
                result_breeze.append(Character(scalar_breeze))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_breeze = ""
        for char_breeze in result_breeze.unicodeScalars {
            let charCode_breeze = Int(char_breeze.value) - offset_breeze
            if let scalar_breeze = UnicodeScalar(charCode_breeze) {
                finalResult_breeze.append(Character(scalar_breeze))
            }
        }
        
        return finalResult_breeze
    }
    
    /// 生成随机字符串
    private func generateRandomString_Breeze(length_breeze: Int) -> String {
        let letters_breeze = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_breeze).map { _ in letters_breeze.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Breeze {
    /// 群组ID
    var gid_breeze: Int
    /// 群组简介
    var intro_breeze: String
    /// 群组封面
    var cover_breeze: String
    /// 加入信息
    var join_breeze: String
    /// 消息列表
    var messages_breeze: [MessageModel_Breeze]
}
