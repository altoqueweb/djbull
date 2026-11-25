// Recibe los links de TikTok guardados en el panel y devuelve su miniatura,
// usando el oEmbed público de TikTok (no necesita cuenta de desarrollador).
// Uso: /.netlify/functions/tiktok?urls=link1,link2,...

const ALLOWED = /^https:\/\/(www\.|vm\.|vt\.)?tiktok\.com\//i;

export default async (req) => {
  const headers = {
    'Content-Type': 'application/json',
    'Cache-Control': 'public, max-age=300',
    'Netlify-CDN-Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400'
  };
  const urls = (new URL(req.url).searchParams.get('urls') || '')
    .split(',').map((u) => u.trim()).filter((u) => ALLOWED.test(u)).slice(0, 6);

  const items = await Promise.all(urls.map(async (url) => {
    try {
      const r = await fetch('https://www.tiktok.com/oembed?url=' + encodeURIComponent(url));
      if (!r.ok) return { url };
      const j = await r.json();
      return { url, thumbnail: j.thumbnail_url || null, title: j.title || null };
    } catch {
      return { url };
    }
  }));
  return new Response(JSON.stringify({ items }), { headers });
};
