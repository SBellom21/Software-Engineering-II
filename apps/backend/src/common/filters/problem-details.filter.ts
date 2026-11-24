import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { DomainErrorCode, ProblemDetails } from '@arriendos/api-types';
import { randomUUID } from 'crypto';
import { Response } from 'express';

@Catch()
export class ProblemDetailsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let title = 'Error interno del servidor';
    let detail = 'Ocurrió un error inesperado procesando la solicitud.';
    let code: string = DomainErrorCode.INTERNAL_ERROR;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        detail = exceptionResponse;
        title = exception.name;
      } else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const body = exceptionResponse as Record<string, unknown>;
        title = typeof body.title === 'string' ? body.title : exception.name;
        detail =
          typeof body.detail === 'string'
            ? body.detail
            : typeof body.message === 'string'
              ? body.message
              : detail;
        code = typeof body.code === 'string' ? body.code : code;
      }
    }

    const problem: ProblemDetails = {
      type: `https://api.arriendosbogota.co/errors/${code.toLowerCase()}`,
      title,
      status,
      detail,
      code,
      traceId: randomUUID(),
      timestamp: new Date().toISOString(),
    };

    response.status(status).type('application/problem+json').json(problem);
  }
}
