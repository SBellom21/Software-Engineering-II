export interface VisibilityScoreInput {
  baseScore: number;
  verified: boolean;
  avgStars: number;
  weights: {
    scoreWeight: number;
    verifiedBonus: number;
    starsWeight: number;
  };
}

export function clampScore(value: number): number {
  if (Number.isNaN(value) || !Number.isFinite(value)) {
    return 0;
  }
  return Math.max(0, Math.min(100, Math.round(value)));
}

/**
 * Fórmula oficial de VisibilityScore (Sección 4.11 / BR-05):
 * VisibilityScore = (score * w_score) + (I_verified * b_verified) + (avg_stars * w_stars)
 */
export function calculateVisibilityScore(input: VisibilityScoreInput): number {
  const clampedBase = clampScore(input.baseScore);
  const verifiedFactor = input.verified ? 1 : 0;
  const stars = Math.max(1, Math.min(5, input.avgStars));

  return Number(
    (
      clampedBase * input.weights.scoreWeight +
      verifiedFactor * input.weights.verifiedBonus +
      stars * input.weights.starsWeight
    ).toFixed(4),
  );
}
