import { cookies } from "next/headers";
import { randomBytes, scryptSync, timingSafeEqual } from "crypto";
import { redirect } from "next/navigation";
import { db } from "./db";

const COOKIE_NAME = "kd_session";
const SESSION_DAYS = 180;

export function hashPin(pin: string) {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(pin, salt, 64).toString("hex");
  return { hash, salt };
}

export function verifyPin(pin: string, hash: string, salt: string) {
  const candidate = scryptSync(pin, salt, 64);
  const stored = Buffer.from(hash, "hex");
  if (candidate.length !== stored.length) return false;
  return timingSafeEqual(candidate, stored);
}

async function setSessionCookie(sessionId: string) {
  const store = await cookies();
  store.set(COOKIE_NAME, sessionId, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: SESSION_DAYS * 24 * 60 * 60,
  });
}

export async function createClientSession(clientId: string) {
  const expiresAt = new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000);
  const session = await db.session.create({
    data: { clientId, isProvider: false, expiresAt },
  });
  await setSessionCookie(session.id);
}

export async function createProviderSession() {
  const expiresAt = new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000);
  const session = await db.session.create({
    data: { isProvider: true, expiresAt },
  });
  await setSessionCookie(session.id);
}

async function getSession() {
  const store = await cookies();
  const sessionId = store.get(COOKIE_NAME)?.value;
  if (!sessionId) return null;
  const session = await db.session.findUnique({ where: { id: sessionId } });
  if (!session || session.expiresAt < new Date()) return null;
  return session;
}

export async function getCurrentClient() {
  const session = await getSession();
  if (!session || !session.clientId) return null;
  return db.client.findUnique({
    where: { id: session.clientId },
    include: { card: true },
  });
}

export async function isProviderSession() {
  const session = await getSession();
  return !!session?.isProvider;
}

export async function requireClient() {
  const client = await getCurrentClient();
  if (!client) redirect("/");
  return client;
}

export async function requireProvider() {
  const ok = await isProviderSession();
  if (!ok) redirect("/david/login");
}
