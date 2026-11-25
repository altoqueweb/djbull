# DJ Bull · Página de booking + panel

Hecho por **AltoqueWeb**.

- **Página pública:** `public/index.html` (portada, cifras, mix, reels, flyers, fechas, booking)
- **Panel:** `public/admin.html` → se abre en `/admin`, entra con Google
- **Base de datos:** `supabase/schema.sql`
- **Reels automáticos:** `netlify/functions/instagram.mjs` y `tiktok.mjs`

No hay que instalar nada: es HTML + JavaScript y Netlify lo publica tal cual.

---

## Paso 1 · Subir el código a GitHub

1. En github.com/AltoqueWeb → **New repository** → nombre `djbull` → **Private** → Create.
2. En el repositorio vacío, toca **"uploading an existing file"**.
3. Arrastra **todo el contenido** de esta carpeta (las carpetas `public`, `netlify`, `supabase` y los archivos `netlify.toml` y `README.md`), no la carpeta en sí.
4. Abajo, **Commit changes**.

## Paso 2 · Crear la base de datos en Supabase

1. Supabase → tu proyecto → **SQL Editor** → **New query**.
2. Copia y pega todo `supabase/schema.sql` → **Run**. Debe decir *Success*.
3. Ve a **Project Settings → API** (o el botón verde **Connect**) y copia:
   - **Project URL** (`https://xxxx.supabase.co`)
   - **anon / publishable key** (la pública; **nunca** la *service_role / secret*)
4. En GitHub abre `public/config.js` → lápiz ✏️ → reemplaza los dos valores → **Commit changes**.

> El archivo ya deja como administradores a `contacto.djbull@gmail.com` y `altoque.web1@gmail.com`.
> Para agregar o quitar uno: Supabase → **Table Editor → admins**.

## Paso 3 · Publicar en Netlify

1. Netlify → **Add new project → Import an existing project → GitHub**.
2. Autoriza y elige **AltoqueWeb/djbull**.
3. Netlify lee `netlify.toml` solo: no cambies nada → **Deploy**.
4. **Project configuration → Change project name** → `djbull` → la página queda en `https://djbull.netlify.app` (si está tomado, usa otro y cámbialo en los pasos siguientes).

### Aviso por correo de cada solicitud (Netlify Forms)
1. Netlify → tu proyecto → **Forms** → **Enable form detection**.
2. **Deploys → Trigger deploy → Deploy project** (para que detecte el formulario).
3. **Forms → Form notifications → Add notification → Email notification** → `contacto.djbull@gmail.com` → formulario `booking`.

Las solicitudes llegan al correo **y** quedan guardadas en el panel (pestaña *Solicitudes*).

## Paso 4 · Login con Google para el panel

### 4a. Google Cloud (con el Gmail de AltoqueWeb)
1. console.cloud.google.com → crea un proyecto `AltoqueWeb`.
2. **APIs y servicios → Pantalla de consentimiento de OAuth** (o *Google Auth Platform*): tipo **Externo**, nombre de la app `DJ Bull Panel`, tu correo de soporte. Guarda.
3. En **Público / Audience**: **Publicar app** (o agrega como usuarios de prueba a `contacto.djbull@gmail.com` y `altoque.web1@gmail.com`).
4. **Credenciales / Clients → Crear ID de cliente de OAuth → Aplicación web**.
   - **URI de redireccionamiento autorizados:** `https://TU-PROYECTO.supabase.co/auth/v1/callback`
     (está en Supabase → Authentication → Sign In / Providers → Google, como *Callback URL*).
5. Copia el **ID de cliente** y el **Secreto**.

### 4b. Supabase
1. **Authentication → Sign In / Providers → Google** → actívalo → pega ID y secreto → Save.
2. **Authentication → URL Configuration:**
   - **Site URL:** `https://djbull.netlify.app`
   - **Redirect URLs:** agrega `https://djbull.netlify.app/admin`

Prueba: entra a `https://djbull.netlify.app/admin` → *Iniciar sesión con Google*.

## Paso 5 · Primer contenido (desde el panel)

- **Flyers:** sube los 3 de discos (Chinatown, Primera Musa, Cusi Night).
- **Fechas:** Prometeo (27 dic) y Cocoteo (12 feb) ya vienen cargadas.
- **Portada:** ya trae la foto de Javier. Se puede cambiar desde *Portada y cifras*.
- **Mix:** cuando exista, pegar el link en *Mix y TikTok*.

## Paso 6 · Reels automáticos de Instagram

Requiere que la cuenta de DJ Bull sea **Empresa o Creador** (ya lo es).

1. developers.facebook.com (con la cuenta de AltoqueWeb) → **Crear app** → caso de uso de **Instagram** (*API de Instagram con inicio de sesión de Instagram*).
2. En la configuración de la API de Instagram, **agrega la cuenta @djbull.cl** y **genera un token** (DJ Bull tendrá que aprobarlo una vez desde su Instagram).
3. Copia el token → Netlify → **Project configuration → Environment variables → Add** →
   - Key: `IG_ACCESS_TOKEN`  · Value: el token
4. **Deploys → Trigger deploy**. Los últimos reels aparecen solos en la página.

> El token dura unos **60 días**. Antes de que venza hay que renovarlo y reemplazarlo en Netlify
> (pendiente: automatizar la renovación).
> Mientras no esté configurado, la pestaña Instagram muestra recuadros con link a su perfil.

**TikTok:** se pegan los links de cada video en el panel (*Mix y TikTok*); la página saca la miniatura sola.

## Paso 7 · Cambiar el link de la bio

En Instagram y TikTok de DJ Bull, reemplazar el link de Beacons por `https://djbull.netlify.app`.
Para saber cuántas visitas vienen de cada red, se puede usar:
- Instagram: `https://djbull.netlify.app/?utm_source=instagram`
- TikTok: `https://djbull.netlify.app/?utm_source=tiktok`

---

## Qué mide el panel (pestaña Métricas)
Visitas, personas distintas, solicitudes, conversión, visitas por día, de dónde llegan
(Instagram, TikTok, WhatsApp, Google, directo…), qué botones tocan, flyers más vistos y si
entran desde celular o computador. Filtro de 7, 30 o 90 días.

## Notas
- **Plan gratis de Supabase:** pausa proyectos sin actividad por una semana. Con visitas reales no pasa; si pasa, se reactiva desde el dashboard.
- **Dominio propio (djbull.cl):** cuando lo compre, Netlify → *Domain management* → *Add domain*, y actualizar Site URL / Redirect URLs del paso 4.
