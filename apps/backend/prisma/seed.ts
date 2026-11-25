import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main(): Promise<void> {
  // Seed intencionalmente vacío por instrucción explícita:
  // No se crean usuarios ADMIN, pesos iniciales ni polígonos de Bogotá sin autorización/datos oficiales IDECA.
  await prisma.$queryRaw`SELECT 1`;
}

main()
  .catch((error: unknown) => {
    console.error('Error ejecutando seed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
