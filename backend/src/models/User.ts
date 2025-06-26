export interface User {
  id: number;
  email: string;
  username: string;
  password_hash: string | null;
  first_name?: string;
  last_name?: string;
  avatar_url?: string;
  google_id?: string;
  is_active: boolean;
  email_verified: boolean;
  echo_score: number;
  bias_profile?: BiasProfile;
  preferred_challenge_time?: string;
  current_streak: number;
  last_activity_date?: Date;
  created_at: Date;
  updated_at: Date;
}

export interface BiasProfile {
  initial_assessment_score: number;
  political_lean: number; // -3 to +3 scale
  preferred_sources: string[];
  blind_spots: string[];
  assessment_date: Date;
}

export interface CreateUserRequest {
  email: string;
  username: string;
  password: string;
  first_name?: string;
  last_name?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: Omit<User, 'password_hash'>;
  token: string;
}

export interface UpdateProfileRequest {
  first_name?: string;
  last_name?: string;
  username?: string;
  email?: string;
  avatar_url?: string;
  preferred_challenge_time?: string;
}

export interface ProfileUpdateResponse {
  user: any;
  message: string;
} 