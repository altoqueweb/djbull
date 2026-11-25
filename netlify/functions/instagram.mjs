// Devuelve los últimos reels de Instagram de DJ Bull.
// Necesita la variable de entorno IG_ACCESS_TOKEN en Netlify
// (Site configuration → Environment variables). Ver README, paso 6.
// Si no está configurada, responde una lista vacía y la página
// muestra recuadros con link a Instagram.

export default async () => {
  const token = process.env.IG_ACCESS_TOKEN;
  const headers = {
    'Content-Type': 'application/json',
    // Netlify guarda la respuesta 30 min para no pedirle a Instagram en cada visita
    'Cache-Control': 'public, max-age=300',
    'Netlify-CDN-Cache-Control': 'public, s-maxage=1800, stale-while-revalidate=3600'
  };
  if (!token) return new Response(JSON.stringify({ items: [], configured: false }), { headers });

  try {
    const fields = 'id,media_type,media_product_type,thumbnail_url,media_url,permalink,timestamp';
    const url = `https://graph.instagram.com/me/media?fields=${fields}&limit=25&access_token=${encodeURIComponent(token)}`;
    const r = await fetch(url);
    if (!r.ok) throw new Error('Instagram respondió ' + r.status);
    const json = await r.json();
    const items = (json.data || [])
      .filter((m) => m.media_type === 'VIDEO' || m.media_product_type === 'REELS')
      .slice(0, 6)
      .map((m) => ({ permalink: m.permalink, thumbnail: m.thumbnail_url || m.media_url, date: m.timestamp }));
    return new Response(JSON.stringify({ items, configured: true }), { headers });
  } catch (e) {
    return new Response(JSON.stringify({ items: [], error: String(e.message || e) }), { status: 200, headers });
  }
};
