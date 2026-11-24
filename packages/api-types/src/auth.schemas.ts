import { z } from 'zod';
import { PublicRegisterRole } from './enums';

/** BR-02: Selección de rol obligatoria antes de registro. BR-27: >= 18 años. */
export const RegisterSchema = z.object({
  role: z.nativeEnum(PublicRegisterRole),
  fullName: z.string().min(2).max(120),
  email: z.string().email().toLowerCase(),
  birthDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Formato YYYY-MM-DD requerido'),
  password: z.string().min(8).max(72).optional(),
  googleIdToken: z.string().min(10).optional(),
  privacyPolicyVersion: z.string().min(1),
});

export const LoginSchema = z.object({
  email: z.string().email().toLowerCase(),
  password: z.string().min(1).optional(),
  googleIdToken: z.string().min(10).optional(),
});

export const SelectRoleSchema = z.object({
  selectionToken: z.string().min(10),
  role: z.nativeEnum(PublicRegisterRole),
});

export type RegisterDto = z.infer<typeof RegisterSchema>;
export type LoginDto = z.infer<typeof LoginSchema>;
export type SelectRoleDto = z.infer<typeof SelectRoleSchema>;
