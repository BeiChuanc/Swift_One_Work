import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Sylva {
    /// 个人聊天
    case personal_sylva
    /// 群聊
    case group_sylva
    /// AI聊天
    case ai_sylva
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Sylva {
    
    /// 单例
    static let shared_Sylva = MessageViewModel_Sylva()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Sylva = Notification.Name("MessageStateDidChange_Sylva")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Sylva: [Int: [MessageModel_Sylva]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Sylva: [Int: GroupChatInfo_Sylva] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Sylva: [MessageModel_Sylva] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Sylva: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Sylva() {
        userMesMap_Sylva = [:]
        aiChats_Sylva = []
        notifyStateChange_Sylva()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Sylva() -> [Int: GroupChatInfo_Sylva] {
        return groupChats_Sylva
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Sylva(userId_sylva: Int) -> [MessageModel_Sylva] {
        return userMesMap_Sylva[userId_sylva] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Sylva() -> [PrewUserModel_Sylva] {
        let userIds_sylva = userMesMap_Sylva.keys
        return LocalData_Sylva.shared_Sylva.userList_Sylva.filter { user in
            guard let userId = user.userId_Sylva else { return false }
            return userIds_sylva.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Sylva() -> [MessageModel_Sylva] {
        return aiChats_Sylva
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Sylva(groupId_sylva: Int) -> [MessageModel_Sylva] {
        return groupChats_Sylva[groupId_sylva]?.messages_sylva ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Sylva(userId_sylva: Int) -> MessageModel_Sylva? {
        return userMesMap_Sylva[userId_sylva]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Sylva(message_sylva: String, chatType_sylva: ChatType_Sylva, id_sylva: Int) {
        let currentTime_sylva = getCurrentTime_Sylva()
        
        let chatMessage_sylva = MessageModel_Sylva(
            messageId_sylva: Int(Date().timeIntervalSince1970 * 1000),
            content_sylva: message_sylva,
            userHead_sylva: "current_user_head", // 这里应该从UserViewModel获取
            isMine_sylva: true,
            time_sylva: currentTime_sylva
        )
        
        switch chatType_sylva {
        case .personal_sylva:
            // 个人聊天
            if userMesMap_Sylva[id_sylva] == nil {
                userMesMap_Sylva[id_sylva] = []
            }
            userMesMap_Sylva[id_sylva]?.append(chatMessage_sylva)
            handleMessage_Sylva(message_sylva: chatMessage_sylva, id_sylva: id_sylva, chatType_sylva: chatType_sylva)
            
        case .group_sylva:
            // 群聊
            if var groupInfo_sylva = groupChats_Sylva[id_sylva] {
                groupInfo_sylva.messages_sylva.append(chatMessage_sylva)
                groupChats_Sylva[id_sylva] = groupInfo_sylva
            } else {
                groupChats_Sylva[id_sylva] = GroupChatInfo_Sylva(
                    gid_sylva: id_sylva,
                    intro_sylva: "",
                    cover_sylva: "",
                    join_sylva: "",
                    messages_sylva: [chatMessage_sylva]
                )
            }
            
        case .ai_sylva:
            // AI聊天
            aiChats_Sylva.append(chatMessage_sylva)
            handleMessage_Sylva(message_sylva: chatMessage_sylva, id_sylva: id_sylva, chatType_sylva: chatType_sylva)
        }
        
        notifyStateChange_Sylva()
    }
    
    /// 处理消息回复
    private func handleMessage_Sylva(message_sylva: MessageModel_Sylva, id_sylva: Int, chatType_sylva: ChatType_Sylva) {
        Task {
            let response_sylva = await chatService_Sylva(
                userId_sylva: 0, // 这里应该从UserViewModel获取
                message_sylva: message_sylva.content_Sylva ?? ""
            )
            
            let replyMessage_sylva = MessageModel_Sylva(
                messageId_sylva: Int(Date().timeIntervalSince1970 * 1000),
                content_sylva: response_sylva ?? "Server error",
                userHead_sylva: "",
                isMine_sylva: false,
                time_sylva: getCurrentTime_Sylva()
            )
            
            switch chatType_sylva {
            case .ai_sylva:
                aiChats_Sylva.append(replyMessage_sylva)
                
            case .personal_sylva:
                if userMesMap_Sylva[id_sylva] == nil {
                    userMesMap_Sylva[id_sylva] = []
                }
                userMesMap_Sylva[id_sylva]?.append(replyMessage_sylva)
                
            case .group_sylva:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Sylva()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Sylva(groupId_sylva: Int) {
        if var groupInfo_sylva = groupChats_Sylva[groupId_sylva] {
            groupInfo_sylva.messages_sylva = []
            groupChats_Sylva[groupId_sylva] = groupInfo_sylva
            notifyStateChange_Sylva()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Sylva(groupId_sylva: Int) {
        groupChats_Sylva.removeValue(forKey: groupId_sylva)
        notifyStateChange_Sylva()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Sylva() {
        aiChats_Sylva = []
        notifyStateChange_Sylva()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Sylva(userId_sylva: Int) {
        userMesMap_Sylva.removeValue(forKey: userId_sylva)
        notifyStateChange_Sylva()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Sylva() {
        userMesMap_Sylva = [:]
        groupChats_Sylva = [:]
        aiChats_Sylva = []
        notifyStateChange_Sylva()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Sylva() -> String {
        let formatter_sylva = DateFormatter()
        formatter_sylva.dateFormat = "HH:mm"
        return formatter_sylva.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Sylva() {
        NotificationCenter.default.post(
            name: MessageViewModel_Sylva.messageStateDidChangeNotification_Sylva,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Sylva(userId_sylva: Int, message_sylva: String) async -> String? {
        do {
            let bundleId_sylva = "com.sylva.app"
            let timestamp_sylva = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_sylva = generateRandomString_Sylva(length_sylva: 16)
            let sessionId_sylva = "\(timestamp_sylva)_\(randomString_sylva)"
            
            // 解密URL
            let urlString_sylva = decryptUrl_Sylva(encryptedCodes_sylva: MessageViewModel_Sylva.chatService_Sylva)
            guard let url_sylva = URL(string: urlString_sylva) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_sylva = URLRequest(url: url_sylva)
            request_sylva.httpMethod = "POST"
            request_sylva.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_sylva: [String: Any] = [
                "bundle_id": bundleId_sylva,
                "session_id": sessionId_sylva,
                "content_type": "text",
                "content": message_sylva
            ]
            
            request_sylva.httpBody = try JSONSerialization.data(withJSONObject: body_sylva)
            
            let (data_sylva, response_sylva) = try await URLSession.shared.data(for: request_sylva)
            
            if let httpResponse_sylva = response_sylva as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_sylva.statusCode)")
                
                if httpResponse_sylva.statusCode == 200 {
                    if let json_sylva = try JSONSerialization.jsonObject(with: data_sylva) as? [String: Any],
                       let code_sylva = json_sylva["code"] as? Int,
                       code_sylva == 1003,
                       let data_sylva = json_sylva["data"] as? [String: Any],
                       let answer_sylva = data_sylva["answer"] as? String,
                       !answer_sylva.isEmpty {
                        return answer_sylva
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
    static func encryptUrl_Sylva(plainUrl_Sylva: String) -> [Int] {
        let xorKey_Sylva = 20 // 异或密钥
        let offset_Sylva = 23 // 字符偏移量
        
        var result_Sylva: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Sylva in plainUrl_Sylva.unicodeScalars {
            let charCode_Sylva = Int(char_Sylva.value) + offset_Sylva
            result_Sylva.append(charCode_Sylva)
        }
        
        // 第二层：异或加密
        var finalResult_Sylva: [Int] = []
        for code_Sylva in result_Sylva {
            finalResult_Sylva.append(code_Sylva ^ xorKey_Sylva)
        }
        
        print("✅ URL加密结果: \(finalResult_Sylva)")
        return finalResult_Sylva
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Sylva(encryptedCodes_sylva: [Int]) -> String {
        let xorKey_sylva = 20 // 异或密钥
        let offset_sylva = 23 // 字符偏移量
        
        var result_sylva = ""
        
        // 第一层：异或解密
        for code_sylva in encryptedCodes_sylva {
            let charCode_sylva = code_sylva ^ xorKey_sylva
            if let scalar_sylva = UnicodeScalar(charCode_sylva) {
                result_sylva.append(Character(scalar_sylva))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_sylva = ""
        for char_sylva in result_sylva.unicodeScalars {
            let charCode_sylva = Int(char_sylva.value) - offset_sylva
            if let scalar_sylva = UnicodeScalar(charCode_sylva) {
                finalResult_sylva.append(Character(scalar_sylva))
            }
        }
        
        return finalResult_sylva
    }
    
    /// 生成随机字符串
    private func generateRandomString_Sylva(length_sylva: Int) -> String {
        let letters_sylva = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_sylva).map { _ in letters_sylva.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Sylva {
    /// 群组ID
    var gid_sylva: Int
    /// 群组简介
    var intro_sylva: String
    /// 群组封面
    var cover_sylva: String
    /// 加入信息
    var join_sylva: String
    /// 消息列表
    var messages_sylva: [MessageModel_Sylva]
}
