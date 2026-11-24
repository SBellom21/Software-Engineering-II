import { calculateVisibilityScore, clampScore } from './scoring.calculator';

describe('Scoring Domain Calculator (TDD Base - RNF-06)', () => {
  it('acota puntajes al rango [0, 100] incluso con valores extremos o inválidos', () => {
    expect(clampScore(-20)).toBe(0);
    expect(clampScore(135)).toBe(100);
    expect(clampScore(82.6)).toBe(83);
    expect(clampScore(Number.NaN)).toBe(0);
  });

  it('otorga mayor VisibilityScore a un perfil/inmueble verificado frente a uno no verificado con igual score (BR-05)', () => {
    const weights = { scoreWeight: 1, verifiedBonus: 15, starsWeight: 2 };

    const unverified = calculateVisibilityScore({
      baseScore: 70,
      verified: false,
      avgStars: 5,
      weights,
    });
    const verified = calculateVisibilityScore({
      baseScore: 70,
      verified: true,
      avgStars: 5,
      weights,
    });

    expect(verified).toBeGreaterThan(unverified);
    expect(verified - unverified).toBe(15);
  });
});
