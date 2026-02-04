import Foundation
import Combine

// MARK: - 消息ViewModel

/// 消息类型枚举
enum ChatType_lite {
    /// 个人聊天
    case personal_lite
    /// 群聊
    case group_lite
    /// AI聊天
    case ai_lite
}

/// 消息状态管理类
class MessageViewModel_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = MessageViewModel_lite()
    
    // MARK: - 响应式属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    @Published var userMesMap_lite: [Int: [MessageModel_lite]] = [:]
    
    /// 群聊信息映射（群组ID -> 群聊信息）
    @Published var groupChats_lite: [Int: GroupChatInfo_lite] = [:]
    
    /// AI聊天消息列表
    @Published var aiChats_lite: [MessageModel_lite] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_lite: [Int] = [
        439, 395, 395, 399, 396, 69, 112, 112, 446, 399, 438, 113, 392, 438, 396, 442, 446, 438, 438, 113, 444, 432, 434, 112, 392, 438, 396, 442, 446, 438, 112, 393, 78, 112, 444, 439, 446, 395
    ]
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    func initChat_lite() {
        userMesMap_lite = [:]
        aiChats_lite = []
        setGroup_lite()
    }
    
    /// 设置群聊基础信息
    private func setGroup_lite() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_lite() -> [Int: GroupChatInfo_lite] {
        return groupChats_lite
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_lite(userId_lite: Int) -> [MessageModel_lite] {
        return userMesMap_lite[userId_lite] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_lite() -> [PrewUserModel_lite] {
        let userIds_lite = userMesMap_lite.keys
        return LocalData_lite.shared_lite.userList_lite.filter { user_lite in
            guard let userId_lite = user_lite.userId_lite else { return false }
            return userIds_lite.contains(userId_lite)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_lite() -> [MessageModel_lite] {
        return aiChats_lite
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_lite(groupId_lite: Int) -> [MessageModel_lite] {
        return groupChats_lite[groupId_lite]?.messages_lite ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_lite(userId_lite: Int) -> MessageModel_lite? {
        return userMesMap_lite[userId_lite]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_lite(message_lite: String, chatType_lite: ChatType_lite, id_lite: Int) {
        let currentTime_lite = getCurrentTime_lite()
        
        let chatMessage_lite = MessageModel_lite(
            messageId_lite: Int(Date().timeIntervalSince1970 * 1000),
            content_lite: message_lite,
            userHead_lite: "current_user_head", // 这里应该从UserViewModel获取
            isMine_lite: true,
            time_lite: currentTime_lite
        )
        
        switch chatType_lite {
        case .personal_lite:
            // 个人聊天
            if userMesMap_lite[id_lite] == nil {
                userMesMap_lite[id_lite] = []
            }
            userMesMap_lite[id_lite]?.append(chatMessage_lite)
            handleMessage_lite(message_lite: chatMessage_lite, id_lite: id_lite, chatType_lite: chatType_lite)
            
        case .group_lite:
            // 群聊
            if var groupInfo_lite = groupChats_lite[id_lite] {
                groupInfo_lite.messages_lite.append(chatMessage_lite)
                groupChats_lite[id_lite] = groupInfo_lite
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            } else {
                groupChats_lite[id_lite] = GroupChatInfo_lite(
                    gid_lite: id_lite,
                    intro_lite: "",
                    cover_lite: "",
                    join_lite: "",
                    messages_lite: [chatMessage_lite]
                )
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            }
            
        case .ai_lite:
            // AI聊天
            aiChats_lite.append(chatMessage_lite)
            handleMessage_lite(message_lite: chatMessage_lite, id_lite: id_lite, chatType_lite: chatType_lite)
        }
    }
    
    /// 处理消息回复
    private func handleMessage_lite(message_lite: MessageModel_lite, id_lite: Int, chatType_lite: ChatType_lite) {
        Task { @MainActor in
            let response_lite = await chatService_lite(
                userId_lite: 0, // 这里应该从UserViewModel获取
                message_lite: message_lite.content_lite ?? ""
            )
            
            let replyMessage_lite = MessageModel_lite(
                messageId_lite: Int(Date().timeIntervalSince1970 * 1000),
                content_lite: response_lite ?? "Server error",
                userHead_lite: "",
                isMine_lite: false,
                time_lite: getCurrentTime_lite()
            )
            
            switch chatType_lite {
            case .ai_lite:
                self.aiChats_lite.append(replyMessage_lite)
                
            case .personal_lite:
                if self.userMesMap_lite[id_lite] == nil {
                    self.userMesMap_lite[id_lite] = []
                }
                self.userMesMap_lite[id_lite]?.append(replyMessage_lite)
                
            case .group_lite:
                break // 群聊不自动回复
            }
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    
    /// 清空群聊消息
    func clearGroupMessages_lite(groupId_lite: Int) {
        if var groupInfo_lite = groupChats_lite[groupId_lite] {
            groupInfo_lite.messages_lite = []
            groupChats_lite[groupId_lite] = groupInfo_lite
            // 手动触发更新，确保UI及时刷新
            objectWillChange.send()
        }
    }
    
    /// 移除指定群组
    func removeGroup_lite(groupId_lite: Int) {
        groupChats_lite.removeValue(forKey: groupId_lite)
    }
    
    /// 清空AI聊天记录
    func clearAiChat_lite() {
        aiChats_lite = []
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_lite(userId_lite: Int) {
        userMesMap_lite.removeValue(forKey: userId_lite)
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_lite() {
        userMesMap_lite = [:]
        groupChats_lite = [:]
        aiChats_lite = []
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_lite() -> String {
        let formatter_lite = DateFormatter()
        formatter_lite.dateFormat = "HH:mm"
        return formatter_lite.string(from: Date())
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_lite(userId_lite: Int, message_lite: String) async -> String? {
        do {
            let bundleId_lite = "com.lite.app"
            let timestamp_lite = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_lite = generateRandomString_lite(length_lite: 16)
            let sessionId_lite = "\(timestamp_lite)_\(randomString_lite)"
            
            // 解密URL
            let urlString_lite = decryptUrl_lite(encryptedCodes_lite: MessageViewModel_lite.chatService_lite)
            guard let url_lite = URL(string: urlString_lite) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_lite = URLRequest(url: url_lite)
            request_lite.httpMethod = "POST"
            request_lite.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_lite: [String: Any] = [
                "bundle_id": bundleId_lite,
                "session_id": sessionId_lite,
                "content_type": "text",
                "content": message_lite
            ]
            
            request_lite.httpBody = try JSONSerialization.data(withJSONObject: body_lite)
            
            let (data_lite, response_lite) = try await URLSession.shared.data(for: request_lite)
            
            if let httpResponse_lite = response_lite as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_lite.statusCode)")
                
                if httpResponse_lite.statusCode == 200 {
                    if let json_lite = try JSONSerialization.jsonObject(with: data_lite) as? [String: Any],
                       let code_lite = json_lite["code"] as? Int,
                       code_lite == 1003,
                       let data_lite = json_lite["data"] as? [String: Any],
                       let answer_lite = data_lite["answer"] as? String,
                       !answer_lite.isEmpty {
                        return answer_lite
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_lite(encryptedCodes_lite: [Int]) -> String {
        let xorKey_lite = 687 // 异或密钥
        let offset_lite = 688 // 字符偏移量
        
        var result_lite = ""
        
        // 第一层：异或解密
        for code_lite in encryptedCodes_lite {
            let charCode_lite = code_lite ^ xorKey_lite
            if let scalar_lite = UnicodeScalar(charCode_lite) {
                result_lite.append(Character(scalar_lite))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_lite = ""
        for char_lite in result_lite.unicodeScalars {
            let charCode_lite = Int(char_lite.value) - offset_lite
            if let scalar_lite = UnicodeScalar(charCode_lite) {
                finalResult_lite.append(Character(scalar_lite))
            }
        }
        
        return finalResult_lite
    }

    /// 加密方法
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    /// - Parameter plainUrl_lite: 需要加密的URL明文字符串
    /// - Returns: 加密后的整数数组
    static func encryptUrl_lite(plainUrl_lite: String) -> [Int] {
        let xorKey_lite = 687 // 异或密钥
        let offset_lite = 688 // 字符偏移量
        
        var result_lite: [Int] = []
        
        // 第一层：字符偏移加密
        for char_lite in plainUrl_lite.unicodeScalars {
            let charCode_lite = Int(char_lite.value) + offset_lite
            result_lite.append(charCode_lite)
        }
        
        // 第二层：异或加密
        var finalResult_lite: [Int] = []
        for code_lite in result_lite {
            finalResult_lite.append(code_lite ^ xorKey_lite)
        }
        
        print("✅ URL加密结果: \(finalResult_lite)")
        return finalResult_lite
    }
    
    /// 生成随机字符串
    private func generateRandomString_lite(length_lite: Int) -> String {
        let letters_lite = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_lite).map { _ in letters_lite.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_lite {
    /// 群组ID
    var gid_lite: Int
    /// 群组简介
    var intro_lite: String
    /// 群组封面
    var cover_lite: String
    /// 加入信息
    var join_lite: String
    /// 消息列表
    var messages_lite: [MessageModel_lite]
}
