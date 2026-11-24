import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit(): Promise<void> {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return;
    }
    // Conexión diferida en desarrollo si aún no se ha levantado Docker
    try {
      await this.$connect();
    } catch {
      // Se manejará en readiness probe
    }
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
