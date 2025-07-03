import jwt, { SignOptions } from 'jsonwebtoken';
import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';
import db from '../db';
import config from '../config';
import logger from '../utils/logger';

/**
 * Token Refresh Service
 * 
 * SOLID Principles Applied:
 * - SRP: Only handles token generation, validation, and rotation
 * - OCP: Extensible for different token types and security policies
 * - LSP: Token interfaces are interchangeable
 * - ISP: Focused interface for token operations
 * - DIP: Depends on configuration and database abstractions
 */

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresAt: Date;
  refreshTokenExpiresAt: Date;
}

export interface RefreshTokenData {
  id: number;
  userId: number;
  tokenHash: string;
  jti: string;
  deviceId?: string;
  deviceName?: string;
  userAgent?: string;
  ipAddress?: string;
  issuedAt: Date;
  expiresAt: Date;
  lastUsedAt?: Date;
  isRevoked: boolean;
  rotationCount: number;
}

export interface DeviceInfo {
  deviceId?: string;
  deviceName?: string;
  userAgent?: string;
  ipAddress?: string;
}

export interface AccessTokenPayload {
  id: number;
  email: string;
  username: string;
  jti: string; // JWT ID for tracking
  iat: number; // Issued at
  exp: number; // Expires at
}

export interface RefreshTokenPayload {
  userId: number;
  jti: string;
  deviceId?: string;
  iat: number;
  exp: number;
}

export class TokenRefreshService {
  private static readonly ACCESS_TOKEN_EXPIRY = '15m'; // 15 minutes
  private static readonly REFRESH_TOKEN_EXPIRY_DAYS = 30; // 30 days
  private static readonly MAX_REFRESH_TOKENS_PER_USER = 5; // Limit concurrent sessions

  /**
   * Generate initial token pair for authentication
   */
  static async generateTokenPair(
    user: { id: number; email: string; username: string },
    deviceInfo?: DeviceInfo
  ): Promise<TokenPair> {
    try {
      const jti = uuidv4();
      const refreshJti = uuidv4();
      
      // Calculate expiration times
      const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
      const refreshTokenExpiresAt = new Date(Date.now() + this.REFRESH_TOKEN_EXPIRY_DAYS * 24 * 60 * 60 * 1000);

      // Generate access token
      const accessTokenPayload: AccessTokenPayload = {
        id: user.id,
        email: user.email,
        username: user.username,
        jti,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(accessTokenExpiresAt.getTime() / 1000)
      };

      // Don't set any SignOptions since jti and exp are already in payload
      const accessToken = jwt.sign(accessTokenPayload, config.security.jwtSecret);

      // Generate refresh token
      const refreshTokenPayload: RefreshTokenPayload = {
        userId: user.id,
        jti: refreshJti,
        deviceId: deviceInfo?.deviceId,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(refreshTokenExpiresAt.getTime() / 1000)
      };

      // Don't set any SignOptions since jti and exp are already in payload
      const refreshToken = jwt.sign(refreshTokenPayload, config.security.refreshTokenSecret);

      // Store refresh token in database
      await this.storeRefreshToken(refreshToken, refreshJti, user.id, refreshTokenExpiresAt, deviceInfo);

      // Clean up old tokens if user has too many
      await this.cleanupUserTokens(user.id);

      logger.info('Token pair generated', {
        userId: user.id,
        jti,
        refreshJti,
        deviceId: deviceInfo?.deviceId
      });

      return {
        accessToken,
        refreshToken,
        accessTokenExpiresAt,
        refreshTokenExpiresAt
      };
    } catch (error) {
      logger.error('Failed to generate token pair:', error);
      throw new Error('Token generation failed');
    }
  }

