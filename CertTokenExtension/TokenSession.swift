import CryptoTokenKit

class TokenSession: TKTokenSession, TKTokenSessionDelegate {
    override init(token: TKToken) {
        super.init(token: token)
        delegate = self
    }

    func tokenSession(
        _ session: TKTokenSession,
        supports operation: TKTokenOperation,
        keyObjectID: Any,
        algorithm: TKTokenKeyAlgorithm
    ) -> Bool {
        switch operation {
        case .signData:
            return algorithm.isAlgorithm(.rsaSignatureMessagePKCS1v15SHA256)
                || algorithm.isAlgorithm(.rsaSignatureMessagePKCS1v15SHA384)
                || algorithm.isAlgorithm(.rsaSignatureMessagePKCS1v15SHA512)
        case .decryptData:
            return algorithm.isAlgorithm(.rsaEncryptionPKCS1)
        default:
            return false
        }
    }

    func tokenSession(
        _ session: TKTokenSession,
        sign dataToSign: Data,
        keyObjectID: Any,
        algorithm: TKTokenKeyAlgorithm
    ) throws -> Data {
        NSLog("CertTokenExtension: sign requested for key %@", String(describing: keyObjectID))
        throw NSError(domain: "CertTokenExtension", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Signing not yet implemented (pending HSM API)"
        ])
    }

    func tokenSession(
        _ session: TKTokenSession,
        decrypt ciphertext: Data,
        keyObjectID: Any,
        algorithm: TKTokenKeyAlgorithm
    ) throws -> Data {
        NSLog("CertTokenExtension: decrypt requested for key %@", String(describing: keyObjectID))
        throw NSError(domain: "CertTokenExtension", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Decryption not yet implemented (pending HSM API)"
        ])
    }
}
