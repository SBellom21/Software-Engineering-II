export enum UserRole {
  TENANT = 'TENANT',
  LANDLORD = 'LANDLORD',
  ADMIN = 'ADMIN',
}

export enum PublicRegisterRole {
  TENANT = 'TENANT',
  LANDLORD = 'LANDLORD',
}

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
  BLOCKED = 'BLOCKED',
}

/** BR-06: Exclusivamente APARTMENT o HOUSE (habitaciones prohibidas). */
export enum PropertyType {
  APARTMENT = 'APARTMENT',
  HOUSE = 'HOUSE',
}

export enum PropertyStatus {
  AVAILABLE = 'AVAILABLE',
  OCCUPIED = 'OCCUPIED',
  DEACTIVATED = 'DEACTIVATED',
}

export enum LikeStatus {
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
  REJECTED = 'REJECTED',
}

export enum OfficialRequestOrigin {
  SEARCH = 'SEARCH',
  MATCH = 'MATCH',
}

export enum OfficialRequestSentBy {
  TENANT = 'TENANT',
  SYSTEM = 'SYSTEM',
}

export enum LeaseStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  ENDED = 'ENDED',
}

export enum RatingTarget {
  TENANT = 'TENANT',
  PROPERTY = 'PROPERTY',
}

export enum VerificationTarget {
  USER = 'USER',
  PROPERTY = 'PROPERTY',
}

export enum VerificationStatus {
  PENDING = 'PENDING',
  UNMATCHED_TICKET = 'UNMATCHED_TICKET',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export enum InteractionAction {
  LIKE = 'LIKE',
  PASS = 'PASS',
  ACCEPT = 'ACCEPT',
  REJECT = 'REJECT',
  MATCH = 'MATCH',
  REQUEST = 'REQUEST',
}

export enum NotificationType {
  LIKE_RECEIVED = 'LIKE_RECEIVED',
  MATCH = 'MATCH',
  VERIFICATION_RESULT = 'VERIFICATION_RESULT',
  SUSPENSION = 'SUSPENSION',
  LEASE_CONFIRMATION = 'LEASE_CONFIRMATION',
  NEW_MESSAGE = 'NEW_MESSAGE',
}
