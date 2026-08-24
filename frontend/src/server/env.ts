import { z } from 'zod';

const envSchema = z.object({
  ARTICLES_CORE_URL: z.url().default('http://localhost:8091'),
  SERVER_LISTEN_ADDR: z
    .string()
    .regex(/^[^:]*:\d+$/, 'must be in host:port form')
    .default('0.0.0.0:3010'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  throw new Error(`Invalid environment configuration:\n${z.prettifyError(parsed.error)}`);
}

export const env = parsed.data;
