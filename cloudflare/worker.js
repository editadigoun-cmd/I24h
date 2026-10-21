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
  return btoa(binary).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
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
    const isTokenRoute = request.method === "POST" && url.pathname === "/api/livekit/token";
    const isPromoteRoute = request.method === "POST" && url.pathname === "/api/livekit/promote";
    if (!isTokenRoute && !isPromoteRoute) {
      return json({ error: "Not found" }, 404);
    }

    const authorization = request.headers.get("Authorization") || "";
    if (!env.LIVEKIT_API_SECRET || !env.SUPABASE_ANON_KEY) {
      return json({ error: "Configuration serveur incomplète. Les secrets LiveKit et Supabase doivent être configurés." }, 503);
    }

    let body;
    try { body = await request.json(); } catch { return json({ error: "Corps JSON invalide." }, 400); }
    const participantName = typeof body.participant_name === "string" ? body.participant_name.trim().slice(0, 80) : "Auditeur I24H";
    const invitationCode = typeof body.invitation_code === "string" ? body.invitation_code.trim() : "";

    // Public listeners may join the live room without creating an account.
    // Anonymous tokens are strictly read-only and cannot publish audio, video or data.
    if (!authorization.startsWith("Bearer ")) {
      if (!isTokenRoute) return json({ error: "Authentification requise." }, 401);
      if (invitationCode) return json({ error: "Connectez-vous pour utiliser un code d’invitation." }, 401);
      const now = Math.floor(Date.now() / 1000);
      const identity = "viewer-" + crypto.randomUUID();
      const token = await signJwt({
        iss: LIVEKIT_API_KEY,
        sub: identity,
        nbf: now - 5,
        iat: now,
        exp: now + 1800,
        name: participantName || "Auditeur I24H",
        video: {
          roomJoin: true,
          room: ROOM_NAME,
          canPublish: false,
          canSubscribe: true,
          canPublishData: false,
        },
      }, env.LIVEKIT_API_SECRET);
      return json({
        server_url: LIVEKIT_URL,
        participant_token: token,
        room_name: ROOM_NAME,
        role: "listener",
        expires_in: 1800,
      }, 201);
    }
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
    let canPublish = role === "admin" || role === "administrateur" || role === "animateur";

    // An animator may publish only during a published program assigned to the
    // exact profile name. The database clock is used to avoid trusting a device clock.
    // Admins retain operational access for emergency continuity.
    let assignedSlot = null;
    if (role === "animateur" && isTokenRoute && !invitationCode) {
      const profileResponse = await fetch(
        SUPABASE_URL + "/rest/v1/profiles?id=eq." + encodeURIComponent(user.id) + "&select=full_name&limit=1",
        { headers: { "Authorization": authorization, "apikey": env.SUPABASE_ANON_KEY } }
      );
      if (!profileResponse.ok) return json({ error: "Impossible de vérifier le profil animateur." }, 403);
      const profileRows = await profileResponse.json();
      const fullName = Array.isArray(profileRows) && profileRows[0]
        ? String(profileRows[0].full_name || "").trim() : "";
      if (!fullName) return json({ error: "Votre profil animateur n’a pas de nom complet configuré." }, 403);

      const nowIso = new Date().toISOString();
      const slotUrl = SUPABASE_URL + "/rest/v1/programs?select=id,title,starts_at,ends_at,presenter"
        + "&is_published=eq.true&presenter=eq." + encodeURIComponent(fullName)
        + "&starts_at=lte." + encodeURIComponent(nowIso)
        + "&ends_at=gt." + encodeURIComponent(nowIso)
        + "&order=starts_at.desc&limit=1";
      const slotResponse = await fetch(slotUrl, {
        headers: { "Authorization": authorization, "apikey": env.SUPABASE_ANON_KEY },
      });
      if (!slotResponse.ok) return json({ error: "Impossible de vérifier votre créneau de direct." }, 503);
      const slots = await slotResponse.json();
      assignedSlot = Array.isArray(slots) && slots.length ? slots[0] : null;
      if (!assignedSlot || !assignedSlot.ends_at) {
        return json({
          error: "Aucun créneau de direct actif ne vous est attribué. Le direct est réservé aux animateurs programmés et uniquement pendant leur horaire.",
          code: "NO_ACTIVE_SLOT",
        }, 403);
      }
    }

    if (isPromoteRoute) {
      if (!canPublish) return json({ error: "Seuls les administrateurs et animateurs peuvent faire monter un auditeur." }, 403);
      const identity = typeof body.identity === "string" ? body.identity.trim() : "";
      if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(identity)) {
        return json({ error: "Identifiant du membre invalide." }, 400);
      }
      const now = Math.floor(Date.now() / 1000);
      const serviceToken = await signJwt({
        iss: LIVEKIT_API_KEY,
        sub: "i24h-moderator",
        nbf: now - 5,
        iat: now,
        exp: now + 60,
        video: { roomAdmin: true, room: ROOM_NAME },
      }, env.LIVEKIT_API_SECRET);
      const promoteResponse = await fetch(LIVEKIT_URL.replace(/^wss:/, "https:").replace(/\\/$/, "") + "/twirp/livekit.RoomService/UpdateParticipant", {
        method: "POST",
        headers: {
          "Authorization": "Bearer " + serviceToken,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          room: ROOM_NAME,
          identity,
          permission: { canPublish: true, canSubscribe: true, canPublishData: true },
        }),
      });
      if (!promoteResponse.ok) {
        const detail = (await promoteResponse.text()).slice(0, 300);
        return json({ error: "LiveKit n'a pas pu autoriser ce membre à parler.", detail }, 502);
      }
      return json({ success: true, identity, canPublish: true });
    }

    if (!canPublish && invitationCode) {
      const inviteResponse = await fetch(SUPABASE_URL + "/rest/v1/rpc/consume_live_guest_invitation", {
        method: "POST",
        headers: {
          "Authorization": authorization,
          "apikey": env.SUPABASE_ANON_KEY,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          p_invite_code: invitationCode,
          p_participant_id: user.id,
          p_participant_email: user.email || "",
        }),
      });
      if (!inviteResponse.ok) return json({ error: "Impossible de vérifier cette invitation. Réessayez." }, 403);
      canPublish = (await inviteResponse.json()) === true;
      if (!canPublish) return json({ error: "Invitation invalide, expirée ou destinée à une autre adresse e-mail." }, 403);
    }

    const now = Math.floor(Date.now() / 1000);
    const slotEndEpoch = assignedSlot ? Math.floor(Date.parse(assignedSlot.ends_at) / 1000) : null;
    const tokenExpiry = slotEndEpoch ? Math.min(now + 3600, slotEndEpoch) : now + 3600;
    if (tokenExpiry <= now) return json({ error: "Votre créneau de direct est terminé.", code: "SLOT_ENDED" }, 403);
    const token = await signJwt({
      iss: LIVEKIT_API_KEY,
      sub: user.id,
      nbf: now - 5,
      iat: now,
      exp: tokenExpiry,
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
      role: canPublish ? (role === "admin" || role === "administrateur" ? "admin-speaker" : role === "animateur" ? "scheduled-animator" : "guest-speaker") : "listener",
      expires_in: Math.max(0, tokenExpiry - now),
      ...(assignedSlot ? { scheduled_program: { id: assignedSlot.id, title: assignedSlot.title, starts_at: assignedSlot.starts_at, ends_at: assignedSlot.ends_at } } : {}),
    }, 201);
  },
};
