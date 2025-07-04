import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import db from '../db';
import logger from '../utils/logger';
import { UserService } from './UserService';

export interface PasswordResetToken {
  id: number;
  userId: number;
  token: string;
  expiresAt: Date;
  used: boolean;
  createdAt: Date;
}

export class PasswordResetService {
  private static readonly TOKEN_EXPIRY_HOURS = 1; // Token expires in 1 hour
  private static readonly SALT_ROUNDS = 10;

  /**
   * Generate a password reset token for a user
   */
  static async createResetToken(email: string): Promise<{ token: string; userId: number } | null> {
    try {
      // Find user by email
      const user = await UserService.findByEmail(email);
      if (!user) {
        // Don't reveal if user exists or not
        logger.warn('Password reset requested for non-existent email:', email);
        return null;
      }

      // Generate secure random token
      const token = crypto.randomBytes(32).toString('hex');
      const expiresAt = new Date(Date.now() + this.TOKEN_EXPIRY_HOURS * 60 * 60 * 1000);

      // Delete any existing unused tokens for this user
      await db('password_reset_tokens')
        .where('user_id', user.id)
        .where('used', false)
        .delete();

      // Insert new token
      await db('password_reset_tokens').insert({
        user_id: user.id,
        token,
        expires_at: expiresAt,
        used: false
      });

      logger.info('Password reset token created for user:', user.id);
      return { token, userId: user.id };
    } catch (error) {
      logger.error('Failed to create password reset token:', error);
      throw error;
    }
  }

  /**
   * Verify a password reset token
   */
  static async verifyToken(token: string): Promise<{ valid: boolean; userId?: number; email?: string }> {
    try {
      const tokenRecord = await db('password_reset_tokens')
        .where('token', token)
        .where('used', false)
        .where('expires_at', '>', new Date())
        .first();

      if (!tokenRecord) {
        return { valid: false };
      }

      // Get user info
      const user = await UserService.findById(tokenRecord.user_id);
      if (!user) {
        return { valid: false };
      }

      return {
        valid: true,
        userId: user.id,
        email: user.email
      };
    } catch (error) {
      logger.error('Failed to verify password reset token:', error);
      return { valid: false };
    }
  }

  /**
   * Reset password using token
   */
  static async resetPassword(token: string, newPassword: string): Promise<boolean> {
    try {
      // Verify token first
      const verification = await this.verifyToken(token);
      if (!verification.valid || !verification.userId) {
        return false;
      }

      // Hash new password
      const passwordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);

      // Update user password
      await db('users')
        .where('id', verification.userId)
        .update({
          password_hash: passwordHash,
          updated_at: new Date()
        });

      // Mark token as used
      await db('password_reset_tokens')
        .where('token', token)
        .update({
          used: true,
          updated_at: new Date()
        });

      logger.info('Password reset successful for user:', verification.userId);
      return true;
    } catch (error) {
      logger.error('Failed to reset password:', error);
      return false;
    }
  }

  /**
   * Direct password reset (for emergency use)
   */
  static async directPasswordReset(email: string, newPassword: string): Promise<boolean> {
    try {
      const user = await UserService.findByEmail(email);
      if (!user) {
        return false;
      }

      const passwordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);

      await db('users')
        .where('id', user.id)
        .update({
          password_hash: passwordHash,
          updated_at: new Date()
        });

      logger.info('Direct password reset for user:', user.id);
      return true;
    } catch (error) {
      logger.error('Failed to directly reset password:', error);
      return false;
    }
  }
}