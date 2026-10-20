const LIVEKIT_URL = "wss://i24h-lsx4vdhf.livekit.cloud";
const LIVEKIT_API_KEY = "APIPYUuADbstEyG";
const SUPABASE_URL = "https://pwujpjjoxxqupckurrad.supabase.co";
const ROOM_NAME = "i24h-live";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
  "Access-Control-Allow-Headers": "Authorization, Content-Type",
  "Access-Control-Max-Age": "86400",
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8", ...corsHeaders },
  });
}

function base64url(bytes) {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replace(/=/g, "").replace(/\\+/g, "-").replace(/\\//g, "_");
}

function encodeJson(value) {
  return base64url(new TextEncoder().encode(JSON.stringify(value)));
}

async function signJwt(payload, secret) {
  const header = encodeJson({ alg: "HS256", typ: "JWT" });
  const body = encodeJson(payload);
  const unsigned = header + "." + body;
  const key = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
  );
  const signature = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(unsigned));
  return unsigned + "." + base64url(new Uint8Array(signature));
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders });
    if (request.method === "GET" && url.pathname === "/api/health") {
      return json({
        service: "i24h-livekit-token",
        status: "ok",
        livekitConfigured: Boolean(env.LIVEKIT_API_SECRET),
        supabaseConfigured: Boolean(env.SUPABASE_ANON_KEY),
        apiKeyConfigured: Boolean(LIVEKIT_API_KEY),
      });
    }
    if (request.method !== "POST" || url.pathname !== "/api/livekit/token") {
      return json({ error: "Not found" }, 404);
    }

    const authHeader = request.headers.get("Authorization") || "";
    if (!authHeader.startsWith("Bearer ")) return json({ error: "Authentification requise." }, 401);
    if (!env.LIVEKIT_API_SECRET || !env.SUPABASE_ANON_KEY) {
      return json({ error: "Configuration serveur incomplète. Les secrets LiveKit et Supabase doivent être configurés." }, 503);
    }

    let body;
    try { body = await request.json(); } catch { return json({ error: "Corps JSON invalide." }, 400); }
    const participantName = typeof body.participant_name === "string" ? body.participant_name.trim().slice(0, 80) : "Participant I24H";
    const authorization = authHeader;

    const authResponse = await fetch(SUPABASE_URL + "/auth/v1/user", {
      headers: { "Authorization": authorization, "apikey": env.SUPABASE_ANON_KEY },
    });
    if (!authResponse.ok) return json({ error: "Session Supabase invalide ou expirée." }, 401);
    const user = await authResponse.json();
    if (!user || typeof user.id !== "string") return json({ error: "Utilisateur non authentifié." }, 401);

    const profileResponse = await fetch(
      SUPABASE_URL + "/rest/v1/profiles?id=eq." + encodeURIComponent(user.id) + "&select=role&limit=1",
      { headers: { "Authorization": authorization, "apikey": env.SUPABASE_ANON_KEY } }
    );
    if (!profileResponse.ok) return json({ error: "Impossible de vérifier le rôle du compte." }, 403);
    const profiles = await profileResponse.json();
    const role = Array.isArray(profiles) && profiles[0] ? String(profiles[0].role || "").toLowerCase() : "";
    const canPublish = role === "admin" || role === "administrateur" || role === "animateur";

    const now = Math.floor(Date.now() / 1000);
    const token = await signJwt({
      iss: LIVEKIT_API_KEY,
      sub: user.id,
      nbf: now - 5,
      iat: now,
      exp: now + 3600,
      name: participantName || "Participant I24H",
      video: {
        roomJoin: true,
        room: ROOM_NAME,
        canPublish,
        canSubscribe: true,
        canPublishData: true,
      },
    }, env.LIVEKIT_API_SECRET);

    return json({
      server_url: LIVEKIT_URL,
      participant_token: token,
      room_name: ROOM_NAME,
      role: canPublish ? "speaker" : "listener",
      expires_in: 3600,
    }, 201);
  },
};