  /**
   * Refresh access token using refresh token
   */
  static async refreshAccessToken(
    refreshToken: string,
    deviceInfo?: DeviceInfo
  ): Promise<TokenPair> {
    try {
      // Verify refresh token
      const decoded = jwt.verify(refreshToken, config.security.refreshTokenSecret) as RefreshTokenPayload;
      
      // Get refresh token data from database
      const tokenData = await this.getRefreshTokenData(decoded.jti);
      if (!tokenData) {
        throw new Error('Refresh token not found');
      }

      // Validate refresh token
      this.validateRefreshToken(tokenData, refreshToken);

      // Get user data
      const user = await db('users')
        .where('id', tokenData.userId)
        .select('id', 'email', 'username')
        .first();

      if (!user) {
        throw new Error('User not found');
      }

      // Update last used time
      await this.updateTokenLastUsed(tokenData.id);

      // Generate new access token
      const jti = uuidv4();
      const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000);

      const accessTokenPayload: AccessTokenPayload = {
        id: user.id,
        email: user.email,
        username: user.username,
        jti,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(accessTokenExpiresAt.getTime() / 1000)
      };

      // Don't set any SignOptions since jti and exp are already in payload
      const accessToken = jwt.sign(accessTokenPayload, config.security.jwtSecret);

      logger.info('Access token refreshed', {
        userId: user.id,
        newJti: jti,
        refreshJti: decoded.jti,
        rotationCount: tokenData.rotationCount
      });

      return {
        accessToken,
        refreshToken, // Return same refresh token
        accessTokenExpiresAt,
        refreshTokenExpiresAt: tokenData.expiresAt
      };
    } catch (error) {
      logger.error('Failed to refresh access token:', error);
      
      if (error instanceof jwt.JsonWebTokenError) {
        throw new Error('Invalid refresh token');
      }
      if (error instanceof jwt.TokenExpiredError) {
        throw new Error('Refresh token expired');
      }
      
      throw error;
    }
  }

  /**
   * Rotate refresh token for enhanced security
   */
  static async rotateRefreshToken(
    currentRefreshToken: string,
    deviceInfo?: DeviceInfo
  ): Promise<TokenPair> {
    try {
      // Verify current refresh token
      const decoded = jwt.verify(currentRefreshToken, config.security.refreshTokenSecret) as RefreshTokenPayload;
      
      // Get current token data
      const currentTokenData = await this.getRefreshTokenData(decoded.jti);
      if (!currentTokenData) {
        throw new Error('Refresh token not found');
      }

      // Validate current token
      this.validateRefreshToken(currentTokenData, currentRefreshToken);

      // Get user data
      const user = await db('users')
        .where('id', currentTokenData.userId)
        .select('id', 'email', 'username')
        .first();

      if (!user) {
        throw new Error('User not found');
      }

      // Generate new token pair
      const newTokenPair = await this.generateTokenPair(user, {
        ...deviceInfo,
        deviceId: deviceInfo?.deviceId || currentTokenData.deviceId || undefined
      });

      // Revoke old refresh token
      await this.revokeRefreshToken(currentTokenData.jti, 'rotated');

      // Link new token to old token for audit trail
      const newRefreshDecoded = jwt.verify(newTokenPair.refreshToken, config.security.refreshTokenSecret) as RefreshTokenPayload;
      await this.linkTokenRotation(newRefreshDecoded.jti, currentTokenData.jti, currentTokenData.rotationCount + 1);

      logger.info('Refresh token rotated', {
        userId: user.id,
        oldJti: currentTokenData.jti,
        newJti: newRefreshDecoded.jti,
        rotationCount: currentTokenData.rotationCount + 1
      });

      return newTokenPair;
    } catch (error) {
      logger.error('Failed to rotate refresh token:', error);
      throw error;
    }
  }

  /**
   * Revoke refresh token
   */
  static async revokeRefreshToken(jti: string, reason: string = 'manual'): Promise<void> {
    try {
      await db('refresh_tokens')
        .where('jti', jti)
        .update({
          is_revoked: true,
          revoked_at: new Date(),
          revocation_reason: reason,
          updated_at: new Date()
        });

      logger.info('Refresh token revoked', { jti, reason });
    } catch (error) {
      logger.error('Failed to revoke refresh token:', error);
      throw error;
    }
  }

  /**
   * Revoke all refresh tokens for a user
   */
  static async revokeAllUserTokens(userId: number, reason: string = 'logout_all'): Promise<void> {
    try {
      await db('refresh_tokens')
        .where('user_id', userId)
        .where('is_revoked', false)
        .update({
          is_revoked: true,
          revoked_at: new Date(),
          revocation_reason: reason,
          updated_at: new Date()
        });

      logger.info('All user tokens revoked', { userId, reason });
    } catch (error) {
      logger.error('Failed to revoke all user tokens:', error);
      throw error;
    }
  }

  /**
   * Get user's active refresh tokens
   */
  static async getUserActiveTokens(userId: number): Promise<RefreshTokenData[]> {
    try {
      const tokens = await db('refresh_tokens')
        .where('user_id', userId)
        .where('is_revoked', false)
        .where('expires_at', '>', new Date())
        .orderBy('last_used_at', 'desc')
        .select('*');

      return tokens.map(this.mapDatabaseRecordToTokenData);
    } catch (error) {
      logger.error('Failed to get user active tokens:', error);
      throw error;
    }
  }

  /**
   * Clean up expired and revoked tokens
   */
  static async cleanupExpiredTokens(): Promise<void> {
    try {
      const deletedCount = await db('refresh_tokens')
        .where('expires_at', '<', new Date())
        .orWhere('is_revoked', true)
        .del();

      logger.info('Cleanup completed', { deletedTokens: deletedCount });
    } catch (error) {
      logger.error('Failed to cleanup expired tokens:', error);
      throw error;
    }
  }

  // Private helper methods

  private static async storeRefreshToken(
    refreshToken: string,
    jti: string,
    userId: number,
    expiresAt: Date,
    deviceInfo?: DeviceInfo
  ): Promise<void> {
    const tokenHash = this.hashToken(refreshToken);
    
    await db('refresh_tokens').insert({
      user_id: userId,
      token_hash: tokenHash,
      jti,
      device_id: deviceInfo?.deviceId,
      device_name: deviceInfo?.deviceName,
      user_agent: deviceInfo?.userAgent,
      ip_address: deviceInfo?.ipAddress,
      expires_at: expiresAt,
      rotation_count: 0
    });
  }

  private static async getRefreshTokenData(jti: string): Promise<RefreshTokenData | null> {
    const record = await db('refresh_tokens')
      .where('jti', jti)
      .first();

    return record ? this.mapDatabaseRecordToTokenData(record) : null;
  }

  private static validateRefreshToken(tokenData: RefreshTokenData, refreshToken: string): void {
    if (tokenData.isRevoked) {
      throw new Error('Refresh token has been revoked');
    }

    if (tokenData.expiresAt < new Date()) {
      throw new Error('Refresh token has expired');
    }

    const tokenHash = this.hashToken(refreshToken);
    if (tokenHash !== tokenData.tokenHash) {
      throw new Error('Invalid refresh token');
    }
  }

  private static async updateTokenLastUsed(tokenId: number): Promise<void> {
    await db('refresh_tokens')
      .where('id', tokenId)
      .update({
        last_used_at: new Date(),
        updated_at: new Date()
      });
  }

  private static async linkTokenRotation(
    newJti: string,
    previousJti: string,
    rotationCount: number
  ): Promise<void> {
    await db('refresh_tokens')
      .where('jti', newJti)
      .update({
        previous_token_jti: previousJti,
        rotation_count: rotationCount,
        updated_at: new Date()
      });
  }

  private static async cleanupUserTokens(userId: number): Promise<void> {
    const activeTokens = await db('refresh_tokens')
      .where('user_id', userId)
      .where('is_revoked', false)
      .where('expires_at', '>', new Date())
      .orderBy('last_used_at', 'desc')
      .select('jti');

    if (activeTokens.length > this.MAX_REFRESH_TOKENS_PER_USER) {
      const tokensToRevoke = activeTokens.slice(this.MAX_REFRESH_TOKENS_PER_USER);
      
      for (const token of tokensToRevoke) {
        await this.revokeRefreshToken(token.jti, 'session_limit_exceeded');
      }
    }
  }

  private static hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  private static mapDatabaseRecordToTokenData(record: any): RefreshTokenData {
    return {
      id: record.id,
      userId: record.user_id,
      tokenHash: record.token_hash,
      jti: record.jti,
      deviceId: record.device_id,
      deviceName: record.device_name,
      userAgent: record.user_agent,
      ipAddress: record.ip_address,
      issuedAt: new Date(record.issued_at),
      expiresAt: new Date(record.expires_at),
      lastUsedAt: record.last_used_at ? new Date(record.last_used_at) : undefined,
      isRevoked: record.is_revoked,
      rotationCount: record.rotation_count
    };
  }
} 