const imageBaseUrl = import.meta.env.VITE_IMAGE_BASE_URL ?? 'http://localhost:8092';

/** Articles store a path; the CDN host is configuration. */
export function imageUrl(imagePath: string): string {
  return `${imageBaseUrl}${imagePath}`;
}
