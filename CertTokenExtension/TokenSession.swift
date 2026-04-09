import CryptoTokenKit

class TokenSession: TKTokenSession, TKTokenSessionDelegate {
    override init(token: TKToken) {
        super.init(token: token)
        NSLog(">init do TokenSession")
        print(">init do TokenSession")
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
            // supportsAlgorithm matches at ANY level of the algorithm chain,
            // so .rsaSignatureRaw catches all RSA signing variants
            // (Message/Digest × PKCS1v15/PSS × SHA1/256/384/512).
            let ok = algorithm.supportsAlgorithm(.rsaSignatureRaw)
            NSLog("CertTokenExtension: supports signData key=%@ -> %@",
                String(describing: keyObjectID), ok ? "YES" : "NO")
            return ok
        case .decryptData:
            let ok = algorithm.supportsAlgorithm(.rsaEncryptionRaw)
            NSLog("CertTokenExtension: supports decryptData key=%@ -> %@",
                String(describing: keyObjectID), ok ? "YES" : "NO")
            return ok
        default:
            NSLog("CertTokenExtension: supports op=%d -> NO (unhandled)",
                operation.rawValue)
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
